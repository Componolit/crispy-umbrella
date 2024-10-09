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
with RFLX.TLV;
use RFLX.TLV;
with RFLX.TLV.Message;

package RFLX.In_TLV.Contains with
  SPARK_Mode,
  Always_Terminates
is

   function Null_Msg_Message_In_TLV_Message_Value (Ctx : RFLX.TLV.Message.Context) return Boolean is
     (RFLX.TLV.Message.Has_Buffer (Ctx)
      and then RFLX.TLV.Message.Well_Formed (Ctx, RFLX.TLV.Message.F_Value)
      and then not RFLX.TLV.Message.Present (Ctx, RFLX.TLV.Message.F_Value));

end RFLX.In_TLV.Contains;