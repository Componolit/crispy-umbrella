pragma Style_Checks ("N3aAbCdefhiIklnOprStux");
pragma Warnings (Off, """Always_Terminates"" is not a valid aspect identifier");

with RFLX.RFLX_Generic_Types.Generic_Operators;

generic
   with package Operators is new RFLX.RFLX_Generic_Types.Generic_Operators (<>);
package RFLX.RFLX_Generic_Types.Generic_Operations with
   SPARK_Mode,
   Always_Terminates
is
   use Operators;

   use type U64;

   function Extract
      (Buffer : Bytes_Ptr;
       First  : Index;
       Last   : Index;
       Off    : Offset;
       Size   : Positive;
       BO     : Byte_Order) return U64
   with
     Pre =>
       (Buffer /= null
        and then First >= Buffer'First
        and then Last <= Buffer'Last
        and then Size in 1 .. U64'Size
        and then First <= Last
        and then Last - First <= Index'Last - 1
        and then Length ((Offset'Pos (Off) + Size - 1) / Byte'Size) < Length (Last - First + 1)
        and then (Offset'Pos (Off) + Size - 1) / Byte'Size <= Natural'Size
        and then (Byte'Size - Natural (Offset'Pos (Off) mod Byte'Size)) < Long_Integer'Size - 1),
    Post =>
       (if Size < U64'Size then Extract'Result < 2**Size);

   function Extract
      (Buffer : Bytes_Ptr;
       First  : Index;
       Last   : Index;
       Off    : Offset;
       Size   : Positive;
       BO     : Byte_Order) return Base_Integer
   with
     Pre =>
       (Buffer /= null
        and then First >= Buffer'First
        and then Last <= Buffer'Last
        and then Size in 1 .. 63
        and then First <= Last
        and then Last - First <= Index'Last - 1
        and then Length ((Offset'Pos (Off) + Size - 1) / Byte'Size) < Length (Last - First + 1)
        and then (Offset'Pos (Off) + Size - 1) / Byte'Size <= Natural'Size
        and then (Byte'Size - Natural (Offset'Pos (Off) mod Byte'Size)) < Long_Integer'Size - 1),
    Post =>
       (U64 (Extract'Result) < 2**Size);

   procedure Insert
      (Val    : U64;
       Buffer : Bytes_Ptr;
       First  : Index;
       Last   : Index;
       Off    : Offset;
       Size   : Positive;
       BO     : Byte_Order)
   with
     Pre =>
       (Buffer /= null
        and then First >= Buffer'First
        and then Last <= Buffer'Last
        and then Size in 1 .. U64'Size
        and then Fits_Into (Val, Size)
        and then First <= Last
        and then Last - First <= Index'Last - 1
        and then Length ((Offset'Pos (Off) + Size - 1) / Byte'Size) < Length (Last - First + 1)),
     Post =>
       (Buffer'First = Buffer.all'Old'First and Buffer'Last = Buffer.all'Old'Last);

   procedure Insert
      (Val    : Base_Integer;
       Buffer : Bytes_Ptr;
       First  : Index;
       Last   : Index;
       Off    : Offset;
       Size   : Positive;
       BO     : Byte_Order)
   with
     Pre =>
       (Buffer /= null
        and then First >= Buffer'First
        and then Last <= Buffer'Last
        and then Size in 1 .. 63
        and then Fits_Into (Val, Size)
        and then First <= Last
        and then Last - First <= Index'Last - 1
        and then Length ((Offset'Pos (Off) + Size - 1) / Byte'Size) < Length (Last - First + 1)),
     Post =>
       (Buffer'First = Buffer.all'Old'First and Buffer'Last = Buffer.all'Old'Last);

end RFLX.RFLX_Generic_Types.Generic_Operations;
