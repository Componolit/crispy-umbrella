from typing import Any, Dict, Iterable, List, Optional

import yaml

from rflx.error import Location, RecordFluxError, Severity, Subsystem
from rflx.expression import TRUE, Expr
from rflx.fsm_declaration import Subprogram
from rflx.fsm_parser import FSMParser
from rflx.identifier import ID, StrID
from rflx.model import Base
from rflx.statement import Statement


class StateName(Base):
    def __init__(self, name: str, location: Location = None):
        self.__name = name
        self.location = location

    @property
    def name(self) -> str:
        return self.__name


class Transition(Base):
    def __init__(self, target: StateName, condition: Expr = TRUE):
        self.__target = target
        self.__condition = condition

    @property
    def target(self) -> StateName:
        return self.__target


class State(Base):
    def __init__(
        self,
        name: StateName,
        transitions: Optional[Iterable[Transition]] = None,
        actions: Optional[Iterable[Statement]] = None,
    ):
        self.__name = name
        self.__transitions = transitions or []
        self.__actions = actions or []

    @property
    def name(self) -> StateName:
        return self.__name

    @property
    def transitions(self) -> Iterable[Transition]:
        return self.__transitions or []


class StateMachine(Base):
    def __init__(
        self,
        name: str,
        initial: StateName,
        final: StateName,
        states: Iterable[State],
        functions: Dict[StrID, Subprogram],
        location: Location = None,
    ):  # pylint: disable=too-many-arguments
        self.__name = name
        self.__initial = initial
        self.__final = final
        self.__states = states
        self.__functions = {ID(k): v for k, v in functions.items()}
        self.location = location
        self.error = RecordFluxError()

        if not states:
            self.error.append(
                "empty states", Subsystem.SESSION, Severity.ERROR, location,
            )
        self.__validate_state_existence()
        self.__validate_duplicate_states()
        self.__validate_state_reachability()
        self.error.propagate()

    def __validate_state_existence(self) -> None:
        state_names = [s.name for s in self.__states]
        if self.__initial not in state_names:
            self.error.append(
                f'initial state "{self.__initial.name}" does not exist in "{self.__name}"',
                Subsystem.SESSION,
                Severity.ERROR,
                self.__initial.location,
            )
        if self.__final not in state_names:
            self.error.append(
                f'final state "{self.__final.name}" does not exist in "{self.__name}"',
                Subsystem.SESSION,
                Severity.ERROR,
                self.__final.location,
            )
        for s in self.__states:
            for t in s.transitions:
                if t.target not in state_names:
                    self.error.append(
                        f'transition from state "{s.name.name}" to non-existent state'
                        f' "{t.target.name}" in "{self.__name}"',
                        Subsystem.SESSION,
                        Severity.ERROR,
                        t.target.location,
                    )

    def __validate_duplicate_states(self) -> None:
        state_names = [s.name for s in self.__states]
        seen: Dict[str, int] = {}
        duplicates: List[str] = []
        for n in [x.name for x in state_names]:
            if n not in seen:
                seen[n] = 1
            else:
                if seen[n] == 1:
                    duplicates.append(n)
                seen[n] += 1

        if duplicates:
            self.error.append(
                f'duplicate states: {", ".join(sorted(duplicates))}',
                Subsystem.SESSION,
                Severity.ERROR,
                self.location,
            )

    def __validate_state_reachability(self) -> None:
        inputs: Dict[str, List[str]] = {}
        for s in self.__states:
            for t in s.transitions:
                if t.target.name in inputs:
                    inputs[t.target.name].append(s.name.name)
                else:
                    inputs[t.target.name] = [s.name.name]
        unreachable = [
            s.name.name
            for s in self.__states
            if s.name != self.__initial and s.name.name not in inputs
        ]
        if unreachable:
            self.error.append(
                f'unreachable states {", ".join(unreachable)}',
                Subsystem.SESSION,
                Severity.ERROR,
                self.location,
            )

        detached = [
            s.name.name for s in self.__states if s.name != self.__final and not s.transitions
        ]
        if detached:
            self.error.append(
                f'detached states {", ".join(detached)}',
                Subsystem.SESSION,
                Severity.ERROR,
                self.location,
            )


