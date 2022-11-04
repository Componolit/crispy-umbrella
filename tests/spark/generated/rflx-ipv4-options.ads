pragma Style_Checks ("N3aAbCdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");
pragma SPARK_Mode;
with RFLX.RFLX_Message_Sequence;
with RFLX.IPv4.Option;
pragma Warnings (Off, "unit ""*RFLX_Types"" is not referenced");
with RFLX.RFLX_Types;
pragma Warnings (On, "unit ""*RFLX_Types"" is not referenced");

package RFLX.IPv4.Options is new RFLX.RFLX_Message_Sequence (RFLX.IPv4.Option.Context, RFLX.IPv4.Option.Initialize, RFLX.IPv4.Option.Take_Buffer, RFLX.IPv4.Option.Copy, RFLX.IPv4.Option.Has_Buffer, RFLX.IPv4.Option.Size, RFLX.IPv4.Option.Message_Last, RFLX.IPv4.Option.Initialized, RFLX.IPv4.Option.Well_Formed_Message);
