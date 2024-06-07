from collections.abc import Sequence
from enum import Enum
from pathlib import Path
from typing import Optional, Union

from typing_extensions import Self

class ID:
    def __init__(
        self,
        identifier: Union[str, Sequence[str], Self],
        location: Optional[Location] = None,
    ) -> None: ...
    def __eq__(self, other: object) -> bool: ...
    def __lt__(self, other: object) -> bool: ...
    def __add__(self: Self, other: object) -> Self: ...
    def __radd__(self: Self, other: object) -> Self: ...
    def __mul__(self: Self, other: object) -> Self: ...
    def __rmul__(self: Self, other: object) -> Self: ...
    @property
    def location(self) -> Optional[Location]: ...
    @property
    def parts(self) -> Sequence[str]: ...
    @property
    def name(self: Self) -> Self: ...
    @property
    def parent(self: Self) -> Self: ...
    @property
    def flat(self) -> str: ...
    @property
    def ada_str(self) -> str: ...

class Location:
    def __init__(
        self,
        start: tuple[int, int],
        source: Optional[Path] = None,
        end: Optional[tuple[int, int]] = None,
    ): ...
    @property
    def source(self) -> Optional[Path]: ...
    @property
    def start(self) -> tuple[int, int]: ...
    @property
    def end(self) -> Optional[tuple[int, int]]: ...
    @property
    def short(self) -> Location: ...
    def __lt__(self, other: object) -> bool: ...
    @staticmethod
    def merge(locations: Sequence[Optional[Location]]) -> Location: ...

class Severity(Enum):
    ERROR: Severity
    WARNING: Severity
    INFO: Severity
    NOTE: Severity
    HELP: Severity

class Annotation:
    def __init__(
        self,
        label: str | None,
        severity: Severity,
        location: Location,
    ) -> None: ...
    @property
    def location(self) -> Location: ...
    @property
    def severity(self) -> Severity: ...
    @property
    def label(self) -> str | None: ...

class ErrorEntry:
    def __init__(
        self,
        message: str,
        severity: Severity,
        location: Location | None = None,
        annotations: Sequence[Annotation] = [],
        generate_default_annotation: bool = True,
    ) -> None: ...
    @property
    def message(self) -> str: ...
    @property
    def severity(self) -> Severity: ...
    @property
    def location(self) -> Location | None: ...
    @property
    def annotations(self) -> Sequence[Annotation]: ...

class RecordFluxError(BaseException):
    def __init__(self, entries: Sequence[ErrorEntry] = []) -> None: ...
    @classmethod
    def set_max_error(cls, max_value: int) -> None: ...
    @classmethod
    def reset_errors(cls) -> None: ...
    @property
    def entries(self) -> list[ErrorEntry]: ...
    def push(self, entry: ErrorEntry) -> None: ...
    def extend(self, entries: Sequence[ErrorEntry]) -> None: ...
    def print_messages(self) -> None: ...
    def propagate(self) -> None: ...
    def has_errors(self) -> bool: ...

class FatalError(BaseException): ...