class FSM:
    def __init__(self) -> None:
        self.__fsms: List[StateMachine] = []
        self.error = RecordFluxError()

    def __parse_functions(self, doc: Dict[str, Any]) -> Dict[StrID, Subprogram]:
        if "functions" not in doc:
            return {}

        result: Dict[StrID, Subprogram] = {}
        for index, f in enumerate(doc["functions"]):
            try:
                name, declaration = FSMParser.declaration().parseString(f)[0]
            except RecordFluxError as e:
                self.error.extend(e)
                self.error.append(
                    f"error parsing global function declaration {index} ({e})",
                    Subsystem.SESSION,
                    Severity.ERROR,
                )
                continue
            result[ID(name)] = declaration
        self.error.propagate()
        return result

    def __parse_transitions(self, state: Dict) -> List[Transition]:
        transitions: List[Transition] = []
        sname = state["name"]
        if "transitions" in state:
            for index, t in enumerate(state["transitions"]):
                rest = t.keys() - ["condition", "target", "doc"]
                if rest:
                    elements = ", ".join(sorted(rest))
                    self.error.append(
                        f"unexpected elements in transition {index}"
                        f' in state "{state}": {elements}',
                        Subsystem.SESSION,
                        Severity.ERROR,
                    )
                if "condition" in t:
                    try:
                        condition = FSMParser.condition().parseString(t["condition"])[0]
                    except RecordFluxError as e:
                        self.error.extend(e)
                        tname = t["target"]
                        self.error.append(
                            f'invalid condition {index} from state "{sname}" to "{tname}"',
                            Subsystem.SESSION,
                            Severity.ERROR,
                            None,
                        )
                        continue
                else:
                    condition = TRUE
                transitions.append(Transition(target=StateName(t["target"]), condition=condition))
        return transitions

    def __parse(self, name: str, doc: Dict[str, Any]) -> None:  # pylint: disable=too-many-locals
        if "initial" not in doc:
            self.error.append(
                f'missing initial state in "{name}"', Subsystem.SESSION, Severity.ERROR
            )
        if "final" not in doc:
            self.error.append(f'missing final state in "{name}"', Subsystem.SESSION, Severity.ERROR)
        if "states" not in doc:
            self.error.append(
                f'missing states section in "{name}"', Subsystem.SESSION, Severity.ERROR
            )

        self.error.propagate()

        rest = set(doc.keys()) - set(
            ["channels", "variables", "functions", "initial", "final", "states", "renames", "types"]
        )
        if rest:
            self.error.append(
                f'unexpected elements: {", ".join(sorted(rest))}', Subsystem.SESSION, Severity.ERROR
            )

        functions = self.__parse_functions(doc)

        states: List[State] = []
        for s in doc["states"]:
            state = s["name"]
            rest = s.keys() - ["name", "actions", "transitions", "variables", "doc"]
            if rest:
                elements = ", ".join(sorted(rest))
                self.error.append(
                    f'unexpected elements in state "{state}": {elements}',
                    Subsystem.SESSION,
                    Severity.ERROR,
                )
            transitions: List[Transition] = []
            transitions = self.__parse_transitions(s)
            actions: List[Statement] = []
            if "actions" in s and s["actions"]:
                for index, a in enumerate(s["actions"]):
                    try:
                        actions.append(FSMParser.action().parseString(a)[0])
                    except RecordFluxError as e:
                        self.error.extend(e)
                        sname = s["name"]
                        self.error.append(
                            f"error parsing action {index} of state {sname} ({e})",
                            Subsystem.SESSION,
                            Severity.ERROR,
                        )
            states.append(
                State(name=StateName(s["name"]), transitions=transitions, actions=actions)
            )

        self.error.propagate()

        fsm = StateMachine(
            name=name,
            initial=StateName(doc["initial"]),
            final=StateName(doc["final"]),
            states=states,
            functions=functions,
        )
        self.error.extend(fsm.error)
        self.__fsms.append(fsm)
        self.error.propagate()

    def parse(self, name: str, filename: str) -> None:
        with open(filename, "r") as data:
            self.__parse(name, yaml.safe_load(data))

    def parse_string(self, name: str, string: str) -> None:
        self.__parse(name, yaml.safe_load(string))

    @property
    def fsms(self) -> List[StateMachine]:
        return self.__fsms
