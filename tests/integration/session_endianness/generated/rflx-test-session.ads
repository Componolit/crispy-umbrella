pragma Restrictions (No_Streams);
pragma Style_Checks ("N3aAbcdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");
with RFLX.Test.Session_Allocator;
with RFLX.RFLX_Types;
with RFLX.Messages;
with RFLX.Messages.Msg_LE_Nested;
with RFLX.Messages.Msg_LE;
with RFLX.Messages.Msg;

package RFLX.Test.Session with
  SPARK_Mode
is

   use type RFLX.RFLX_Types.Index;

   use type RFLX.RFLX_Types.Length;

   type Channel is (C_I, C_O);

   type State is (S_Start, S_Copy, S_Reply, S_Read2, S_Copy2, S_Reply2, S_Terminated);

   type Private_Context is private;

   type Context is abstract tagged limited
      record
         P : Private_Context;
      end record;

   function Uninitialized (Ctx : Context'Class) return Boolean;

   function Initialized (Ctx : Context'Class) return Boolean;

   function Active (Ctx : Context'Class) return Boolean;

   procedure Initialize (Ctx : in out Context'Class) with
     Pre =>
       Uninitialized (Ctx),
     Post =>
       Initialized (Ctx)
       and Active (Ctx);

   procedure Finalize (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Uninitialized (Ctx)
       and not Active (Ctx);

   pragma Warnings (Off, "subprogram ""Tick"" has no effect");

   procedure Tick (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx);

   pragma Warnings (On, "subprogram ""Tick"" has no effect");

   pragma Warnings (Off, "subprogram ""Run"" has no effect");

   procedure Run (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx);

   pragma Warnings (On, "subprogram ""Run"" has no effect");

   function Next_State (Ctx : Context'Class) return State;

   function Has_Data (Ctx : Context'Class; Chan : Channel) return Boolean with
     Pre =>
       Initialized (Ctx);

   function Read_Buffer_Size (Ctx : Context'Class; Chan : Channel) return RFLX_Types.Length with
     Pre =>
       Initialized (Ctx)
       and then Has_Data (Ctx, Chan);

   procedure Read (Ctx : Context'Class; Chan : Channel; Buffer : out RFLX_Types.Bytes; Offset : RFLX_Types.Length := 0) with
     Pre =>
       Initialized (Ctx)
       and then Has_Data (Ctx, Chan)
       and then Buffer'Length > 0
       and then Offset <= RFLX_Types.Length'Last - Buffer'Length
       and then Buffer'Length + Offset <= Read_Buffer_Size (Ctx, Chan),
     Post =>
       Initialized (Ctx);

   function Needs_Data (Ctx : Context'Class; Chan : Channel) return Boolean with
     Pre =>
       Initialized (Ctx);

   function Write_Buffer_Size (Unused_Ctx : Context'Class; Chan : Channel) return RFLX_Types.Length;

   procedure Write (Ctx : in out Context'Class; Chan : Channel; Buffer : RFLX_Types.Bytes; Offset : RFLX_Types.Length := 0) with
     Pre =>
       Initialized (Ctx)
       and then Needs_Data (Ctx, Chan)
       and then Buffer'Length > 0
       and then Offset <= RFLX_Types.Length'Last - Buffer'Length
       and then Buffer'Length + Offset <= Write_Buffer_Size (Ctx, Chan),
     Post =>
       Initialized (Ctx);

private

   type Private_Context is
      record
         Next_State : State := S_Start;
         In_Msg_Ctx : Messages.Msg_LE_Nested.Context;
         In_Msg2_Ctx : Messages.Msg_LE.Context;
         Out_Msg_Ctx : Messages.Msg_LE.Context;
         Out_Msg2_Ctx : Messages.Msg.Context;
         Slots : Test.Session_Allocator.Slots;
         Memory : Test.Session_Allocator.Memory;
      end record;

   function Uninitialized (Ctx : Context'Class) return Boolean is
     (not Messages.Msg_LE_Nested.Has_Buffer (Ctx.P.In_Msg_Ctx)
      and not Messages.Msg_LE.Has_Buffer (Ctx.P.In_Msg2_Ctx)
      and not Messages.Msg_LE.Has_Buffer (Ctx.P.Out_Msg_Ctx)
      and not Messages.Msg.Has_Buffer (Ctx.P.Out_Msg2_Ctx)
      and Test.Session_Allocator.Uninitialized (Ctx.P.Slots));

   function Initialized (Ctx : Context'Class) return Boolean is
     (Messages.Msg_LE_Nested.Has_Buffer (Ctx.P.In_Msg_Ctx)
      and then Ctx.P.In_Msg_Ctx.Buffer_First = RFLX_Types.Index'First
      and then Ctx.P.In_Msg_Ctx.Buffer_Last = RFLX_Types.Index'First + 4095
      and then Messages.Msg_LE.Has_Buffer (Ctx.P.In_Msg2_Ctx)
      and then Ctx.P.In_Msg2_Ctx.Buffer_First = RFLX_Types.Index'First
      and then Ctx.P.In_Msg2_Ctx.Buffer_Last = RFLX_Types.Index'First + 4095
      and then Messages.Msg_LE.Has_Buffer (Ctx.P.Out_Msg_Ctx)
      and then Ctx.P.Out_Msg_Ctx.Buffer_First = RFLX_Types.Index'First
      and then Ctx.P.Out_Msg_Ctx.Buffer_Last = RFLX_Types.Index'First + 4095
      and then Messages.Msg.Has_Buffer (Ctx.P.Out_Msg2_Ctx)
      and then Ctx.P.Out_Msg2_Ctx.Buffer_First = RFLX_Types.Index'First
      and then Ctx.P.Out_Msg2_Ctx.Buffer_Last = RFLX_Types.Index'First + 4095
      and then Test.Session_Allocator.Global_Allocated (Ctx.P.Slots));

   function Active (Ctx : Context'Class) return Boolean is
     (Ctx.P.Next_State /= S_Terminated);

   function Next_State (Ctx : Context'Class) return State is
     (Ctx.P.Next_State);

   function Has_Data (Ctx : Context'Class; Chan : Channel) return Boolean is
     ((case Chan is
          when C_I =>
             False,
          when C_O =>
             (case Ctx.P.Next_State is
                 when S_Reply =>
                    Messages.Msg_LE.Structural_Valid_Message (Ctx.P.Out_Msg_Ctx)
                    and Messages.Msg_LE.Byte_Size (Ctx.P.Out_Msg_Ctx) > 0,
                 when S_Reply2 =>
                    Messages.Msg.Structural_Valid_Message (Ctx.P.Out_Msg2_Ctx)
                    and Messages.Msg.Byte_Size (Ctx.P.Out_Msg2_Ctx) > 0,
                 when others =>
                    False)));

   function Read_Buffer_Size (Ctx : Context'Class; Chan : Channel) return RFLX_Types.Length is
     ((case Chan is
          when C_I =>
             RFLX_Types.Unreachable,
          when C_O =>
             (case Ctx.P.Next_State is
                 when S_Reply =>
                    Messages.Msg_LE.Byte_Size (Ctx.P.Out_Msg_Ctx),
                 when S_Reply2 =>
                    Messages.Msg.Byte_Size (Ctx.P.Out_Msg2_Ctx),
                 when others =>
                    RFLX_Types.Unreachable)));

   function Needs_Data (Ctx : Context'Class; Chan : Channel) return Boolean is
     ((case Chan is
          when C_I =>
             (case Ctx.P.Next_State is
                 when S_Start | S_Read2 =>
                    True,
                 when others =>
                    False),
          when C_O =>
             False));

   function Write_Buffer_Size (Unused_Ctx : Context'Class; Chan : Channel) return RFLX_Types.Length is
     ((case Chan is
          when C_I =>
             4096,
          when C_O =>
             0));

end RFLX.Test.Session;
