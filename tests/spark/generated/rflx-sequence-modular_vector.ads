pragma Style_Checks ("N3aAbcdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");
pragma SPARK_Mode;
with RFLX.RFLX_Types;
with RFLX.RFLX_Scalar_Sequence;
with RFLX.Sequence;

package RFLX.Sequence.Modular_Vector is new RFLX.RFLX_Scalar_Sequence (RFLX.RFLX_Types, RFLX.Sequence.Modular_Integer, RFLX.Sequence.Modular_Integer, RFLX.Sequence.Valid, RFLX.Sequence.To_Actual, RFLX.Sequence.To_Base);
