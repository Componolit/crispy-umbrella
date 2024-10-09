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
with RFLX.Test.S.FSM_Allocator;
with RFLX.RFLX_Types;
with RFLX.Universal;
with RFLX.Universal.Message;

package RFLX.Test.S.FSM with
  SPARK_Mode
is

   use type RFLX.RFLX_Types.Index;

   use type RFLX.RFLX_Types.Length;

   type Channel is (C_Channel);

   type State is (S_Start, S_Process, S_Reply, S_Final);

   type Private_Context is private;

   type Context is limited
      record
         P : Private_Context;
      end record;

   pragma Unevaluated_Use_Of_Old (Allow);

   function Uninitialized (Ctx : Context) return Boolean;

   function Global_Initialized (Ctx : Context) return Boolean;

   function Global_Allocated (Ctx : Context) return Boolean;

   function Initialized (Ctx : Context) return Boolean;

   function Active (Ctx : Context) return Boolean;

   procedure Initialize (Ctx : in out Context) with
     Pre =>
       Uninitialized (Ctx),
     Post =>
       Initialized (Ctx)
       and Active (Ctx);

   procedure Finalize (Ctx : in out Context) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Uninitialized (Ctx)
       and not Active (Ctx);

   pragma Warnings (Off, "subprogram ""Tick"" has no effect");

   procedure Tick (Ctx : in out Context) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx);

   pragma Warnings (On, "subprogram ""Tick"" has no effect");

   function In_IO_State (Ctx : Context) return Boolean;

   pragma Warnings (Off, "subprogram ""Run"" has no effect");

   procedure Run (Ctx : in out Context) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx);

   pragma Warnings (On, "subprogram ""Run"" has no effect");

   function Next_State (Ctx : Context) return State;

   function Has_Data (Ctx : Context; Chan : Channel) return Boolean with
     Pre =>
       Initialized (Ctx);

   function Read_Buffer_Size (Ctx : Context; Chan : Channel) return RFLX_Types.Length with
     Pre =>
       Initialized (Ctx)
       and then Has_Data (Ctx, Chan);

   procedure Read (Ctx : Context; Chan : Channel; Buffer : out RFLX_Types.Bytes; Offset : RFLX_Types.Length := 0) with
     Pre =>
       Initialized (Ctx)
       and then Has_Data (Ctx, Chan)
       and then Buffer'Length > 0
       and then Offset <= RFLX_Types.Length'Last - Buffer'Length
       and then Buffer'Length + Offset <= Read_Buffer_Size (Ctx, Chan),
     Post =>
       Initialized (Ctx)
       and then Next_State (Ctx) = Next_State (Ctx)'Old;

   function Needs_Data (Ctx : Context; Chan : Channel) return Boolean with
     Pre =>
       Initialized (Ctx);

   function Write_Buffer_Size (Ctx : Context; Chan : Channel) return RFLX_Types.Length with
     Pre =>
       Initialized (Ctx)
       and then Needs_Data (Ctx, Chan);

   procedure Write (Ctx : in out Context; Chan : Channel; Buffer : RFLX_Types.Bytes; Offset : RFLX_Types.Length := 0) with
     Pre =>
       Initialized (Ctx)
       and then Needs_Data (Ctx, Chan)
       and then Buffer'Length > 0
       and then Offset <= RFLX_Types.Length'Last - Buffer'Length
       and then Buffer'Length + Offset <= Write_Buffer_Size (Ctx, Chan),
     Post =>
       Initialized (Ctx)
       and then Next_State (Ctx) = Next_State (Ctx)'Old;

private

   type Private_Context is
      record
         Next_State : State := S_Start;
         Global : Universal.Value := 11;
         Uninitialized_Global : Universal.Value := Universal.Value'First;
         Message_Ctx : Universal.Message.Context;
         Slots : Test.S.FSM_Allocator.Slots;
         Memory : Test.S.FSM_Allocator.Memory;
      end record;

   function Uninitialized (Ctx : Context) return Boolean is
     (not Universal.Message.Has_Buffer (Ctx.P.Message_Ctx)
      and Test.S.FSM_Allocator.Uninitialized (Ctx.P.Slots));

   function Global_Initialized (Ctx : Context) return Boolean is
     (Universal.Message.Has_Buffer (Ctx.P.Message_Ctx)
      and then Ctx.P.Message_Ctx.Buffer_First = RFLX_Types.Index'First
      and then Ctx.P.Message_Ctx.Buffer_Last = RFLX_Types.Index'First + 4095);

   function Global_Allocated (Ctx : Context) return Boolean is
     (Test.S.FSM_Allocator.Global_Allocated (Ctx.P.Slots));

   function Initialized (Ctx : Context) return Boolean is
     (Global_Initialized (Ctx)
      and then Global_Allocated (Ctx));

   function Active (Ctx : Context) return Boolean is
     (Ctx.P.Next_State /= S_Final);

   function Next_State (Ctx : Context) return State is
     (Ctx.P.Next_State);

   function Has_Data (Ctx : Context; Chan : Channel) return Boolean is
     (case Chan is
          when C_Channel =>
             (case Ctx.P.Next_State is
                 when S_Reply =>
                    Universal.Message.Well_Formed_Message (Ctx.P.Message_Ctx)
                    and Universal.Message.Byte_Size (Ctx.P.Message_Ctx) > 0,
                 when others =>
                    False));

   function Read_Buffer_Size (Ctx : Context; Chan : Channel) return RFLX_Types.Length is
     (case Chan is
          when C_Channel =>
             (case Ctx.P.Next_State is
                 when S_Reply =>
                    Universal.Message.Byte_Size (Ctx.P.Message_Ctx),
                 when others =>
                    RFLX_Types.Unreachable));

   function Needs_Data (Ctx : Context; Chan : Channel) return Boolean is
     (case Chan is
          when C_Channel =>
             (case Ctx.P.Next_State is
                 when S_Start =>
                    True,
                 when others =>
                    False));

   function Write_Buffer_Size (Ctx : Context; Chan : Channel) return RFLX_Types.Length is
     (case Chan is
          when C_Channel =>
             (case Ctx.P.Next_State is
                 when S_Start =>
                    Universal.Message.Buffer_Length (Ctx.P.Message_Ctx),
                 when others =>
                    RFLX_Types.Unreachable));

end RFLX.Test.S.FSM;