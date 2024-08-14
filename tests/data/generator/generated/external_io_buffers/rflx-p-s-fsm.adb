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

package body RFLX.P.S.FSM with
  SPARK_Mode
is

   use RFLX.RFLX_Types.Operators;

   procedure A (Ctx : in out Context) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function A_Invariant return Boolean is
        (True)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (A_Invariant);
      TLV.Message.Verify_Message (Ctx.P.M_Ctx);
      Ctx.P.Next_State := S_B;
      pragma Assert (A_Invariant);
   end A;

   procedure B (Ctx : in out Context) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function B_Invariant return Boolean is
        (True)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (B_Invariant);
      TLV.Message.Verify_Message (Ctx.P.M_Ctx);
      Ctx.P.Next_State := S_A;
      pragma Assert (B_Invariant);
   end B;

   procedure Initialize (Ctx : in out Context; M_Buffer : in out RFLX_Types.Bytes_Ptr) is
   begin
      TLV.Message.Initialize (Ctx.P.M_Ctx, M_Buffer);
      M_Buffer := null;
      Ctx.P.Next_State := S_A;
   end Initialize;

   procedure Finalize (Ctx : in out Context; M_Buffer : in out RFLX_Types.Bytes_Ptr) is
   begin
      pragma Warnings (Off, """Ctx.P.M_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      TLV.Message.Take_Buffer (Ctx.P.M_Ctx, M_Buffer);
      pragma Warnings (On, """Ctx.P.M_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      Ctx.P.Next_State := S_Final;
   end Finalize;

   procedure Reset_Messages_Before_Write (Ctx : in out Context) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
   begin
      case Ctx.P.Next_State is
         when S_A =>
            TLV.Message.Reset (Ctx.P.M_Ctx, Ctx.P.M_Ctx.First, Ctx.P.M_Ctx.First - 1);
         when S_B | S_Final =>
            null;
      end case;
   end Reset_Messages_Before_Write;

   procedure Tick (Ctx : in out Context) is
   begin
      case Ctx.P.Next_State is
         when S_A =>
            A (Ctx);
         when S_B =>
            B (Ctx);
         when S_Final =>
            null;
      end case;
      Reset_Messages_Before_Write (Ctx);
   end Tick;

   function In_IO_State (Ctx : Context) return Boolean is
     (Ctx.P.Next_State in S_A | S_B);

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

   procedure Add_Buffer (Ctx : in out Context; Ext_Buf : External_Buffer; Buffer : in out RFLX_Types.Bytes_Ptr; Written_Last : RFLX_Types.Bit_Length) is
   begin
      case Ext_Buf is
         when B_M =>
            TLV.Message.Initialize (Ctx.P.M_Ctx, Buffer, Written_Last => Written_Last);
      end case;
      Buffer := null;
   end Add_Buffer;

   procedure Remove_Buffer (Ctx : in out Context; Ext_Buf : External_Buffer; Buffer : out RFLX_Types.Bytes_Ptr) is
   begin
      case Ext_Buf is
         when B_M =>
            pragma Warnings (Off, """Ctx.P.M_Ctx"" is set by ""Take_Buffer"" but not used after the call");
            TLV.Message.Take_Buffer (Ctx.P.M_Ctx, Buffer);
            pragma Warnings (On, """Ctx.P.M_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      end case;
   end Remove_Buffer;

   procedure Read (Ctx : Context; Chan : Channel; Buffer : out RFLX_Types.Bytes; Offset : RFLX_Types.Length := 0) is
      function Read_Pre (Message_Buffer : RFLX_Types.Bytes) return Boolean is
        (Buffer'Length > 0
         and then Offset < Message_Buffer'Length);
      procedure Read (Message_Buffer : RFLX_Types.Bytes) with
        Pre =>
          Read_Pre (Message_Buffer)
      is
         Length : constant RFLX_Types.Length := RFLX_Types.Length'Min (Buffer'Length, Message_Buffer'Length - Offset);
         Buffer_Last : constant RFLX_Types.Index := Buffer'First + (Length - RFLX_Types.Length'(1));
      begin
         Buffer (Buffer'First .. RFLX_Types.Index (Buffer_Last)) := Message_Buffer (RFLX_Types.Index (RFLX_Types.Length (Message_Buffer'First) + Offset) .. Message_Buffer'First + Offset + (Length - RFLX_Types.Length'(1)));
      end Read;
      procedure TLV_Message_Read is new TLV.Message.Generic_Read (Read, Read_Pre);
   begin
      Buffer := (others => 0);
      case Chan is
         when C_X =>
            case Ctx.P.Next_State is
               when S_B =>
                  TLV_Message_Read (Ctx.P.M_Ctx);
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
      procedure Write (Message_Buffer : out RFLX_Types.Bytes; Length : out RFLX_Types.Length; Context_Buffer_Length : RFLX_Types.Length; Offset : RFLX_Types.Length) with
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
      procedure TLV_Message_Write is new TLV.Message.Generic_Write (Write, Write_Pre);
   begin
      case Chan is
         when C_X =>
            case Ctx.P.Next_State is
               when S_A =>
                  TLV_Message_Write (Ctx.P.M_Ctx, Offset);
               when others =>
                  pragma Warnings (Off, "unreachable code");
                  null;
                  pragma Warnings (On, "unreachable code");
            end case;
      end case;
   end Write;

end RFLX.P.S.FSM;
