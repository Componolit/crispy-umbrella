from typing import Callable, Dict, Iterator, Mapping, Union

from rflx.common import Base
from rflx.pyrflx import PyRFLXError
from rflx.pyrflx.typevalue import MessageValue


class Package(Base):
    def __init__(self, name: str) -> None:
        self.__name = name
        self.__messages: Dict[str, MessageValue] = {}

    @property
    def name(self) -> str:
        return self.__name

    def new_message(
        self, key: str, parameters: Mapping[str, Union[bool, int, str]] = None
    ) -> MessageValue:
        message = self.__messages[key].clone()
        if parameters:
            message.add_parameters(parameters)
        return message

    def set_message(self, key: str, value: MessageValue) -> None:
        self.__messages[key] = value

    def __getitem__(self, key: str) -> MessageValue:
        return self.new_message(key)

    def __iter__(self) -> Iterator[MessageValue]:
        return self.__messages.values().__iter__()

    def set_checksum_functions(self, functions: Dict[str, Dict[str, Callable]]) -> None:
        for message_name, field_name_to_function_mapping in functions.items():
            if message_name not in self.__messages:
                raise PyRFLXError(f'"{message_name}" is not a message in {self.__name}')
            self.__messages[message_name].set_checksum_function(field_name_to_function_mapping)
