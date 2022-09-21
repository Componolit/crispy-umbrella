#  pylint: disable=unused-argument,invalid-name,no-self-use
from typing import Iterable, Optional

class Context: ...

class ExprRef:
    def __eq__(self, other: "ExprRef") -> "BoolRef": ...  # type: ignore
    def __ne__(self, other: "ExprRef") -> "BoolRef": ...  # type: ignore

class BoolRef(ExprRef): ...

class ArithRef(ExprRef):
    def is_int(self) -> bool: ...
    def __sub__(self, other: "ArithRef") -> "ArithRef": ...
    def __add__(self, other: "ArithRef") -> "ArithRef": ...
    def __mul__(self, other: "ArithRef") -> "ArithRef": ...
    def __pow__(self, other: "ArithRef") -> "ArithRef": ...
    def __mod__(self, other: "ArithRef") -> "ArithRef": ...
    def __truediv__(self, other: "ArithRef") -> "ArithRef": ...
    def __gt__(self, other: "ArithRef") -> BoolRef: ...
    def __ge__(self, other: "ArithRef") -> BoolRef: ...
    def __lt__(self, other: "ArithRef") -> BoolRef: ...
    def __le__(self, other: "ArithRef") -> BoolRef: ...
    def __neg__(self) -> "ArithRef": ...

class IntNumRef(ArithRef):
    def as_long(self) -> int: ...
    def as_string(self) -> str: ...
    def as_binary_string(self) -> bytes: ...

def Int(name: str, ctx: Optional[Context] = None) -> ArithRef: ...
def IntVal(val: int, ctx: Optional[Context] = None) -> ArithRef: ...
def Sum(*args: ArithRef) -> ArithRef: ...
def Product(*args: ArithRef) -> ArithRef: ...
def Bool(name: str, ctx: Optional[Context] = None) -> BoolRef: ...
def BoolVal(val: bool, ctx: Optional[Context] = None) -> BoolRef: ...
def Not(val: BoolRef, ctx: Optional[Context] = None) -> BoolRef: ...
def And(*args: BoolRef) -> BoolRef: ...
def Or(*args: BoolRef) -> BoolRef: ...
def If(c: BoolRef, t: ExprRef, e: ExprRef, ctx: Optional[Context] = None) -> ExprRef: ...
def ForAll(v: Iterable[ExprRef], cond: ExprRef) -> ExprRef: ...
def Exists(v: Iterable[ExprRef], cond: ExprRef) -> ExprRef: ...
def simplify(e: ExprRef) -> ExprRef: ...

class CheckSatResult: ...

sat = CheckSatResult()
unsat = CheckSatResult()
unknown = CheckSatResult()

class Solver:
    def add(self, *expr: ExprRef) -> None: ...
    def check(self, *asns: ExprRef) -> CheckSatResult: ...
    def assert_and_track(self, expr: ExprRef, name: str) -> None: ...
    def unsat_core(self) -> Iterable[ExprRef]: ...
    def set(self, unsat_core: bool) -> None: ...
    def reason_unknown(self) -> str: ...

class SolverFor(Solver):
    def __init__(self, logic: str) -> None: ...

class OptimizeObjective:
    def lower(self) -> ExprRef: ...
    def upper(self) -> ExprRef: ...
    def value(self) -> ExprRef: ...

class Optimize:
    def add(self, *args: ExprRef) -> None: ...
    def maximize(self, arg: ExprRef) -> OptimizeObjective: ...
    def minimize(self, arg: ExprRef) -> OptimizeObjective: ...
    def check(self, *assumptions: ExprRef) -> CheckSatResult: ...

class Z3Exception(Exception):
    def __init__(self, value: str) -> None: ...
