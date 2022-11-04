pragma Restrictions (No_Streams);
pragma Style_Checks ("N3aAbCdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");
with RFLX.Test.Session_Allocator;
with RFLX.RFLX_Types;
with RFLX.Universal;
with RFLX.Universal.Message;
with RFLX.Test.Definite_Message;

package RFLX.Test.Session with
  SPARK_Mode
is

   use type RFLX.RFLX_Types.Index;

   use type RFLX.RFLX_Types.Length;

   type Channel is (C_Channel);

   type State is (S_Start, S_Process, S_Reply, S_Process_2, S_Reply_2, S_Final);

   type Private_Context is private;

   type Context is abstract tagged limited
      record
         P : Private_Context;
      end record;

   procedure Get_Message_Type (Ctx : in out Context; RFLX_Result : out RFLX.Universal.Option_Type) is abstract with
     Pre'Class =>
       not RFLX_Result'Constrained;

   procedure Create_Message (Ctx : in out Context; Message_Type : RFLX.Universal.Option_Type; Length : RFLX.Test.Length; Data : RFLX_Types.Bytes; RFLX_Result : out RFLX.Test.Definite_Message.Structure) is abstract;

   procedure Valid_Message (Ctx : in out Context; Message_Type : RFLX.Universal.Option_Type; Strict : Boolean; RFLX_Result : out RFLX.Test.Result) is abstract;

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

   function In_IO_State (Ctx : Context'Class) return Boolean;

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

   function Write_Buffer_Size (Ctx : Context'Class; Chan : Channel) return RFLX_Types.Length with
     Pre =>
       Initialized (Ctx)
       and then Needs_Data (Ctx, Chan);

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
         Message_Ctx : Universal.Message.Context;
         Definite_Message_Ctx : Test.Definite_Message.Context;
         Slots : Test.Session_Allocator.Slots;
         Memory : Test.Session_Allocator.Memory;
      end record;

   function Uninitialized (Ctx : Context'Class) return Boolean is
     (not Universal.Message.Has_Buffer (Ctx.P.Message_Ctx)
      and not Test.Definite_Message.Has_Buffer (Ctx.P.Definite_Message_Ctx)
      and Test.Session_Allocator.Uninitialized (Ctx.P.Slots));

   function Global_Initialized (Ctx : Context'Class) return Boolean is
     (Universal.Message.Has_Buffer (Ctx.P.Message_Ctx)
      and then Ctx.P.Message_Ctx.Buffer_First = RFLX_Types.Index'First
      and then Ctx.P.Message_Ctx.Buffer_Last = RFLX_Types.Index'First + 4095
      and then Test.Definite_Message.Has_Buffer (Ctx.P.Definite_Message_Ctx)
      and then Ctx.P.Definite_Message_Ctx.Buffer_First = RFLX_Types.Index'First
      and then Ctx.P.Definite_Message_Ctx.Buffer_Last = RFLX_Types.Index'First + 4095);

   function Initialized (Ctx : Context'Class) return Boolean is
     (Global_Initialized (Ctx)
      and then Test.Session_Allocator.Global_Allocated (Ctx.P.Slots));

   function Active (Ctx : Context'Class) return Boolean is
     (Ctx.P.Next_State /= S_Final);

   function Next_State (Ctx : Context'Class) return State is
     (Ctx.P.Next_State);

   function Has_Data (Ctx : Context'Class; Chan : Channel) return Boolean is
     ((case Chan is
          when C_Channel =>
             (case Ctx.P.Next_State is
                 when S_Reply | S_Reply_2 =>
                    Test.Definite_Message.Well_Formed_Message (Ctx.P.Definite_Message_Ctx)
                    and Test.Definite_Message.Byte_Size (Ctx.P.Definite_Message_Ctx) > 0,
                 when others =>
                    False)));

   function Read_Buffer_Size (Ctx : Context'Class; Chan : Channel) return RFLX_Types.Length is
     ((case Chan is
          when C_Channel =>
             (case Ctx.P.Next_State is
                 when S_Reply | S_Reply_2 =>
                    Test.Definite_Message.Byte_Size (Ctx.P.Definite_Message_Ctx),
                 when others =>
                    RFLX_Types.Unreachable)));

   function Needs_Data (Ctx : Context'Class; Chan : Channel) return Boolean is
     ((case Chan is
          when C_Channel =>
             (case Ctx.P.Next_State is
                 when S_Start =>
                    True,
                 when others =>
                    False)));

   function Write_Buffer_Size (Ctx : Context'Class; Chan : Channel) return RFLX_Types.Length is
     ((case Chan is
          when C_Channel =>
             (case Ctx.P.Next_State is
                 when S_Start =>
                    Universal.Message.Buffer_Length (Ctx.P.Message_Ctx),
                 when others =>
                    RFLX_Types.Unreachable)));

end RFLX.Test.Session;
