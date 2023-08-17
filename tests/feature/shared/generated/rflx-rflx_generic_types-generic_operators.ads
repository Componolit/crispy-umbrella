pragma Style_Checks ("N3aAbCdefhiIklnOprStux");
pragma Warnings (Off, """Always_Terminates"" is not a valid aspect identifier");

generic
package RFLX.RFLX_Generic_Types.Generic_Operators with
   SPARK_Mode,
   Annotate =>
     (GNATprove, Always_Return)
is

   function "+" (Left : Index; Right : Length) return Index is
      (Index (Length (Left) + Right))
   with
     Pre =>
       Length (Left) <= Length'Last - Right;

   function "-" (Left : Index; Right : Index) return Length is
      (Length (Left) - Length (Right))
   with
     Pre =>
       Length (Left) >= Length'First + Length (Right);

   function "-" (Left : Index; Right : Length) return Index is
      (Index (Length (Left) - Right))
   with
     Pre =>
       Right < Length'Last
       and then Length (Left) >= Length (Index'First) + Right;

end RFLX.RFLX_Generic_Types.Generic_Operators;
