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
with RFLX.RFLX_Types.Operators;

package body RFLX.Test.S.FSM
with
  SPARK_Mode
is

   use RFLX.RFLX_Types.Operators;

   use type RFLX.RFLX_Types.Bytes_Ptr;

   use type RFLX.Universal.Message_Type;

   use type RFLX.Universal.Length;

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
      T_1 : Universal.Message_Type;
      T_2 : Boolean;
      T_3 : Boolean;
      T_4 : Universal.Length;
      T_5 : Boolean;
      function Start_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
      with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Start_Invariant);
      -- tests/feature/fsm_functions/test.rflx:40:10
      Universal.Message.Verify_Message (Ctx.P.Message_Ctx);
      -- tests/feature/fsm_functions/test.rflx:43:16
      T_0 := Universal.Message.Well_Formed_Message (Ctx.P.Message_Ctx);
      -- tests/feature/fsm_functions/test.rflx:44:20
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not Universal.Message.Valid (Ctx.P.Message_Ctx, Universal.Message.F_Message_Type) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Start_Invariant);
         goto Finalize_Start;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_functions/test.rflx:44:20
      T_1 := Universal.Message.Get_Message_Type (Ctx.P.Message_Ctx);
      -- tests/feature/fsm_functions/test.rflx:44:20
      T_2 := T_1 = Universal.MT_Data;
      -- tests/feature/fsm_functions/test.rflx:43:16
      T_3 := T_0
      and then T_2;
      -- tests/feature/fsm_functions/test.rflx:45:20
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not Universal.Message.Valid (Ctx.P.Message_Ctx, Universal.Message.F_Length) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Start_Invariant);
         goto Finalize_Start;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_functions/test.rflx:45:20
      T_4 := Universal.Message.Get_Length (Ctx.P.Message_Ctx);
      -- tests/feature/fsm_functions/test.rflx:45:20
      T_5 := T_4 = 3;
      if
         T_3
         and then T_5
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
      Valid : Test.Result;
      Message_Type : Universal.Option_Type;
      Length : Test.Length;
      T_6 : RFLX.RFLX_Types.Base_Integer;
      T_7 : Test.Length;
      function Process_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
      with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Process_Invariant);
      -- tests/feature/fsm_functions/test.rflx:56:10
      Get_Message_Type (Ctx.E, Message_Type);
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not Universal.Message.Valid_Next (Ctx.P.Message_Ctx, Universal.Message.F_Data) then
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
      if not (RFLX.RFLX_Types.Base_Integer (RFLX.RFLX_Types.Base_Integer'First) <= RFLX.RFLX_Types.Base_Integer (Universal.Message.Field_Size (Ctx.P.Message_Ctx, Universal.Message.F_Data))) then
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
      if not (RFLX.RFLX_Types.Base_Integer (Universal.Message.Field_Size (Ctx.P.Message_Ctx, Universal.Message.F_Data)) <= RFLX.RFLX_Types.Base_Integer (RFLX.RFLX_Types.Base_Integer'Last)) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_functions/test.rflx:57:20
      T_6 := RFLX.RFLX_Types.Base_Integer (Universal.Message.Field_Size (Ctx.P.Message_Ctx, Universal.Message.F_Data));
      -- tests/feature/fsm_functions/test.rflx:57:40
      Byte_Size (Ctx.E, T_7);
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not (RFLX.RFLX_Types.Base_Integer (Test.Length'First) <= RFLX.RFLX_Types.Base_Integer (T_6)) then
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
      if not (RFLX.RFLX_Types.Base_Integer (T_6) <= RFLX.RFLX_Types.Base_Integer (Test.Length'Last)) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_functions/test.rflx:57:40
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not (T_7 /= 0) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_functions/test.rflx:57:10
      Length := Test.Length (T_6) / T_7;
      -- tests/feature/fsm_functions/test.rflx:58:68
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not Universal.Message.Well_Formed (Ctx.P.Message_Ctx, Universal.Message.F_Data) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_Invariant);
         goto Finalize_Process;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_functions/test.rflx:58:10
      declare
         Definite_Message : Test.Definite_Message.Structure;
         RFLX_Create_Message_Arg_2_Message : RFLX_Types.Bytes (RFLX_Types.Index'First .. RFLX_Types.Index'First + RFLX_Types.Length'(4095)) := (others => 0);
         RFLX_Create_Message_Arg_2_Message_Length : constant RFLX_Types.Length := RFLX_Types.To_Length (Universal.Message.Field_Size (Ctx.P.Message_Ctx, Universal.Message.F_Data));
      begin
         if not (RFLX_Create_Message_Arg_2_Message'Length >= RFLX_Create_Message_Arg_2_Message_Length) then
            Ctx.P.Next_State := S_Final;
            pragma Assert (Process_Invariant);
            goto Finalize_Process;
         end if;
         Universal.Message.Get_Data (Ctx.P.Message_Ctx, RFLX_Create_Message_Arg_2_Message (RFLX_Types.Index'First .. (if
             RFLX_Create_Message_Arg_2_Message_Length > 0
          then
             RFLX_Types.Index'First + RFLX_Create_Message_Arg_2_Message_Length - RFLX_Types.Length'(1)
          else
             (-1))));
         Create_Message (Ctx.E, Message_Type, Length, RFLX_Create_Message_Arg_2_Message (RFLX_Types.Index'First .. (if
             RFLX_Create_Message_Arg_2_Message_Length > 0
          then
             RFLX_Types.Index'First + RFLX_Create_Message_Arg_2_Message_Length - RFLX_Types.Length'(1)
          else
             (-1))), Definite_Message);
         if not Test.Definite_Message.Valid_Structure (Definite_Message) then
            Ctx.P.Next_State := S_Final;
            pragma Assert (Process_Invariant);
            goto Finalize_Process;
         end if;
         if not Test.Definite_Message.Sufficient_Buffer_Length (Ctx.P.Definite_Message_Ctx, Definite_Message) then
            Ctx.P.Next_State := S_Final;
            pragma Assert (Process_Invariant);
            goto Finalize_Process;
         end if;
         Test.Definite_Message.To_Context (Definite_Message, Ctx.P.Definite_Message_Ctx);
      end;
      -- tests/feature/fsm_functions/test.rflx:59:10
      declare
         Definite_Message : Test.Definite_Message.Structure;
      begin
         Test.Definite_Message.To_Structure (Ctx.P.Definite_Message_Ctx, Definite_Message);
         Valid_Message (Ctx.E, Definite_Message, True, Valid);
      end;
      if Valid = M_Valid then
         Ctx.P.Next_State := S_Reply;
      else
         Ctx.P.Next_State := S_Final;
      end if;
      pragma Assert (Process_Invariant);
      <<Finalize_Process>>
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
         and Ctx.P.Slots.Slot_Ptr_2 = null)
      with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Reply_Invariant);
      -- tests/feature/fsm_functions/test.rflx:70:10
      Ctx.P.Next_State := S_Process_2;
      pragma Assert (Reply_Invariant);
   end Reply;

   procedure Process_2 (Ctx : in out Context)
   with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      Length : Test.Length;
      T_8 : RFLX.RFLX_Types.Base_Integer;
      function Process_2_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
      with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Process_2_Invariant);
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not (RFLX.RFLX_Types.Base_Integer (RFLX.RFLX_Types.Base_Integer'First) <= RFLX.RFLX_Types.Base_Integer (Universal.Message.Size (Ctx.P.Message_Ctx))) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_2_Invariant);
         goto Finalize_Process_2;
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
      if not (RFLX.RFLX_Types.Base_Integer (Universal.Message.Size (Ctx.P.Message_Ctx)) <= RFLX.RFLX_Types.Base_Integer (RFLX.RFLX_Types.Base_Integer'Last)) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_2_Invariant);
         goto Finalize_Process_2;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_functions/test.rflx:78:20
      T_8 := RFLX.RFLX_Types.Base_Integer (Universal.Message.Size (Ctx.P.Message_Ctx));
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not (RFLX.RFLX_Types.Base_Integer (Test.Length'First) <= RFLX.RFLX_Types.Base_Integer (T_8)) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_2_Invariant);
         goto Finalize_Process_2;
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
      if not (RFLX.RFLX_Types.Base_Integer (T_8) <= RFLX.RFLX_Types.Base_Integer (Test.Length'Last)) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_2_Invariant);
         goto Finalize_Process_2;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_functions/test.rflx:78:35
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not (8 /= 0) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_2_Invariant);
         goto Finalize_Process_2;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_functions/test.rflx:78:10
      Length := Test.Length (T_8) / 8;
      pragma Warnings (Off, "condition can only be False if invalid values present");
      pragma Warnings (Off, "condition is always False");
      pragma Warnings (Off, "this code can never be executed and has been deleted");
      pragma Warnings (Off, "statement has no effect");
      pragma Warnings (Off, "this statement is never reached");
      if not Universal.Message.Well_Formed_Message (Ctx.P.Message_Ctx) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_2_Invariant);
         goto Finalize_Process_2;
      end if;
      pragma Warnings (On, "this statement is never reached");
      pragma Warnings (On, "statement has no effect");
      pragma Warnings (On, "this code can never be executed and has been deleted");
      pragma Warnings (On, "condition is always False");
      pragma Warnings (On, "condition can only be False if invalid values present");
      -- tests/feature/fsm_functions/test.rflx:79:10
      declare
         Definite_Message : Test.Definite_Message.Structure;
         RFLX_Create_Message_Arg_2_Message : RFLX_Types.Bytes (RFLX_Types.Index'First .. RFLX_Types.Index'First + RFLX_Types.Length'(4095)) := (others => 0);
         RFLX_Create_Message_Arg_2_Message_Length : constant RFLX_Types.Length := Universal.Message.Byte_Size (Ctx.P.Message_Ctx);
      begin
         if not (RFLX_Create_Message_Arg_2_Message'Length >= RFLX_Create_Message_Arg_2_Message_Length) then
            Ctx.P.Next_State := S_Final;
            pragma Assert (Process_2_Invariant);
            goto Finalize_Process_2;
         end if;
         if not Universal.Message.Well_Formed_Message (Ctx.P.Message_Ctx) then
            Ctx.P.Next_State := S_Final;
            pragma Assert (Process_2_Invariant);
            goto Finalize_Process_2;
         end if;
         Universal.Message.Data (Ctx.P.Message_Ctx, RFLX_Create_Message_Arg_2_Message (RFLX_Types.Index'First .. (if
             RFLX_Create_Message_Arg_2_Message_Length > 0
          then
             RFLX_Types.Index'First + RFLX_Create_Message_Arg_2_Message_Length - RFLX_Types.Length'(1)
          else
             (-1))));
         Create_Message (Ctx.E, (Known => True, Enum => Universal.OT_Data), Length, RFLX_Create_Message_Arg_2_Message (RFLX_Types.Index'First .. (if
             RFLX_Create_Message_Arg_2_Message_Length > 0
          then
             RFLX_Types.Index'First + RFLX_Create_Message_Arg_2_Message_Length - RFLX_Types.Length'(1)
          else
             (-1))), Definite_Message);
         if not Test.Definite_Message.Valid_Structure (Definite_Message) then
            Ctx.P.Next_State := S_Final;
            pragma Assert (Process_2_Invariant);
            goto Finalize_Process_2;
         end if;
         if not Test.Definite_Message.Sufficient_Buffer_Length (Ctx.P.Definite_Message_Ctx, Definite_Message) then
            Ctx.P.Next_State := S_Final;
            pragma Assert (Process_2_Invariant);
            goto Finalize_Process_2;
         end if;
         Test.Definite_Message.To_Context (Definite_Message, Ctx.P.Definite_Message_Ctx);
      end;
      Ctx.P.Next_State := S_Reply_2;
      pragma Assert (Process_2_Invariant);
      <<Finalize_Process_2>>
   end Process_2;

   procedure Reply_2 (Ctx : in out Context)
   with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Reply_2_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
      with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Reply_2_Invariant);
      -- tests/feature/fsm_functions/test.rflx:88:10
      Ctx.P.Next_State := S_Process_3;
      pragma Assert (Reply_2_Invariant);
   end Reply_2;

   procedure Process_3 (Ctx : in out Context)
   with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      Local_Message : Test.Definite_Message.Structure;
      function Process_3_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
      with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Process_3_Invariant);
      -- tests/feature/fsm_functions/test.rflx:96:10
      Create_Message (Ctx.E, (Known => True, Enum => Universal.OT_Data), 2, (RFLX_Types.Byte'Val (3), RFLX_Types.Byte'Val (4)), Local_Message);
      if not Test.Definite_Message.Valid_Structure (Local_Message) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_3_Invariant);
         goto Finalize_Process_3;
      end if;
      -- tests/feature/fsm_functions/test.rflx:97:10
      if not Test.Definite_Message.Valid_Next (Ctx.P.Definite_Message_Ctx, Test.Definite_Message.F_Length) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_3_Invariant);
         goto Finalize_Process_3;
      end if;
      if not Test.Definite_Message.Sufficient_Space (Ctx.P.Definite_Message_Ctx, Test.Definite_Message.F_Length) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_3_Invariant);
         goto Finalize_Process_3;
      end if;
      if not RFLX.Test.Definite_Message.Field_Condition (Ctx.P.Definite_Message_Ctx, RFLX.Test.Definite_Message.F_Length) then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Process_3_Invariant);
         goto Finalize_Process_3;
      end if;
      Test.Definite_Message.Set_Length (Ctx.P.Definite_Message_Ctx, Test.Length'(Local_Message.Length));
      declare
         function RFLX_Process_Data_Pre (Length : RFLX_Types.Length) return Boolean is
           (Test.Definite_Message.Valid_Structure (Local_Message)
            and then Length = RFLX_Types.To_Length (Test.Definite_Message.Field_Size_Data (Local_Message)));
         procedure RFLX_Process_Data (Data : out RFLX_Types.Bytes)
         with
           Pre =>
             RFLX_Process_Data_Pre (Data'Length)
         is
         begin
            if Data'Length > 0 then
               Data := Local_Message.Data (Local_Message.Data'First .. Local_Message.Data'First + RFLX_Types.Length'(Data'Length) - RFLX_Types.Length'(1));
            else
               Data := (others => 0);
            end if;
         end RFLX_Process_Data;
         procedure RFLX_Test_Definite_Message_Set_Data is new Test.Definite_Message.Generic_Set_Data (RFLX_Process_Data, RFLX_Process_Data_Pre);
      begin
         if
            not (Test.Definite_Message.Valid_Next (Ctx.P.Definite_Message_Ctx, Test.Definite_Message.F_Data)
             and Test.Definite_Message.Available_Space (Ctx.P.Definite_Message_Ctx, Test.Definite_Message.F_Data) >= RFLX_Types.To_Bit_Length (RFLX_Types.To_Length (Test.Definite_Message.Field_Size_Data (Local_Message))))
         then
            Ctx.P.Next_State := S_Final;
            pragma Assert (Process_3_Invariant);
            goto Finalize_Process_3;
         end if;
         if not Test.Definite_Message.Valid_Length (Ctx.P.Definite_Message_Ctx, Test.Definite_Message.F_Data, RFLX_Types.To_Length (Test.Definite_Message.Field_Size_Data (Local_Message))) then
            Ctx.P.Next_State := S_Final;
            pragma Assert (Process_3_Invariant);
            goto Finalize_Process_3;
         end if;
         RFLX_Test_Definite_Message_Set_Data (Ctx.P.Definite_Message_Ctx, RFLX_Types.To_Length (Test.Definite_Message.Field_Size_Data (Local_Message)));
      end;
      Ctx.P.Next_State := S_Reply_3;
      pragma Assert (Process_3_Invariant);
      <<Finalize_Process_3>>
   end Process_3;

   procedure Reply_3 (Ctx : in out Context)
   with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Reply_3_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
      with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Reply_3_Invariant);
      -- tests/feature/fsm_functions/test.rflx:107:10
      Ctx.P.Next_State := S_Final;
      pragma Assert (Reply_3_Invariant);
   end Reply_3;

   procedure Initialize (Ctx : in out Context) is
      Message_Buffer : RFLX_Types.Bytes_Ptr;
      Definite_Message_Buffer : RFLX_Types.Bytes_Ptr;
   begin
      Test.S.FSM_Allocator.Initialize (Ctx.P.Slots, Ctx.P.Memory);
      Message_Buffer := Ctx.P.Slots.Slot_Ptr_1;
      pragma Warnings (Off, "unused assignment");
      Ctx.P.Slots.Slot_Ptr_1 := null;
      pragma Warnings (On, "unused assignment");
      Universal.Message.Initialize (Ctx.P.Message_Ctx, Message_Buffer);
      Definite_Message_Buffer := Ctx.P.Slots.Slot_Ptr_2;
      pragma Warnings (Off, "unused assignment");
      Ctx.P.Slots.Slot_Ptr_2 := null;
      pragma Warnings (On, "unused assignment");
      Test.Definite_Message.Initialize (Ctx.P.Definite_Message_Ctx, Definite_Message_Buffer);
      Ctx.P.Next_State := S_Start;
   end Initialize;

   procedure Finalize (Ctx : in out Context) is
      Message_Buffer : RFLX_Types.Bytes_Ptr;
      Definite_Message_Buffer : RFLX_Types.Bytes_Ptr;
   begin
      pragma Warnings (Off, """Ctx.P.Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      Universal.Message.Take_Buffer (Ctx.P.Message_Ctx, Message_Buffer);
      pragma Warnings (On, """Ctx.P.Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      pragma Assert (Ctx.P.Slots.Slot_Ptr_1 = null);
      pragma Assert (Message_Buffer /= null);
      Ctx.P.Slots.Slot_Ptr_1 := Message_Buffer;
      pragma Assert (Ctx.P.Slots.Slot_Ptr_1 /= null);
      pragma Warnings (Off, """Ctx.P.Definite_Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      Test.Definite_Message.Take_Buffer (Ctx.P.Definite_Message_Ctx, Definite_Message_Buffer);
      pragma Warnings (On, """Ctx.P.Definite_Message_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      pragma Assert (Ctx.P.Slots.Slot_Ptr_2 = null);
      pragma Assert (Definite_Message_Buffer /= null);
      Ctx.P.Slots.Slot_Ptr_2 := Definite_Message_Buffer;
      pragma Assert (Ctx.P.Slots.Slot_Ptr_2 /= null);
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
            Universal.Message.Reset (Ctx.P.Message_Ctx, Ctx.P.Message_Ctx.First, Ctx.P.Message_Ctx.First - 1);
         when S_Process | S_Reply | S_Process_2 | S_Reply_2 | S_Process_3 | S_Reply_3 | S_Final =>
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
         when S_Process_2 =>
            Process_2 (Ctx);
         when S_Reply_2 =>
            Reply_2 (Ctx);
         when S_Process_3 =>
            Process_3 (Ctx);
         when S_Reply_3 =>
            Reply_3 (Ctx);
         when S_Final =>
            null;
      end case;
      Reset_Messages_Before_Write (Ctx);
   end Tick;

   function In_IO_State (Ctx : Context) return Boolean is
     (Ctx.P.Next_State in S_Start | S_Reply | S_Reply_2 | S_Reply_3);

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
      procedure Test_Definite_Message_Read is new Test.Definite_Message.Generic_Read (Read, Read_Pre);
   begin
      Buffer := (others => 0);
      case Chan is
         when C_Channel =>
            case Ctx.P.Next_State is
               when S_Reply | S_Reply_2 | S_Reply_3 =>
                  Test_Definite_Message_Read (Ctx.P.Definite_Message_Ctx);
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
      procedure Universal_Message_Write is new Universal.Message.Generic_Write (Write, Write_Pre);
   begin
      case Chan is
         when C_Channel =>
            case Ctx.P.Next_State is
               when S_Start =>
                  Universal_Message_Write (Ctx.P.Message_Ctx, Offset);
               when others =>
                  pragma Warnings (Off, "unreachable code");
                  null;
                  pragma Warnings (On, "unreachable code");
            end case;
      end case;
   end Write;

end RFLX.Test.S.FSM;
