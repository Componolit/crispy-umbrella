pragma Style_Checks ("N3aAbCdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");
with RFLX.RFLX_Types;

package RFLX.UDP with
  SPARK_Mode
is

   type Port is range 0 .. 2**16 - 1 with
     Size =>
       16;

   use type RFLX.RFLX_Types.Base_Integer;

   function Valid_Port (Val : RFLX.RFLX_Types.Base_Integer) return Boolean is
     (Val <= 65535);

   function To_Base_Integer (Val : RFLX.UDP.Port) return RFLX.RFLX_Types.Base_Integer is
     (RFLX.RFLX_Types.Base_Integer (Val));

   function To_Actual (Val : RFLX.RFLX_Types.Base_Integer) return RFLX.UDP.Port is
     (RFLX.UDP.Port (Val))
    with
     Pre =>
       Valid_Port (Val);

   type Length is range 8 .. 2**16 - 1 with
     Size =>
       16;

   function Valid_Length (Val : RFLX.RFLX_Types.Base_Integer) return Boolean is
     (Val >= 8
      and Val <= 65535);

   function To_Base_Integer (Val : RFLX.UDP.Length) return RFLX.RFLX_Types.Base_Integer is
     (RFLX.RFLX_Types.Base_Integer (Val));

   function To_Actual (Val : RFLX.RFLX_Types.Base_Integer) return RFLX.UDP.Length is
     (RFLX.UDP.Length (Val))
    with
     Pre =>
       Valid_Length (Val);

   type Checksum is range 0 .. 2**16 - 1 with
     Size =>
       16;

   function Valid_Checksum (Val : RFLX.RFLX_Types.Base_Integer) return Boolean is
     (Val <= 65535);

   function To_Base_Integer (Val : RFLX.UDP.Checksum) return RFLX.RFLX_Types.Base_Integer is
     (RFLX.RFLX_Types.Base_Integer (Val));

   function To_Actual (Val : RFLX.RFLX_Types.Base_Integer) return RFLX.UDP.Checksum is
     (RFLX.UDP.Checksum (Val))
    with
     Pre =>
       Valid_Checksum (Val);

end RFLX.UDP;
