from rflx.model import BUILTIN_TYPES


class Types:
    def __init__(self, prefix: str = "") -> None:
        self.prefix = prefix

    def prefixed(self, type_name: str) -> str:
        if type_name in BUILTIN_TYPES:
            return type_name
        return f"{self.prefix}{type_name}"

    @property
    def prefixed_builtin_types(self) -> str:
        return f"{self.prefix}Builtin_Types"

    @property
    def prefixed_builtin_conversions(self) -> str:
        return f"{self.prefix}Builtin_Types.Conversions"

    @property
    def prefixed_generic_types(self) -> str:
        return f"{self.prefix}Generic_Types"

    @property
    def prefixed_types(self) -> str:
        return f"{self.prefix}Types"

    @property
    def types(self) -> str:
        return f"Types"

    @property
    def byte(self) -> str:
        return f"{self.types}.Byte"

    @property
    def bytes(self) -> str:
        return f"{self.types}.Bytes"

    @property
    def bytes_ptr(self) -> str:
        return f"{self.types}.Bytes_Ptr"

    @property
    def index(self) -> str:
        return f"{self.types}.Index"

    @property
    def length(self) -> str:
        return f"{self.types}.Length"

    @property
    def bit_index(self) -> str:
        return f"{self.types}.Bit_Index"

    @property
    def bit_length(self) -> str:
        return f"{self.types}.Bit_Length"

    @property
    def byte_index(self) -> str:
        return f"{self.types}.Byte_Index"

    @property
    def first_bit_index(self) -> str:
        return f"{self.types}.First_Bit_Index"

    @property
    def last_bit_index(self) -> str:
        return f"{self.types}.Last_Bit_Index"

    @property
    def offset(self) -> str:
        return f"{self.types}.Offset"

    @property
    def unreachable_bit_length(self) -> str:
        return f"{self.types}.Unreachable_Bit_Length"
