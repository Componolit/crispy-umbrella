pragma Style_Checks ("N3aAbcdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");
with RFLX.Universal;
with RFLX.Universal.Option;
with RFLX.Universal.Contains;
use type RFLX.Universal.Message_Type;

package body RFLX.Test.Session with
  SPARK_Mode
is

   procedure Start (State : out Session_State) with
     Pre =>
       Initialized,
     Post =>
       Initialized
   is
   begin
      declare
         procedure Universal_Message_Write is new Universal.Message.Write (Channel_Read);
      begin
         Universal_Message_Write (Message_Ctx);
      end;
      Universal.Message.Verify_Message (Message_Ctx);
      if
        Universal.Message.Structural_Valid_Message (Message_Ctx)
        and then Universal.Message.Get_Message_Type (Message_Ctx) = Universal.MT_Data
      then
         State := S_Reply;
      else
         State := S_Terminated;
      end if;
   end Start;

   procedure Reply (State : out Session_State) with
     Pre =>
       Initialized,
     Post =>
       Initialized
   is
      Inner_Message_Ctx : Universal.Option.Context;
      Inner_Message_Buffer : RFLX_Types.Bytes_Ptr;
   begin
      Inner_Message_Buffer := new RFLX_Types.Bytes'(RFLX_Types.Index'First .. RFLX_Types.Index'First + 4095 => RFLX_Types.Byte'First);
      Universal.Option.Initialize (Inner_Message_Ctx, Inner_Message_Buffer);
      if Universal.Contains.Option_In_Message_Data (Message_Ctx) then
         Universal.Contains.Copy_Data (Message_Ctx, Inner_Message_Ctx);
         Universal.Option.Verify_Message (Inner_Message_Ctx);
      else
         State := S_Terminated;
         pragma Warnings (Off, "unused assignment to ""Inner_Message_Ctx""");
         pragma Warnings (Off, """Inner_Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
         Universal.Option.Take_Buffer (Inner_Message_Ctx, Inner_Message_Buffer);
         pragma Warnings (On, """Inner_Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
         pragma Warnings (On, "unused assignment to ""Inner_Message_Ctx""");
         RFLX_Types.Free (Inner_Message_Buffer);
         return;
      end if;
      if Universal.Option.Structural_Valid_Message (Inner_Message_Ctx) then
         declare
            procedure Universal_Option_Read is new Universal.Option.Read (Channel_Write);
         begin
            Universal_Option_Read (Inner_Message_Ctx);
         end;
      else
         State := S_Terminated;
         pragma Warnings (Off, "unused assignment to ""Inner_Message_Ctx""");
         pragma Warnings (Off, """Inner_Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
         Universal.Option.Take_Buffer (Inner_Message_Ctx, Inner_Message_Buffer);
         pragma Warnings (On, """Inner_Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
         pragma Warnings (On, "unused assignment to ""Inner_Message_Ctx""");
         RFLX_Types.Free (Inner_Message_Buffer);
         return;
      end if;
      State := S_Terminated;
      pragma Warnings (Off, "unused assignment to ""Inner_Message_Ctx""");
      pragma Warnings (Off, """Inner_Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      Universal.Option.Take_Buffer (Inner_Message_Ctx, Inner_Message_Buffer);
      pragma Warnings (On, """Inner_Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      pragma Warnings (On, "unused assignment to ""Inner_Message_Ctx""");
      RFLX_Types.Free (Inner_Message_Buffer);
   end Reply;

   procedure Initialize is
      Message_Buffer : RFLX_Types.Bytes_Ptr;
   begin
      if Universal.Message.Has_Buffer (Message_Ctx) then
         pragma Warnings (Off, "unused assignment to ""Message_Ctx""");
         pragma Warnings (Off, """Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
         Universal.Message.Take_Buffer (Message_Ctx, Message_Buffer);
         pragma Warnings (On, """Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
         pragma Warnings (On, "unused assignment to ""Message_Ctx""");
         RFLX_Types.Free (Message_Buffer);
      end if;
      Message_Buffer := new RFLX_Types.Bytes'(RFLX_Types.Index'First .. RFLX_Types.Index'First + 4095 => RFLX_Types.Byte'First);
      Universal.Message.Initialize (Message_Ctx, Message_Buffer);
      State := S_Start;
   end Initialize;

   procedure Finalize is
      Message_Buffer : RFLX_Types.Bytes_Ptr;
   begin
      pragma Warnings (Off, "unused assignment to ""Message_Ctx""");
      pragma Warnings (Off, """Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      Universal.Message.Take_Buffer (Message_Ctx, Message_Buffer);
      pragma Warnings (On, """Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      pragma Warnings (On, "unused assignment to ""Message_Ctx""");
      RFLX_Types.Free (Message_Buffer);
      State := S_Terminated;
   end Finalize;

   procedure Tick is
   begin
      case State is
         when S_Start =>
            Start (State);
         when S_Reply =>
            Reply (State);
         when S_Terminated =>
            null;
      end case;
   end Tick;

   procedure Run is
   begin
      Initialize;
      while Active loop
         pragma Loop_Invariant (Initialized);
         Tick;
      end loop;
      Finalize;
   end Run;

end RFLX.Test.Session;
