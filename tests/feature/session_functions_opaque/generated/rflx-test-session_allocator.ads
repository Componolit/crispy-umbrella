pragma Style_Checks ("N3aAbCdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");
with RFLX.RFLX_Types;
use type RFLX.RFLX_Types.Index;
use type RFLX.RFLX_Types.Bytes_Ptr;

package RFLX.Test.Session_Allocator with
  SPARK_Mode,
  Always_Terminates
is

   type Memory is
      record
         Slot_1 : aliased RFLX_Types.Bytes (RFLX_Types.Index'First .. RFLX_Types.Index'First + 4095) := (others => 0);
      end record;

   subtype Slot_Ptr_Type_4096 is RFLX_Types.Bytes_Ptr with
     Dynamic_Predicate =>
       Slot_Ptr_Type_4096 = null
       or else (Slot_Ptr_Type_4096'First = RFLX_Types.Index'First
                and then Slot_Ptr_Type_4096'Last = RFLX_Types.Index'First + 4095);

   type Slots is
      record
         Slot_Ptr_1 : Slot_Ptr_Type_4096;
      end record;

   function Initialized (S : Slots) return Boolean is
     (S.Slot_Ptr_1 /= null);

   function Uninitialized (S : Slots) return Boolean is
     (S.Slot_Ptr_1 = null);

   procedure Initialize (S : out Slots; M : Memory) with
     Post =>
       Initialized (S);

   procedure Finalize (S : in out Slots) with
     Post =>
       Uninitialized (S);

   function Global_Allocated (S : Slots) return Boolean is
     (S.Slot_Ptr_1 /= null);

end RFLX.Test.Session_Allocator;
