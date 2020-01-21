with RFLX.Types;
use type RFLX.Types.Bytes, RFLX.Types.Bytes_Ptr, RFLX.Types.Index, RFLX.Types.Length, RFLX.Types.Bit_Index, RFLX.Types.Bit_Length;

package RFLX.Enumeration with
  SPARK_Mode
is

   type Priority_Base is mod 2**3;

   type Priority_Enum is (LOW, MEDIUM, HIGH) with
     Size =>
       3;
   for Priority_Enum use (LOW => 1, MEDIUM => 4, HIGH => 7);

   type Priority (Known : Boolean := False) is
      record
         case Known is
            when True =>
               Enum : Priority_Enum;
            when False =>
               Raw : Priority_Base;
         end case;
      end record;

   pragma Warnings (Off, "precondition is statically false");

   function Unreachable_Enumeration_Priority return Enumeration.Priority is
     ((False, Enumeration.Priority_Base'First))
    with
     Pre =>
       False;

   pragma Warnings (On, "precondition is statically false");

   function Extract is new RFLX.Types.Extract (RFLX.Types.Index, RFLX.Types.Byte, RFLX.Types.Bytes, RFLX.Types.Offset, Enumeration.Priority_Base);

   procedure Insert is new RFLX.Types.Insert (RFLX.Types.Index, RFLX.Types.Byte, RFLX.Types.Bytes, RFLX.Types.Offset, Enumeration.Priority_Base);

   pragma Warnings (Off, "unused variable ""Val""");

   function Valid (Val : Enumeration.Priority_Base) return Boolean is
     (True);

   pragma Warnings (On, "unused variable ""Val""");

   function Convert (Enum : Priority_Enum) return Enumeration.Priority_Base is
     ((case Enum is
         when LOW =>
            1,
         when MEDIUM =>
            4,
         when HIGH =>
            7));

   function Convert (Enum : Priority_Enum) return Enumeration.Priority is
     ((True, Enum));

   function Convert (Val : Enumeration.Priority_Base) return Enumeration.Priority is
     ((case Val is
         when 1 =>
            (True, LOW),
         when 4 =>
            (True, MEDIUM),
         when 7 =>
            (True, HIGH),
         when others =>
            (False, Val)))
    with
     Pre =>
       Valid (Val);

   function Convert (Val : Enumeration.Priority) return Enumeration.Priority_Base is
     ((if Val.Known then
       Convert (Val.Enum)
    else
       Val.Raw));

end RFLX.Enumeration;
