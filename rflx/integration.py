from pathlib import Path
from typing import Dict, Optional

from pydantic import BaseModel, Extra, Field, ValidationError
from pydantic.types import ConstrainedInt

from rflx.error import Location, RecordFluxError, Severity, Subsystem
from rflx.identifier import ID
from rflx.model import Model
from rflx.model.session import Session


class IntSize(ConstrainedInt):
    gt = 0


class SessionSize(BaseModel, extra=Extra.forbid):
    default: Optional[IntSize] = Field(alias="Default")
    global_: Optional[Dict[str, IntSize]] = Field(alias="Global")
    local_: Optional[Dict[str, Dict[str, IntSize]]] = Field(alias="Local")


class SessionIntegration(BaseModel, extra=Extra.forbid):
    buffer_size: SessionSize = Field(alias="Buffer_Size")


class IntegrationFile(BaseModel, extra=Extra.forbid):
    session: Dict[str, SessionIntegration] = Field(alias="Session")


class Integration:
    @property
    def defaultsize(self) -> int:
        return 4096

    def __init__(self) -> None:
        self._packages: Dict[str, IntegrationFile] = {}

    def add_integration_file(self, filename: Path, file: object, error: RecordFluxError) -> None:
        try:
            self._packages[filename.stem] = IntegrationFile.parse_obj(file)
        except ValidationError as e:
            error.extend(
                [(f"{e}", Subsystem.PARSER, Severity.ERROR, self._to_location(filename.stem))]
            )

    def validate(self, model: Model, error: RecordFluxError) -> None:
        for package, integration_file in self._packages.items():
            for session_name, integration in integration_file.session.items():
                matching_sessions = [
                    s
                    for s in model.sessions
                    if package == str(s.package).lower() and str(s.identifier.name) == session_name
                ]
                if not matching_sessions:
                    error.extend(
                        [
                            (
                                f'unknown session "{session_name}"',
                                Subsystem.PARSER,
                                Severity.ERROR,
                                Integration._to_location(package),
                            )
                        ]
                    )
                    return
                assert len(matching_sessions) == 1
                session = matching_sessions[0]
                self._validate_globals(package, integration, session, error)
                self._validate_states(package, integration, session, error)

    def get_size(self, session: ID, variable: ID, state: Optional[ID]) -> int:
        """
        Return the requested buffer size for a variable of a given session and state.

        If state is None, the variable is assumed to be a global
        variable. If no specific buffer size was requested for the variable,
        return the default buffer size for the session, if present, or the
        default buffer size for RecordFlux.
        """
        integration_package = str(session.parent).lower()
        if integration_package not in self._packages:
            return self.defaultsize

        session_name = str(session.name)
        if session_name not in self._packages[integration_package].session:
            return self.defaultsize

        buffer_size = self._packages[integration_package].session[session_name].buffer_size
        variable_name = str(variable.name)
        default_size = self.defaultsize if buffer_size.default is None else buffer_size.default
        if state is None:
            if buffer_size.global_ is not None and variable_name in buffer_size.global_:
                return buffer_size.global_[variable_name]
            return default_size

        state_name = str(state)
        if (
            buffer_size.local_ is not None
            and state_name in buffer_size.local_
            and variable_name in buffer_size.local_[state_name]
        ):
            return buffer_size.local_[state_name][variable_name]
        return default_size

    @staticmethod
    def _to_location(package: str) -> Location:
        return Location(start=(0, 0), source=Path(package + ".rfi"))

    @staticmethod
    def _validate_globals(
        package: str, integration: SessionIntegration, session: Session, error: RecordFluxError
    ) -> None:
        if integration.buffer_size.global_ is None:
            return
        session_decl_vars = [str(x.name) for x in session.declarations.keys()]
        for var_name in integration.buffer_size.global_.keys():
            if var_name not in session_decl_vars:
                error.extend(
                    [
                        (
                            (
                                f'unknown global variable "{var_name}" '
                                f'in session "{session.identifier.name}"'
                            ),
                            Subsystem.PARSER,
                            Severity.ERROR,
                            Integration._to_location(package),
                        )
                    ]
                )

    @staticmethod
    def _validate_states(
        package: str, integration: SessionIntegration, session: Session, error: RecordFluxError
    ) -> None:
        if integration.buffer_size.local_ is None:
            return
        for state_name, state_entry in integration.buffer_size.local_.items():
            state = None
            for s in session.states:
                if str(s.identifier.name) == state_name:
                    state = s
            if state is None:
                error.extend(
                    [
                        (
                            (
                                f'unknown state "{state_name}" in session '
                                f'"{session.identifier.name}"'
                            ),
                            Subsystem.PARSER,
                            Severity.ERROR,
                            Integration._to_location(package),
                        )
                    ]
                )
                return
            state_declaration_vars = [str(x.name) for x in state.declarations.keys()]
            for var_name in state_entry.keys():
                if var_name not in state_declaration_vars:
                    error.extend(
                        [
                            (
                                (
                                    f'unknown variable "{var_name}" in state '
                                    f'"{state_name}" of session "{session.identifier.name}"'
                                ),
                                Subsystem.PARSER,
                                Severity.ERROR,
                                Integration._to_location(package),
                            )
                        ]
                    )
