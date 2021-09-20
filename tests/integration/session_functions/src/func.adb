package body Func with
   SPARK_Mode
is

   procedure Get_Message_Type (Result : out RFLX.Universal.Option_Type) is
   begin
      Result := (Known => True, Enum => RFLX.Universal.OT_Data);
   end Get_Message_Type;

   procedure Create_Message
      (Result       : out RFLX.Fixed_Size.Simple_Message.Structure;
       Message_Type : RFLX.Universal.Option_Type;
       Data         : RFLX.RFLX_Types.Bytes)
   is
   begin
      Result.Message_Type := Message_Type;
      if Result.Data'Length = Data'Length then
         Result.Data := Data;
      else
         Result.Data := (others => 0);
      end if;
   end Create_Message;

end Func;
