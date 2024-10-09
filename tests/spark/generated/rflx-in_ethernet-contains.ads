------------------------------------------------------------------------------
--                                                                          --
--                         Generated by RecordFlux                          --
--                                                                          --
--                          Copyright (C) AdaCore                           --
--                                                                          --
--         SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception          --
--                                                                          --
------------------------------------------------------------------------------

pragma Ada_2012;
pragma Style_Checks ("N3aAbCdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");
with RFLX.RFLX_Types;
with RFLX.Ethernet;
use RFLX.Ethernet;
with RFLX.Ethernet.Frame;
with RFLX.IPv4.Packet;

package RFLX.In_Ethernet.Contains with
  SPARK_Mode,
  Always_Terminates
is

   use type RFLX_Types.Index;

   use type RFLX_Types.Bit_Index;

   function IPv4_Packet_In_Ethernet_Frame_Payload (Ctx : RFLX.Ethernet.Frame.Context) return Boolean is
     (RFLX.Ethernet.Frame.Has_Buffer (Ctx)
      and then RFLX.Ethernet.Frame.Present (Ctx, RFLX.Ethernet.Frame.F_Payload)
      and then RFLX.Ethernet.Frame.Valid (Ctx, RFLX.Ethernet.Frame.F_Type_Length)
      and then RFLX.Ethernet.Frame.Get_Type_Length (Ctx) = 16#800#);

   use type RFLX.Ethernet.Frame.Field_Cursors;

   procedure Switch_To_Payload (Ethernet_Frame_PDU_Context : in out RFLX.Ethernet.Frame.Context; IPv4_Packet_SDU_Context : out RFLX.IPv4.Packet.Context) with
     Pre =>
       not Ethernet_Frame_PDU_Context'Constrained
       and not IPv4_Packet_SDU_Context'Constrained
       and RFLX.In_Ethernet.Contains.IPv4_Packet_In_Ethernet_Frame_Payload (Ethernet_Frame_PDU_Context),
     Post =>
       not RFLX.Ethernet.Frame.Has_Buffer (Ethernet_Frame_PDU_Context)
       and RFLX.IPv4.Packet.Has_Buffer (IPv4_Packet_SDU_Context)
       and Ethernet_Frame_PDU_Context.Buffer_First = IPv4_Packet_SDU_Context.Buffer_First
       and Ethernet_Frame_PDU_Context.Buffer_Last = IPv4_Packet_SDU_Context.Buffer_Last
       and IPv4_Packet_SDU_Context.First = RFLX.Ethernet.Frame.Field_First (Ethernet_Frame_PDU_Context, RFLX.Ethernet.Frame.F_Payload)
       and IPv4_Packet_SDU_Context.Last = RFLX.Ethernet.Frame.Field_Last (Ethernet_Frame_PDU_Context, RFLX.Ethernet.Frame.F_Payload)
       and RFLX.IPv4.Packet.Initialized (IPv4_Packet_SDU_Context)
       and Ethernet_Frame_PDU_Context.Buffer_First = Ethernet_Frame_PDU_Context.Buffer_First'Old
       and Ethernet_Frame_PDU_Context.Buffer_Last = Ethernet_Frame_PDU_Context.Buffer_Last'Old
       and Ethernet_Frame_PDU_Context.First = Ethernet_Frame_PDU_Context.First'Old
       and RFLX.Ethernet.Frame.Context_Cursors (Ethernet_Frame_PDU_Context) = RFLX.Ethernet.Frame.Context_Cursors (Ethernet_Frame_PDU_Context)'Old;

   function Sufficient_Space_For_Payload (Ethernet_Frame_PDU_Context : RFLX.Ethernet.Frame.Context; IPv4_Packet_SDU_Context : RFLX.IPv4.Packet.Context) return Boolean is
     (RFLX.IPv4.Packet.Buffer_Size (IPv4_Packet_SDU_Context) >= RFLX.Ethernet.Frame.Field_Size (Ethernet_Frame_PDU_Context, RFLX.Ethernet.Frame.F_Payload)
      and then RFLX_Types.To_First_Bit_Index (IPv4_Packet_SDU_Context.Buffer_First) + RFLX.Ethernet.Frame.Field_Size (Ethernet_Frame_PDU_Context, RFLX.Ethernet.Frame.F_Payload) - 1 < RFLX_Types.Bit_Index'Last) with
     Pre =>
       RFLX.IPv4.Packet.Has_Buffer (IPv4_Packet_SDU_Context)
       and then RFLX.In_Ethernet.Contains.IPv4_Packet_In_Ethernet_Frame_Payload (Ethernet_Frame_PDU_Context);

   procedure Copy_Payload (Ethernet_Frame_PDU_Context : RFLX.Ethernet.Frame.Context; IPv4_Packet_SDU_Context : in out RFLX.IPv4.Packet.Context) with
     Pre =>
       not IPv4_Packet_SDU_Context'Constrained
       and then RFLX.IPv4.Packet.Has_Buffer (IPv4_Packet_SDU_Context)
       and then RFLX.In_Ethernet.Contains.IPv4_Packet_In_Ethernet_Frame_Payload (Ethernet_Frame_PDU_Context)
       and then Sufficient_Space_For_Payload (Ethernet_Frame_PDU_Context, IPv4_Packet_SDU_Context),
     Post =>
       RFLX.Ethernet.Frame.Has_Buffer (Ethernet_Frame_PDU_Context)
       and RFLX.IPv4.Packet.Has_Buffer (IPv4_Packet_SDU_Context)
       and RFLX.IPv4.Packet.Initialized (IPv4_Packet_SDU_Context)
       and IPv4_Packet_SDU_Context.Buffer_First = IPv4_Packet_SDU_Context.Buffer_First'Old
       and IPv4_Packet_SDU_Context.Buffer_Last = IPv4_Packet_SDU_Context.Buffer_Last'Old;

end RFLX.In_Ethernet.Contains;