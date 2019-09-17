# RecordFlux

[![Build Status](https://travis-ci.org/Componolit/RecordFlux.svg?branch=master)](https://travis-ci.org/Componolit/RecordFlux)
[![Code Coverage](https://codecov.io/github/Componolit/RecordFlux/coverage.svg?branch=master)](https://codecov.io/github/Componolit/RecordFlux)
[![Python Versions](https://img.shields.io/badge/python-3.6%20%7C%203.7-blue.svg)](https://python.org/)
[![Checked with mypy](http://www.mypy-lang.org/static/mypy_badge.svg)](http://mypy-lang.org/)

RecordFlux is a toolset for the formal specification of messages and the generation of verifiable binary parsers.

## Message Specification Language

The RecordFlux Message Specification Language is a domain-specific language to formally specify message formats of existing real-world binary protocols. Its syntax is inspired by [Ada](https://www.adacore.com/about-ada). A detailed description of the language elements can be found in the [Language Reference](/doc/Language-Reference.md).

## Code Generation

The code generator generates parsers based on message specifications. The generated parser allows to validate and dissect messages and thereby respects all specified restrictions between message fields and related messages. Adding the generation of messages is planned. By using [SPARK](https://www.adacore.com/about-spark) we are able to prove the absence of runtime errors and prevent the incorrect usage of the generated code (e.g., enforce that a field of a message is validated before accessed).

The code generator creates a number of packages for a specification. All basic types like integers, enumerations and arrays are collectively declared in one package. For each message a child package is generated which contains validation and access functions for every field of the message.

A user of the generated code has to validate a message field or the whole message before accessing the data of a particular message field. The SPARK verifcation tools in combination with the generated contracts make it possible to ensure this property, and so prevent incorrect usage.

## Usage

The `rflx` tool is used to verify a specification and generate code based on it. It offers the two sub-commands `check` and `generate` for this purpose.

## Example

In the following, the complete process of specifying a message, generating code, and using the generated code is demonstrated using a small example.

### Specification

The following sample specification describes a protocol `TLV` with one message type `Message` consisting of three fields:

- A field `Tag` of 2 bit length,
- a field `Value_Length` of 14 bit length, and
- a field `Value`, whose length is specified by the value in `Value_Length`.

The `Tag` can have two valid values: `1` (`Msg_Data`) and `3` (`Msg_Error`). In case `Tag` has a value of `1` the fields `Value_Length` and `Value` follow. `Message` contains only the `Tag` field, if the value of `Tag` is `3`. All other values of `Tag` lead to an invalid message.

The structure of messages is often non-linear because of optional fields. For this reason the specification uses a graph-based representation. The order of fields is defined by then clauses. Then clauses are also used to state conditions and aspects of the following field. A more detailed description can be found in the [Language Reference](doc/Language-Reference.md#message-type).

```
package TLV is

   type Tag_Type is (Msg_Data => 1, Msg_Error => 3) with Size => 2;
   type Length_Type is mod 2**14;

   type Message is
      message
         Tag    : Tag_Type
            then Length
               if Tag = Msg_Data,
            then null
               if Tag = Msg_Error;
         Length : Length_Type
            then Value
               with Length => Length * 8;
         Value  : Payload_Type;
       end message;

end TLV;
```

### Generating Code

With the sub-command `check` the correctness of the given specification file can be checked.

```
$ rflx check specs/tlv.rflx
Parsing specs/tlv.rflx... OK
```

The sub-command `generate` is used to generate the code based on the specification. The target directory and the specification files have to be given.

```
$ rflx generate specs/tlv.rflx generated
Parsing specs/tlv.rflx... OK
Generating... OK
Created generated/rflx-tlv.ads
Created generated/rflx-tlv-generic_message.ads
Created generated/rflx-tlv-generic_message.adb
Created generated/rflx-tlv-message.ads
Created generated/rflx.ads
Created generated/rflx-types.ads
Created generated/rflx-types.adb
Created generated/rflx-message_sequence.ads
Created generated/rflx-message_sequence.adb
Created generated/rflx-scalar_sequence.ads
Created generated/rflx-scalar_sequence.adb
```

### Use of Generated Code

All scalar types defined in the specification are represented by a similar Ada type in the generated code. For `TLV` the following types are defined in the package `RFLX.TLV`:

- `type Tag_Type is (Msg_Data, Msg_Error) with Size => 2`
- `for Tag_Type use (Msg_Data => 1, Msg_Error => 3);`
- `type Length_Type is mod 2**14`

All types and subprograms related to `Message` can be found in the package `RFLX.TLV.Message`:

- `type Context_Type`
    - Stores buffer and internal state
- `function Create return Context_Type`
    - Return default initialized context
- `procedure Initialize (Context : out Context_Type; Buffer : in out RFLX.Types.Bytes_Ptr)`
    - Initialize context with buffer
- `procedure Initialize (Context : out Context_Type; Buffer : in out RFLX.Types.Bytes_Ptr; First, Last : RFLX.Types.Bit_Index_Type)`
    - Initialize context with buffer and explicit bounds
- `procedure Take_Buffer (Context : in out Context_Type; Buffer : out RFLX.Types.Bytes_Ptr)`
    - Get buffer and remove it from context (note: buffer cannot put back into context, thus further verification of message is not possible after this action)
- `function Has_Buffer (Context : Context_Type) return Boolean`
    - Check if context contains buffer (i.e. non-null pointer)
- `procedure Verify (Context : in out Context_Type; Field : Field_Type)`
    - Verify validity of field
- `procedure Verify_Message (Context : in out Context_Type)`
    - Verify all fields of message
- `function Structural_Valid (Context : Context_Type; Field : Field_Type) return Boolean`
    - Check if composite field is structural valid (i.e. location and length of field is correct, but content is not necessarily valid)
- `function Present (Context : Context_Type; Field : Field_Type) return Boolean`
    - Check if composite field is structural valid and has non-zero length
- `function Valid (Context : Context_Type; Field : Field_Type) return Boolean`
    - Check if field is valid (i.e. it has valid structure and valid content)
- `function Incomplete (Context : Context_Type; Field : Field_Type) return Boolean`
    - Check if buffer was too short to verify field
- `function Structural_Valid_Message (Context : Context_Type) return Boolean`
    - Check if all fields of message are at least structural valid
- `function Valid_Message (Context : Context_Type) return Boolean`
    - Check if all fields of message are valid
- `function Incomplete_Message (Context : Context_Type) return Boolean`
    - Check if buffer was too short to verify message
- `function Get_Tag (Context : Context_Type) return Tag_Type`
    - Get value of `Tag` field
- `function Get_Length (Context : Context_Type) return Length_Type`
    - Get value of `Length` field
- `generic with procedure Process_Value (Value : RFLX.Types.Bytes); procedure Get_Value (Context : Context_Type)`
    - Access content of `Value` field

A simple program to parse a `TLV.Message` could be as follows:

```
with Ada.Text_IO;
with RFLX.Types;
with RFLX.TLV.Message;

procedure Main is
   Buffer  : RFLX.Types.Bytes_Ptr := new RFLX.Types.Bytes'(64, 4, 0, 0, 0, 0);
   Context : RFLX.TLV.Message.Context_Type := RFLX.TLV.Message.Create;
begin
   RFLX.TLV.Message.Initialize (Context, Buffer);
   RFLX.TLV.Message.Verify_Message (Context);
   if RFLX.TLV.Message.Structural_Valid_Message (Context) then
      case RFLX.TLV.Message.Get_Tag (Context) is
         when RFLX.TLV.Msg_Data =>
            if RFLX.TLV.Message.Present (Context, RFLX.TLV.Message.F_Value) then
               Ada.Text_IO.Put_Line ("Data message with value of"
                                     & RFLX.TLV.Message.Get_Length (Context)'Img
                                     & " byte length");
            else
               Ada.Text_IO.Put_Line ("Data message without value");
            end if;
         when RFLX.TLV.Msg_Error =>
            Ada.Text_IO.Put_Line ("Error message");
      end case;
   else
      Ada.Text_IO.Put_Line ("Invalid message");
   end if;
end Main;
```

In case that a valid message is contained in `Buffer` the value of `Tag` is read. If the value of `Tag` is `Msg_Data` and the `Value` field is present, the content of `Value` can be accessed.

## Dependencies

- [Python >=3.6](https://www.python.org)
- [PyParsing 2.4.0](https://github.com/pyparsing/pyparsing/)
- [GNAT Community 2019](https://www.adacore.com/download)

## Known Issues

### GNAT Community 2019

- GNAT shows an incorrect warning for `Initialize (Context, Buffer)`. It can be suppressed by adding `pragma Warnings (Off, "unused assignment to ""Buffer""")`.
- GNATprove is not able to prove the generated code, if only CVC4 and Z3 are used. Adding `--no-axiom-guard` circumvents this problem.

These issues should be fixed in the next GNAT Community release.

## Licence

This software is licensed under the `AGPL-3.0`. See the `LICENSE` file for the full license text.
