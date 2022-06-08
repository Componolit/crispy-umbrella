pragma Style_Checks ("N3aAbcdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");
with RFLX.RFLX_Types;

package RFLX.Universal with
  SPARK_Mode
is

   type Option_Type_Enum is (OT_Null, OT_Data) with
     Size =>
       8;
   for Option_Type_Enum use (OT_Null => 0, OT_Data => 1);

   type Option_Type (Known : Boolean := False) is
      record
         case Known is
            when True =>
               Enum : Option_Type_Enum;
            when False =>
               Raw : RFLX_Types.Base_Integer;
         end case;
      end record;

   use type RFLX.RFLX_Types.Base_Integer;

   function Valid_Option_Type (Val : RFLX.RFLX_Types.Base_Integer) return Boolean is
     (Val < 2**8);

   function Valid_Option_Type (Val : Option_Type) return Boolean is
     ((if Val.Known then True else Valid_Option_Type (Val.Raw) and Val.Raw not in 0 | 1));

   function To_Base_Int (Enum : RFLX.Universal.Option_Type_Enum) return RFLX.RFLX_Types.Base_Integer is
     ((case Enum is
          when OT_Null =>
             0,
          when OT_Data =>
             1));

   function To_Actual (Enum : Option_Type_Enum) return RFLX.Universal.Option_Type is
     ((True, Enum));

   function To_Actual (Val : RFLX.RFLX_Types.Base_Integer) return RFLX.Universal.Option_Type is
     ((case Val is
          when 0 =>
             (True, OT_Null),
          when 1 =>
             (True, OT_Data),
          when others =>
             (False, Val)))
    with
     Pre =>
       Valid_Option_Type (Val);

   function To_Base_Int (Val : RFLX.Universal.Option_Type) return RFLX.RFLX_Types.Base_Integer is
     ((if Val.Known then To_Base_Int (Val.Enum) else Val.Raw));

end RFLX.Universal;
