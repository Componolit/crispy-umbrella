------------------------------------------------------------------------------
--                                                                          --
--                         Generated by RecordFlux                          --
--                                                                          --
--                          Copyright (C) AdaCore                           --
--                                                                          --
--         SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception          --
--                                                                          --
------------------------------------------------------------------------------

pragma Restrictions (No_Streams);
pragma Ada_2012;
pragma Style_Checks ("N3aAbCdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");
with RFLX.RFLX_Builtin_Types.Conversions;
with RFLX.RFLX_Types.Operators;

package body RFLX.Test.S.FSM
with
  SPARK_Mode
is

   use RFLX.RFLX_Types.Operators;

   use type RFLX.RFLX_Types.Bytes_Ptr;

   use type RFLX.RFLX_Types.Bit_Length;

   pragma Warnings (Off, """*"" is already use-visible through previous use_type_clause");

   pragma Warnings (Off, "use clause for type ""*"" defined at * has no effect");

   use type RFLX.RFLX_Types.Base_Integer;

   pragma Warnings (On, "use clause for type ""*"" defined at * has no effect");

   pragma Warnings (On, """*"" is already use-visible through previous use_type_clause");

   procedure Start (Ctx : in out Context)
   with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      T_0 : Boolean;
      T_1 : Boolean;
      T_2 : Boolean;
      T_3 : Boolean;
      T_4 : Boolean;
      T_5 : Test.Length;
      T_6 : Boolean;
      function Start_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 /= null)
      with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Start_Invariant);
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:28:10
      Test.Message.Verify_Message (Ctx.P.Message_Ctx);
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:31:16
      T_0 := Test.Message.Well_Formed_Message (Ctx.P.Message_Ctx);
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:31:16
      T_1 := T_0;
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:32:20
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not Test.Message.Valid (Ctx.P.Message_Ctx, Test.Message.F_Has_Data) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Start_Invariant);
         goto Finalize_Start;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:32:20
      T_2 := Test.Message.Get_Has_Data (Ctx.P.Message_Ctx);
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:32:20
      T_3 := T_2;
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:31:16
      T_4 := T_1
      and then T_3;
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:33:20
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not Test.Message.Valid (Ctx.P.Message_Ctx, Test.Message.F_Length) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Start_Invariant);
         goto Finalize_Start;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:33:20
      T_5 := Test.Message.Get_Length (Ctx.P.Message_Ctx);
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:33:20
      T_6 := T_5 = 2;
      if
         T_4
         and then T_6
      then
         Ctx.P.Next_State := S_Process;
      else
         Ctx.P.Next_State := S_Final;
      end if;
      pragma Assert (Start_Invariant);
      <<Finalize_Start>>
   end Start;

   procedure Process (Ctx : in out Context)
   with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      Local_Message_Ctx : Test.Message.Context;
      T_7 : RFLX.RFLX_Types.Base_Integer;
      T_8 : Boolean;
      T_9 : Boolean;
      Local_Message_Buffer : RFLX_Types.Bytes_Ptr;
      function Process_Invariant return Boolean is
        (Global_Initialized (Ctx)
         and Test.Message.Has_Buffer (Local_Message_Ctx)
         and Local_Message_Ctx.Buffer_First = RFLX.RFLX_Types.Index'First
         and Local_Message_Ctx.Buffer_Last >= RFLX.RFLX_Types.Index'First + RFLX_Types.Length'(4095)
         and Ctx.P.Slots.Slot_Ptr_2 = null
         and Ctx.P.Slots.Slot_Ptr_1 = null)
      with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      Local_Message_Buffer := Ctx.P.Slots.Slot_Ptr_2;
      pragma Warnings (Off, "unused assignment");
      Ctx.P.Slots.Slot_Ptr_2 := null;
      pragma Warnings (On, "unused assignment");
      Test.Message.Initialize (Local_Message_Ctx, Local_Message_Buffer);
      pragma Assert (Process_Invariant);
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:42:10
      if not Test.Message.Valid_Next (Ctx.P.Message_Ctx, Test.Message.F_Has_Data) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      if not Test.Message.Sufficient_Space (Ctx.P.Message_Ctx, Test.Message.F_Has_Data) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      if not RFLX.Test.Message.Field_Condition (Ctx.P.Message_Ctx, RFLX.Test.Message.F_Has_Data, RFLX_Builtin_Types.Conversions.To_Base_Integer (Boolean'(Ctx.P.Has_Data)), (1 .. 0 => 0)) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      Test.Message.Set_Has_Data (Ctx.P.Message_Ctx, Boolean'(Ctx.P.Has_Data));
      if not Test.Message.Sufficient_Space (Ctx.P.Message_Ctx, Test.Message.F_Length) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      if not RFLX.Test.Message.Field_Condition (Ctx.P.Message_Ctx, RFLX.Test.Message.F_Length, Test.To_Base_Integer (Test.Length'(Ctx.P.Length)), (1 .. 0 => 0)) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      Test.Message.Set_Length (Ctx.P.Message_Ctx, Test.Length'(Ctx.P.Length));
      if not Test.Message.Valid_Length (Ctx.P.Message_Ctx, Test.Message.F_Data, RFLX_Types.To_Length (1 * RFLX_Types.Byte'Size)) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      if not Test.Message.Sufficient_Space (Ctx.P.Message_Ctx, Test.Message.F_Data) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      if not RFLX.Test.Message.Field_Condition (Ctx.P.Message_Ctx, RFLX.Test.Message.F_Data, 0, (RFLX_Types.Index'First => RFLX_Types.Byte'Val (65)), 8) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      Test.Message.Set_Data (Ctx.P.Message_Ctx, (RFLX_Types.Index'First => RFLX_Types.Byte'Val (65)));
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not Test.Message.Valid_Next (Ctx.P.Message_Ctx, Test.Message.F_Data) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not (RFLX.RFLX_Types.Base_Integer (RFLX.RFLX_Types.Base_Integer'First) <= RFLX.RFLX_Types.Base_Integer (Test.Message.Field_Size (Ctx.P.Message_Ctx, Test.Message.F_Data))) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not (RFLX.RFLX_Types.Base_Integer (Test.Message.Field_Size (Ctx.P.Message_Ctx, Test.Message.F_Data)) <= RFLX.RFLX_Types.Base_Integer (RFLX.RFLX_Types.Base_Integer'Last)) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:46:34
      T_7 := RFLX.RFLX_Types.Base_Integer (Test.Message.Field_Size (Ctx.P.Message_Ctx, Test.Message.F_Data));
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not (RFLX.RFLX_Types.Base_Integer (Test.Length'First) <= RFLX.RFLX_Types.Base_Integer (T_7)) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not (RFLX.RFLX_Types.Base_Integer (T_7) <= RFLX.RFLX_Types.Base_Integer (Test.Length'Last)) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:46:54
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not (8 /= 0) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:47:32
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not Test.Message.Well_Formed (Ctx.P.Message_Ctx, Test.Message.F_Data) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:45:10
      if not Test.Message.Valid_Next (Local_Message_Ctx, Test.Message.F_Has_Data) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      if not Test.Message.Sufficient_Space (Local_Message_Ctx, Test.Message.F_Has_Data) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      if not RFLX.Test.Message.Field_Condition (Local_Message_Ctx, RFLX.Test.Message.F_Has_Data, RFLX_Builtin_Types.Conversions.To_Base_Integer (Boolean'(True)), (1 .. 0 => 0)) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      Test.Message.Set_Has_Data (Local_Message_Ctx, Boolean'(True));
      if not Test.Message.Sufficient_Space (Local_Message_Ctx, Test.Message.F_Length) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      if not RFLX.Test.Message.Field_Condition (Local_Message_Ctx, RFLX.Test.Message.F_Length, Test.To_Base_Integer (Test.Length'(Test.Length (T_7) / 8)), (1 .. 0 => 0)) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      Test.Message.Set_Length (Local_Message_Ctx, Test.Length'(Test.Length (T_7) / 8));
      declare
         pragma Warnings (Off, "is not modified, could be declared constant");
         RFLX_Ctx_P_Message_Ctx_Tmp : Test.Message.Context := Ctx.P.Message_Ctx;
         pragma Warnings (On, "is not modified, could be declared constant");
         function RFLX_Process_Data_Pre (Length : RFLX_Types.Length) return Boolean is
           (Test.Message.Has_Buffer (RFLX_Ctx_P_Message_Ctx_Tmp)
            and then Test.Message.Well_Formed (RFLX_Ctx_P_Message_Ctx_Tmp, Test.Message.F_Data)
            and then Length = RFLX_Types.To_Length (Test.Message.Field_Size (RFLX_Ctx_P_Message_Ctx_Tmp, Test.Message.F_Data)));
         procedure RFLX_Process_Data (Data : out RFLX_Types.Bytes)
         with
           Pre =>
             RFLX_Process_Data_Pre (Data'Length)
         is
         begin
            Test.Message.Get_Data (RFLX_Ctx_P_Message_Ctx_Tmp, Data);
         end RFLX_Process_Data;
         procedure RFLX_Test_Message_Set_Data is new Test.Message.Generic_Set_Data (RFLX_Process_Data, RFLX_Process_Data_Pre);
      begin
         if
            not (Test.Message.Valid_Next (Local_Message_Ctx, Test.Message.F_Data)
             and Test.Message.Available_Space (Local_Message_Ctx, Test.Message.F_Data) >= RFLX_Types.To_Bit_Length (RFLX_Types.To_Length (Test.Message.Field_Size (RFLX_Ctx_P_Message_Ctx_Tmp, Test.Message.F_Data))))
         then
            Ctx.P.Next_State := S_Final;
            Ctx.P.Message_Ctx := RFLX_Ctx_P_Message_Ctx_Tmp;
            pragma Assert (Process_Invariant);
            goto Finalize_Process;
         end if;
         if not Test.Message.Valid_Length (Local_Message_Ctx, Test.Message.F_Data, RFLX_Types.To_Length (Test.Message.Field_Size (RFLX_Ctx_P_Message_Ctx_Tmp, Test.Message.F_Data))) then
            Ctx.P.Next_State := S_Final;
            Ctx.P.Message_Ctx := RFLX_Ctx_P_Message_Ctx_Tmp;
            pragma Assert (Process_Invariant);
            goto Finalize_Process;
         end if;
         RFLX_Test_Message_Set_Data (Local_Message_Ctx, RFLX_Types.To_Length (Test.Message.Field_Size (RFLX_Ctx_P_Message_Ctx_Tmp, Test.Message.F_Data)));
         Ctx.P.Message_Ctx := RFLX_Ctx_P_Message_Ctx_Tmp;
      end;
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:50:16
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not Test.Message.Valid (Ctx.P.Message_Ctx, Test.Message.F_Has_Data) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:50:16
      T_8 := Test.Message.Get_Has_Data (Ctx.P.Message_Ctx);
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:50:35
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not Test.Message.Valid (Local_Message_Ctx, Test.Message.F_Has_Data) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:50:35
      T_9 := Test.Message.Get_Has_Data (Local_Message_Ctx);
      if T_8 = T_9 then
         Ctx.P.Next_State := S_Reply;
      else
         Ctx.P.Next_State := S_Final;
      end if;
      pragma Assert (Process_Invariant);
      <<Finalize_Process>>
      pragma Warnings (Off, """Local_Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      Test.Message.Take_Buffer (Local_Message_Ctx, Local_Message_Buffer);
      pragma Warnings (On, """Local_Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      pragma Assert (Ctx.P.Slots.Slot_Ptr_2 = null);
      pragma Assert (Local_Message_Buffer /= null);
      Ctx.P.Slots.Slot_Ptr_2 := Local_Message_Buffer;
      pragma Assert (Ctx.P.Slots.Slot_Ptr_2 /= null);
      pragma Assert (Global_Initialized (Ctx));
   end Process;

   procedure Reply (Ctx : in out Context)
   with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Reply_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 /= null)
      with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Reply_Invariant);
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:58:10
      -- tests/feature/fsm_setting_of_message_fields/test.rflx:61:16
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not Test.Message.Valid (Ctx.P.Message_Ctx, Test.Message.F_Has_Data) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Reply_Invariant);
         goto Finalize_Reply;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      if Test.Message.Get_Has_Data (Ctx.P.Message_Ctx) then
         Ctx.P.Next_State := S_Final;
      else
         Ctx.P.Next_State := S_Final;
      end if;
      pragma Assert (Reply_Invariant);
      <<Finalize_Reply>>
   end Reply;

   procedure Initialize (Ctx : in out Context) is
      Message_Buffer : RFLX_Types.Bytes_Ptr;
   begin
      Test.S.FSM_Allocator.Initialize (Ctx.P.Slots, Ctx.P.Memory);
      Message_Buffer := Ctx.P.Slots.Slot_Ptr_1;
      pragma Warnings (Off, "unused assignment");
      Ctx.P.Slots.Slot_Ptr_1 := null;
      pragma Warnings (On, "unused assignment");
      Test.Message.Initialize (Ctx.P.Message_Ctx, Message_Buffer);
      Ctx.P.Has_Data := True;
      Ctx.P.Length := 1;
      Ctx.P.Next_State := S_Start;
   end Initialize;

   procedure Finalize (Ctx : in out Context) is
      Message_Buffer : RFLX_Types.Bytes_Ptr;
   begin
      pragma Warnings (Off, """Ctx.P.Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      Test.Message.Take_Buffer (Ctx.P.Message_Ctx, Message_Buffer);
      pragma Warnings (On, """Ctx.P.Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      pragma Assert (Ctx.P.Slots.Slot_Ptr_1 = null);
      pragma Assert (Message_Buffer /= null);
      Ctx.P.Slots.Slot_Ptr_1 := Message_Buffer;
      pragma Assert (Ctx.P.Slots.Slot_Ptr_1 /= null);
      Test.S.FSM_Allocator.Finalize (Ctx.P.Slots);
      Ctx.P.Next_State := S_Final;
   end Finalize;

   procedure Reset_Messages_Before_Write (Ctx : in out Context)
   with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
   begin
      case Ctx.P.Next_State is
         when S_Start =>
            Test.Message.Reset (Ctx.P.Message_Ctx, Ctx.P.Message_Ctx.First, Ctx.P.Message_Ctx.First - 1);
         when S_Process | S_Reply | S_Final =>
            null;
      end case;
   end Reset_Messages_Before_Write;

   procedure Tick (Ctx : in out Context) is
   begin
      case Ctx.P.Next_State is
         when S_Start =>
            Start (Ctx);
         when S_Process =>
            Process (Ctx);
         when S_Reply =>
            Reply (Ctx);
         when S_Final =>
            null;
      end case;
      Reset_Messages_Before_Write (Ctx);
   end Tick;

   function In_IO_State (Ctx : Context) return Boolean is
     (Ctx.P.Next_State in S_Start | S_Reply);

   procedure Run (Ctx : in out Context) is
   begin
      Tick (Ctx);
      while
         Active (Ctx)
         and not In_IO_State (Ctx)
      loop
         pragma Loop_Invariant (Initialized (Ctx));
         Tick (Ctx);
      end loop;
   end Run;

   procedure Read (Ctx : Context; Chan : Channel; Buffer : out RFLX_Types.Bytes; Offset : RFLX_Types.Length := 0) is
      function Read_Pre (Message_Buffer : RFLX_Types.Bytes) return Boolean is
        (Buffer'Length > 0
         and then Offset < Message_Buffer'Length);
      procedure Read (Message_Buffer : RFLX_Types.Bytes)
      with
        Pre =>
          Read_Pre (Message_Buffer)
      is
         Length : constant RFLX_Types.Length := RFLX_Types.Length'Min (Buffer'Length, Message_Buffer'Length - Offset);
         Buffer_Last : constant RFLX_Types.Index := Buffer'First + (Length - RFLX_Types.Length'(1));
      begin
         Buffer (Buffer'First .. RFLX_Types.Index (Buffer_Last)) := Message_Buffer (RFLX_Types.Index (RFLX_Types.Length (Message_Buffer'First) + Offset) .. Message_Buffer'First + Offset + (Length - RFLX_Types.Length'(1)));
      end Read;
      procedure Test_Message_Read is new Test.Message.Generic_Read (Read, Read_Pre);
   begin
      Buffer := (others => 0);
      case Chan is
         when C_Channel =>
            case Ctx.P.Next_State is
               when S_Reply =>
                  Test_Message_Read (Ctx.P.Message_Ctx);
               when others =>
                  pragma Warnings (Off, "unreachable code");
                  null;
                  pragma Warnings (On, "unreachable code");
            end case;
      end case;
   end Read;

   procedure Write (Ctx : in out Context; Chan : Channel; Buffer : RFLX_Types.Bytes; Offset : RFLX_Types.Length := 0) is
      Write_Buffer_Length : constant RFLX_Types.Length := Write_Buffer_Size (Ctx, Chan);
      function Write_Pre (Context_Buffer_Length : RFLX_Types.Length; Offset : RFLX_Types.Length) return Boolean is
        (Buffer'Length > 0
         and then Context_Buffer_Length = Write_Buffer_Length
         and then Offset <= RFLX_Types.Length'Last - Buffer'Length
         and then Buffer'Length + Offset <= Write_Buffer_Length);
      procedure Write (Message_Buffer : out RFLX_Types.Bytes; Length : out RFLX_Types.Length; Context_Buffer_Length : RFLX_Types.Length; Offset : RFLX_Types.Length)
      with
        Pre =>
          Write_Pre (Context_Buffer_Length, Offset)
          and then Offset <= RFLX_Types.Length'Last - Message_Buffer'Length
          and then Message_Buffer'Length + Offset = Write_Buffer_Length,
        Post =>
          Length <= Message_Buffer'Length
      is
      begin
         Length := Buffer'Length;
         Message_Buffer := (others => 0);
         Message_Buffer (Message_Buffer'First .. RFLX_Types.Index (RFLX_Types.Length (Message_Buffer'First) - 1 + Length)) := Buffer;
      end Write;
      procedure Test_Message_Write is new Test.Message.Generic_Write (Write, Write_Pre);
   begin
      case Chan is
         when C_Channel =>
            case Ctx.P.Next_State is
               when S_Start =>
                  Test_Message_Write (Ctx.P.Message_Ctx, Offset);
               when others =>
                  pragma Warnings (Off, "unreachable code");
                  null;
                  pragma Warnings (On, "unreachable code");
            end case;
      end case;
   end Write;

end RFLX.Test.S.FSM;
