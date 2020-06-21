# pylint: disable=too-many-lines
from copy import deepcopy

import pytest
from icontract import ViolationError

from rflx.error import Location, RecordFluxError
from rflx.expression import (
    TRUE,
    Add,
    Aggregate,
    And,
    Div,
    Equal,
    First,
    GreaterEqual,
    Length,
    LessEqual,
    NotEqual,
    Number,
    Or,
    Pow,
    Sub,
    Variable,
)
from rflx.identifier import ID
from rflx.model import (
    BOOLEAN,
    FINAL,
    INITIAL,
    Array,
    DerivedMessage,
    Enumeration,
    Field,
    Link,
    Message,
    ModularInteger,
    Opaque,
    RangeInteger,
    Refinement,
    Type,
    UnprovenDerivedMessage,
    UnprovenMessage,
)
from tests.models import ENUMERATION, ETHERNET_FRAME, MODULAR_INTEGER, RANGE_INTEGER
from tests.utils import assert_equal

M_NO_REF = UnprovenMessage(
    "P.No_Ref",
    [
        Link(INITIAL, Field("F1"), length=Number(16)),
        Link(Field("F1"), Field("F2")),
        Link(Field("F2"), Field("F3"), LessEqual(Variable("F2"), Number(100)), first=First("F2")),
        Link(
            Field("F2"), Field("F4"), GreaterEqual(Variable("F2"), Number(200)), first=First("F2"),
        ),
        Link(Field("F3"), FINAL, Equal(Variable("F3"), Variable("ONE"))),
        Link(Field("F4"), FINAL),
    ],
    {
        Field("F1"): Opaque(),
        Field("F2"): MODULAR_INTEGER,
        Field("F3"): ENUMERATION,
        Field("F4"): RANGE_INTEGER,
    },
)

M_SMPL_REF = UnprovenMessage(
    "P.Smpl_Ref",
    [Link(INITIAL, Field("NR")), Link(Field("NR"), FINAL)],
    {Field("NR"): deepcopy(M_NO_REF)},
)


M_CMPLX_REF = UnprovenMessage(
    "P.Cmplx_Ref",
    [
        Link(INITIAL, Field("F1")),
        Link(Field("F1"), Field("F2"), LessEqual(Variable("F1"), Number(100))),
        Link(Field("F1"), Field("F3"), GreaterEqual(Variable("F1"), Number(200))),
        Link(Field("F2"), Field("NR"), LessEqual(Variable("F1"), Number(10))),
        Link(Field("F3"), Field("NR"), GreaterEqual(Variable("F1"), Number(220))),
        Link(Field("NR"), Field("F5"), LessEqual(Variable("F1"), Number(100))),
        Link(Field("NR"), Field("F6"), GreaterEqual(Variable("F1"), Number(200))),
        Link(Field("F5"), FINAL),
        Link(Field("F6"), FINAL),
    ],
    {
        Field("F1"): deepcopy(MODULAR_INTEGER),
        Field("F2"): deepcopy(MODULAR_INTEGER),
        Field("F3"): deepcopy(RANGE_INTEGER),
        Field("NR"): deepcopy(M_NO_REF),
        Field("F5"): deepcopy(MODULAR_INTEGER),
        Field("F6"): deepcopy(RANGE_INTEGER),
    },
)


M_DBL_REF = UnprovenMessage(
    "P.Dbl_Ref",
    [Link(INITIAL, Field("SR")), Link(Field("SR"), Field("NR")), Link(Field("NR"), FINAL)],
    {Field("SR"): deepcopy(M_SMPL_REF), Field("NR"): deepcopy(M_NO_REF)},
)


M_NO_REF_DERI = UnprovenDerivedMessage(
    "P.No_Ref_Deri",
    M_NO_REF,
    [
        Link(INITIAL, Field("F1"), length=Number(16)),
        Link(Field("F1"), Field("F2")),
        Link(Field("F2"), Field("F3"), LessEqual(Variable("F2"), Number(100)), first=First("F2")),
        Link(
            Field("F2"), Field("F4"), GreaterEqual(Variable("F2"), Number(200)), first=First("F2"),
        ),
        Link(Field("F3"), FINAL, Equal(Variable("F3"), Variable("ONE"))),
        Link(Field("F4"), FINAL),
    ],
    {
        Field("F1"): Opaque(),
        Field("F2"): MODULAR_INTEGER,
        Field("F3"): ENUMERATION,
        Field("F4"): RANGE_INTEGER,
    },
)


M_SMPL_REF_DERI = UnprovenDerivedMessage(
    "P.Smpl_Ref_Deri",
    M_SMPL_REF,
    [Link(INITIAL, Field("NR")), Link(Field("NR"), FINAL)],
    {Field("NR"): deepcopy(M_NO_REF_DERI)},
)


def assert_type(instance: Type, regex: str) -> None:
    with pytest.raises(RecordFluxError, match=regex):
        instance.error.propagate()


def assert_message(actual: Message, expected: Message, msg: str = None) -> None:
    msg = f"{expected.full_name} - {msg}" if msg else expected.full_name
    assert actual.full_name == expected.full_name, msg
    assert actual.structure == expected.structure, msg
    assert actual.types == expected.types, msg
    assert actual.fields == expected.fields, msg


def test_type_name() -> None:
    t = ModularInteger("Package.Type_Name", Number(256))
    assert t.name == "Type_Name"
    assert t.package == ID("Package")
    assert_type(
        ModularInteger("X", Number(256), Location((10, 20))),
        r'^<stdin>:10:20: model: error: unexpected format of type name "X"$',
    )
    assert_type(
        ModularInteger("X.Y.Z", Number(256), Location((10, 20))),
        '^<stdin>:10:20: model: error: unexpected format of type name "X.Y.Z"$',
    )


def test_modular_size() -> None:
    assert ModularInteger("P.T", Pow(Number(2), Number(32))).size == Number(32)


def test_modular_first() -> None:
    mod = ModularInteger("P.T", Pow(Number(2), Number(32)))
    assert mod.first == Number(0)
    assert mod.first.simplified() == Number(0)


def test_modular_last() -> None:
    mod = ModularInteger("P.T", Pow(Number(2), Number(32)))
    assert mod.last == Sub(Pow(Number(2), Number(32)), Number(1))
    assert mod.last.simplified() == Number(2 ** 32 - 1)


def test_modular_invalid_modulus_power_of_two() -> None:
    assert_type(
        ModularInteger("P.T", Number(255), Location((65, 3))),
        r'^<stdin>:65:3: model: error: modulus of "T" not power of two$',
    )


def test_modular_invalid_modulus_variable() -> None:
    assert_type(
        ModularInteger("P.T", Pow(Number(2), Variable("X")), Location((3, 23))),
        r'^<stdin>:3:23: model: error: modulus of "T" contains variable$',
    )


def test_modular_invalid_modulus_limit() -> None:
    assert_type(
        ModularInteger("P.T", Pow(Number(2), Number(128), Location((55, 3)))),
        r'^<stdin>:55:3: model: error: modulus of "T" exceeds limit \(2\*\*64\)$',
    )


def test_range_size() -> None:
    assert_equal(
        RangeInteger("P.T", Number(0), Sub(Pow(Number(2), Number(32)), Number(1)), Number(32)).size,
        Number(32),
    )


def test_range_invalid_first_variable() -> None:
    assert_type(
        RangeInteger("P.T", Add(Number(1), Variable("X")), Number(15), Number(4), Location((5, 3))),
        r'^<stdin>:5:3: model: error: first of "T" contains variable$',
    )


def test_range_invalid_last_variable() -> None:
    assert_type(
        RangeInteger("P.T", Number(1), Add(Number(1), Variable("X")), Number(4), Location((80, 6))),
        r'^<stdin>:80:6: model: error: last of "T" contains variable$',
    )


def test_range_invalid_last_exceeds_limit() -> None:
    assert_type_error(
        RangeInteger("P.T", Number(1), Pow(Number(2), Number(63)), Number(64)),
        r'^model: error: last of "T" exceeds limit \(2\*\*63 - 1\)$',
    )


def test_range_invalid_first_negative() -> None:
    assert_type(
        RangeInteger("P.T", Number(-1), Number(0), Number(1), Location((6, 4))),
        r'^<stdin>:6:4: model: error: first of "T" negative$',
    )


def test_range_invalid_range() -> None:
    assert_type(
        RangeInteger("P.T", Number(1), Number(0), Number(1), Location((10, 5))),
        r'^<stdin>:10:5: model: error: range of "T" negative$',
    )


def test_range_invalid_size_variable() -> None:
    assert_type(
        RangeInteger(
            "P.T", Number(0), Number(256), Add(Number(8), Variable("X")), Location((22, 4))
        ),
        r'^<stdin>:22:4: model: error: size of "T" contains variable$',
    )


def test_range_invalid_size_too_small() -> None:
    assert_type(
        RangeInteger("P.T", Number(0), Number(256), Number(8), Location((10, 4))),
        r'^<stdin>:10:4: model: error: size of "T" too small$',
    )


def test_range_invalid_size_exceeds_limit() -> None:
    # ISSUE: Componolit/RecordFlux#238
    assert_type(
        RangeInteger("P.T", Number(0), Number(256), Number(128), Location((50, 3))),
        r'^<stdin>:50:3: model: error: size of "T" exceeds limit \(2\*\*64\)$',
    )


def test_enumeration_invalid_size_variable() -> None:
    assert_type(
        Enumeration(
            "P.T", {"A": Number(1)}, Add(Number(8), Variable("X")), False, Location((34, 3))
        ),
        r'^<stdin>:34:3: model: error: size of "T" contains variable$',
    )


def test_enumeration_invalid_size_too_small() -> None:
    assert_type(
        Enumeration("P.T", {"A": Number(256)}, Number(8), False, Location((10, 5))),
        r'^<stdin>:10:5: model: error: size of "T" too small$',
    )


def test_enumeration_invalid_size_exceeds_limit() -> None:
    assert_type(
        Enumeration("P.T", {"A": Number(256)}, Number(128), False, Location((8, 20))),
        r'^<stdin>:8:20: model: error: size of "T" exceeds limit \(2\*\*64\)$',
    )


def test_enumeration_invalid_always_valid_aspect() -> None:
    with pytest.raises(
        RecordFluxError, match=r'^model: error: unnecessary always-valid aspect on "T"$'
    ):
        Enumeration("P.T", {"A": Number(0), "B": Number(1)}, Number(1), True).error.propagate()


def test_enumeration_invalid_literal() -> None:
    assert_type(
        Enumeration("P.T", {"A B": Number(1)}, Number(8), False, Location(((1, 2)))),
        r'^<stdin>:1:2: model: error: invalid literal name "A B" in "T"$',
    )
    assert_type(
        Enumeration("P.T", {"A.B": Number(1)}, Number(8), False, Location((6, 4))),
        r'^<stdin>:6:4: model: error: invalid literal name "A.B" in "T"$',
    )


def test_message_incorrect_name() -> None:
    assert_type(
        Message("M", [], {}, Location((10, 8))),
        '^<stdin>:10:8: model: error: unexpected format of type name "M"$',
    )


def test_message_missing_type() -> None:
    x = Field(ID("X", Location((5, 6))))
    structure = [Link(INITIAL, x), Link(x, FINAL)]

    assert_type(
        Message("P.M", structure, {}),
        '^<stdin>:5:6: model: error: missing type for field "X" in "P.M"$',
    )


def test_message_unused_type() -> None:
    t = ModularInteger("P.T", Number(2))

    structure = [
        Link(INITIAL, Field("X")),
        Link(Field("X"), FINAL),
    ]

    types = {Field("X"): t, Field(ID("Y", Location((5, 6)))): t}

    assert_type(
        Message("P.M", structure, types), '^<stdin>:5:6: model: error: unused field "Y" in "P.M"$'
    )


def test_message_ambiguous_first_field() -> None:
    t = ModularInteger("P.T", Number(2))

    structure = [
        Link(INITIAL, Field(ID("X", Location((2, 6))))),
        Link(INITIAL, Field(ID("Y", Location((3, 6))))),
        Link(Field("X"), Field("Z")),
        Link(Field("Y"), Field("Z")),
        Link(Field("Z"), FINAL),
    ]

    types = {Field("X"): t, Field("Y"): t, Field("Z"): t}

    assert_type(
        Message("P.M", structure, types, location=Location((1, 5))),
        '^<stdin>:1:5: model: error: ambiguous first field in "P.M"\n'
        "<stdin>:2:6: model: info: duplicate\n"
        "<stdin>:3:6: model: info: duplicate",
    )


def test_message_duplicate_link() -> None:
    t = ModularInteger("P.T", Number(2))
    x = Field(ID("X", location=Location((1, 5))))

    structure = [
        Link(INITIAL, x),
        Link(x, FINAL, location=Location((4, 42))),
        Link(x, FINAL, location=Location((5, 42))),
    ]

    types = {Field("X"): t}

    assert_type(
        Message("P.M", structure, types),
        f'^<stdin>:1:5: model: error: duplicate link from "X" to "{FINAL.name}"\n'
        f"<stdin>:4:42: model: info: duplicate link\n"
        f"<stdin>:5:42: model: info: duplicate link",
    )


def test_message_multiple_duplicate_links() -> None:
    t = ModularInteger("P.T", Number(2))
    x = Field(ID("X", location=Location((1, 5))))
    y = Field(ID("Y", location=Location((2, 5))))

    structure = [
        Link(INITIAL, x),
        Link(x, y),
        Link(x, FINAL, location=Location((3, 16))),
        Link(x, FINAL, location=Location((4, 18))),
        Link(y, FINAL, location=Location((5, 20))),
        Link(y, FINAL, location=Location((6, 22))),
    ]

    types = {Field("X"): t, Field("Y"): t}

    assert_type(
        Message("P.M", structure, types),
        f'^<stdin>:1:5: model: error: duplicate link from "X" to "{FINAL.name}"\n'
        f"<stdin>:3:16: model: info: duplicate link\n"
        f"<stdin>:4:18: model: info: duplicate link\n"
        f'<stdin>:2:5: model: error: duplicate link from "Y" to "{FINAL.name}"\n'
        f"<stdin>:5:20: model: info: duplicate link\n"
        f"<stdin>:6:22: model: info: duplicate link",
    )


def test_message_unreachable_field() -> None:
    structure = [
        Link(INITIAL, Field("X")),
        Link(Field("X"), Field("Z")),
        Link(Field(ID("Y", Location((20, 3)))), Field("Z")),
        Link(Field("Z"), FINAL),
    ]

    types = {Field("X"): BOOLEAN, Field("Y"): BOOLEAN, Field("Z"): BOOLEAN}

    assert_type(
        Message("P.M", structure, types),
        '^<stdin>:20:3: model: error: unreachable field "Y" in "P.M"$',
    )


def test_message_cycle() -> None:
    t = ModularInteger("P.T", Number(2))

    structure = [
        Link(INITIAL, Field("X")),
        Link(Field(ID("X", Location((3, 5)))), Field("Y")),
        Link(Field(ID("Y", Location((3, 5)))), Field("Z")),
        Link(Field(ID("Z", Location((3, 5)))), Field("X")),
        Link(Field("X"), FINAL),
    ]

    types = {Field("X"): t, Field("Y"): t, Field("Z"): t}

    assert_type(
        Message("P.M", structure, types, Location((10, 5))),
        '^<stdin>:10:5: model: error: structure of "P.M" contains cycle'
        # We cannot detect cycles, c.f. Componolit/RecordFlux#256
        # '\n'
        # '<stdin>:3:5: model: info: field "X" links to "Y"\n'
        # '<stdin>:4:5: model: info: field "Y" links to "Z"\n'
        # '<stdin>:5:5: model: info: field "Z" links to "X"\n',
    )


def test_message_fields() -> None:
    assert_equal(
        ETHERNET_FRAME.fields,
        (
            Field("Destination"),
            Field("Source"),
            Field("Type_Length_TPID"),
            Field("TPID"),
            Field("TCI"),
            Field("Type_Length"),
            Field("Payload"),
        ),
    )


def test_message_definite_fields() -> None:
    assert_equal(
        ETHERNET_FRAME.definite_fields,
        (
            Field("Destination"),
            Field("Source"),
            Field("Type_Length_TPID"),
            Field("Type_Length"),
            Field("Payload"),
        ),
    )


def test_message_field_condition() -> None:
    assert_equal(ETHERNET_FRAME.field_condition(INITIAL), TRUE)
    assert_equal(
        ETHERNET_FRAME.field_condition(Field("TPID")),
        Equal(Variable("Type_Length_TPID"), Number(33024, 16)),
    )
    assert_equal(
        ETHERNET_FRAME.field_condition(Field("Type_Length")),
        Or(
            NotEqual(Variable("Type_Length_TPID"), Number(33024, 16)),
            Equal(Variable("Type_Length_TPID"), Number(33024, 16)),
        ),
    )
    assert_equal(
        ETHERNET_FRAME.field_condition(Field("Payload")),
        Or(
            And(
                Or(
                    NotEqual(Variable("Type_Length_TPID"), Number(33024, 16)),
                    Equal(Variable("Type_Length_TPID"), Number(33024, 16)),
                ),
                LessEqual(Variable("Type_Length"), Number(1500)),
            ),
            And(
                Or(
                    NotEqual(Variable("Type_Length_TPID"), Number(33024, 16)),
                    Equal(Variable("Type_Length_TPID"), Number(33024, 16)),
                ),
                GreaterEqual(Variable("Type_Length"), Number(1536)),
            ),
        ),
    )


def test_message_incoming() -> None:
    assert_equal(ETHERNET_FRAME.incoming(INITIAL), [])
    assert_equal(
        ETHERNET_FRAME.incoming(Field("Type_Length")),
        [
            Link(
                Field("Type_Length_TPID"),
                Field("Type_Length"),
                NotEqual(Variable("Type_Length_TPID"), Number(0x8100, 16)),
                first=First("Type_Length_TPID"),
            ),
            Link(Field("TCI"), Field("Type_Length")),
        ],
    )
    assert_equal(
        ETHERNET_FRAME.incoming(FINAL),
        [
            Link(
                Field("Payload"),
                FINAL,
                And(
                    GreaterEqual(Div(Length("Payload"), Number(8)), Number(46)),
                    LessEqual(Div(Length("Payload"), Number(8)), Number(1500)),
                ),
            )
        ],
    )


def test_message_outgoing() -> None:
    assert_equal(ETHERNET_FRAME.outgoing(INITIAL), [Link(INITIAL, Field("Destination"))])
    assert_equal(ETHERNET_FRAME.outgoing(Field("Type_Length")), ETHERNET_FRAME.structure[7:9])
    assert_equal(ETHERNET_FRAME.outgoing(FINAL), [])


def test_message_direct_predecessors() -> None:
    assert_equal(ETHERNET_FRAME.direct_predecessors(INITIAL), [])
    assert_equal(
        ETHERNET_FRAME.direct_predecessors(Field("Type_Length")),
        [Field("Type_Length_TPID"), Field("TCI")],
    )
    assert_equal(ETHERNET_FRAME.direct_predecessors(FINAL), [Field("Payload")])


def test_message_direct_successors() -> None:
    assert_equal(ETHERNET_FRAME.direct_successors(INITIAL), [Field("Destination")])
    assert_equal(ETHERNET_FRAME.direct_successors(Field("Type_Length")), [Field("Payload")])
    assert_equal(ETHERNET_FRAME.direct_successors(FINAL), [])


def test_message_definite_predecessors() -> None:
    assert_equal(
        ETHERNET_FRAME.definite_predecessors(FINAL),
        (
            Field("Destination"),
            Field("Source"),
            Field("Type_Length_TPID"),
            Field("Type_Length"),
            Field("Payload"),
        ),
    )
    assert_equal(
        ETHERNET_FRAME.definite_predecessors(Field("TCI")),
        (Field("Destination"), Field("Source"), Field("Type_Length_TPID"), Field("TPID")),
    )


def test_message_predecessors() -> None:
    assert_equal(
        ETHERNET_FRAME.predecessors(FINAL),
        (
            Field("Destination"),
            Field("Source"),
            Field("Type_Length_TPID"),
            Field("TPID"),
            Field("TCI"),
            Field("Type_Length"),
            Field("Payload"),
        ),
    )
    assert_equal(
        ETHERNET_FRAME.predecessors(Field("TCI")),
        (Field("Destination"), Field("Source"), Field("Type_Length_TPID"), Field("TPID")),
    )
    assert_equal(ETHERNET_FRAME.predecessors(Field("Destination")), ())
    assert_equal(ETHERNET_FRAME.predecessors(INITIAL), ())


def test_message_successors() -> None:
    assert_equal(
        ETHERNET_FRAME.successors(INITIAL),
        (
            Field("Destination"),
            Field("Source"),
            Field("Type_Length_TPID"),
            Field("TPID"),
            Field("TCI"),
            Field("Type_Length"),
            Field("Payload"),
        ),
    )
    assert_equal(
        ETHERNET_FRAME.successors(Field("Source")),
        (
            Field("Type_Length_TPID"),
            Field("TPID"),
            Field("TCI"),
            Field("Type_Length"),
            Field("Payload"),
        ),
    )
    assert_equal(
        ETHERNET_FRAME.successors(Field("TPID")),
        (Field("TCI"), Field("Type_Length"), Field("Payload")),
    )
    assert_equal(ETHERNET_FRAME.successors(Field("Payload")), ())
    assert_equal(ETHERNET_FRAME.successors(FINAL), ())


def test_message_nonexistent_variable() -> None:
    mod_type = ModularInteger("P.MT", Pow(Number(2), Number(32)))
    enum_type = Enumeration("P.ET", {"Val1": Number(0), "Val2": Number(1)}, Number(8), True)
    structure = [
        Link(INITIAL, Field("F1")),
        Link(
            Field("F1"),
            Field("F2"),
            Equal(Variable("F1"), Variable("Val3", location=Location((444, 55)))),
        ),
        Link(Field("F2"), FINAL),
    ]

    types = {Field("F1"): enum_type, Field("F2"): mod_type}
    assert_type(
        Message("P.M", structure, types),
        '^<stdin>:444:55: model: error: undefined variable "Val3" referenced',
    )


def test_message_subsequent_variable() -> None:
    f1 = Field("F1")
    f2 = Field("F2")
    t = ModularInteger("P.T", Pow(Number(2), Number(32)))
    structure = [
        Link(INITIAL, f1),
        Link(f1, f2, Equal(Variable("F2", location=Location((1024, 57))), Number(42))),
        Link(f2, FINAL),
    ]

    types = {Field("F1"): t, Field("F2"): t}
    assert_type(
        Message("P.M", structure, types),
        '^<stdin>:1024:57: model: error: subsequent field "F2" referenced',
    )


def test_message_invalid_use_of_length_attribute() -> None:
    structure = [
        Link(INITIAL, Field("F1")),
        Link(Field("F1"), FINAL, Equal(Length("F1"), Number(32), Location((400, 17)))),
    ]
    types = {Field("F1"): MODULAR_INTEGER}
    assert_type(
        Message("P.M", structure, types),
        r'^<stdin>:400:17: model: error: invalid use of length attribute for "F1"$',
    )


def test_message_invalid_relation_to_aggregate() -> None:
    structure = [
        Link(INITIAL, Field("F1"), length=Number(16)),
        Link(
            Field("F1"),
            FINAL,
            LessEqual(Variable("F1"), Aggregate(Number(1), Number(2)), Location((100, 20))),
        ),
    ]
    types = {Field("F1"): Opaque()}
    assert_type(
        Message("P.M", structure, types),
        r'^<stdin>:100:20: model: error: invalid relation " <= " to aggregate$',
    )


def test_message_invalid_element_in_relation_to_aggregate() -> None:
    structure = [
        Link(INITIAL, Field("F1")),
        Link(
            Field("F1"),
            FINAL,
            Equal(Variable("F1"), Aggregate(Number(1), Number(2)), Location((14, 7))),
        ),
    ]
    types = {Field("F1"): MODULAR_INTEGER}
    assert_type(
        Message("P.M", structure, types),
        r'^<stdin>:14:7: model: error: invalid relation between "F1" and aggregate$',
    )


def test_message_field_size() -> None:
    message = Message(
        "P.M",
        [Link(INITIAL, Field("F")), Link(Field("F"), FINAL)],
        {Field("F"): MODULAR_INTEGER},
        Location((30, 10)),
    )

    assert message.field_size(FINAL) == Number(0)
    assert message.field_size(Field("F")) == Number(8)

    with pytest.raises(AssertionError, match='^field "X" not found$'):
        message.field_size(Field("X"))
        message.error.propagate()


def test_message_copy() -> None:
    message = Message(
        "P.M", [Link(INITIAL, Field("F")), Link(Field("F"), FINAL)], {Field("F"): MODULAR_INTEGER},
    )
    assert_equal(
        message.copy(identifier="A.B"),
        Message(
            "A.B",
            [Link(INITIAL, Field("F")), Link(Field("F"), FINAL)],
            {Field("F"): MODULAR_INTEGER},
        ),
    )
    assert_equal(
        message.copy(
            structure=[Link(INITIAL, Field("C")), Link(Field("C"), FINAL)],
            types={Field("C"): RANGE_INTEGER},
        ),
        Message(
            "P.M",
            [Link(INITIAL, Field("C")), Link(Field("C"), FINAL)],
            {Field("C"): RANGE_INTEGER},
        ),
    )


def test_message_proven() -> None:
    message = Message(
        "P.M", [Link(INITIAL, Field("F")), Link(Field("F"), FINAL)], {Field("F"): MODULAR_INTEGER},
    )
    assert message.proven() == message


def test_derived_message_incorrect_base_name() -> None:
    assert_type(
        DerivedMessage("P.M", Message("M", [], {}, location=Location((40, 8)))),
        '^<stdin>:40:8: model: error: unexpected format of type name "M"$',
    )


def test_derived_message_proven() -> None:
    message = DerivedMessage(
        "P.M",
        Message(
            "X.M",
            [Link(INITIAL, Field("F")), Link(Field("F"), FINAL)],
            {Field("F"): MODULAR_INTEGER},
        ),
    )
    assert message.proven() == message


def test_prefixed_message() -> None:
    assert_equal(
        UnprovenMessage(
            "P.M",
            [
                Link(INITIAL, Field("F1")),
                Link(
                    Field("F1"),
                    Field("F2"),
                    LessEqual(Variable("F1"), Number(100)),
                    first=First("F1"),
                ),
                Link(
                    Field("F1"),
                    Field("F3"),
                    GreaterEqual(Variable("F1"), Number(200)),
                    first=First("F1"),
                ),
                Link(Field("F2"), FINAL),
                Link(Field("F3"), Field("F4"), length=Variable("F3")),
                Link(Field("F4"), FINAL),
            ],
            {
                Field("F1"): deepcopy(MODULAR_INTEGER),
                Field("F2"): deepcopy(MODULAR_INTEGER),
                Field("F3"): deepcopy(RANGE_INTEGER),
                Field("F4"): Opaque(),
            },
        ).prefixed("X_"),
        UnprovenMessage(
            "P.M",
            [
                Link(INITIAL, Field("X_F1")),
                Link(
                    Field("X_F1"),
                    Field("X_F2"),
                    LessEqual(Variable("X_F1"), Number(100)),
                    first=First("X_F1"),
                ),
                Link(
                    Field("X_F1"),
                    Field("X_F3"),
                    GreaterEqual(Variable("X_F1"), Number(200)),
                    first=First("X_F1"),
                ),
                Link(Field("X_F2"), FINAL),
                Link(Field("X_F3"), Field("X_F4"), length=Variable("X_F3")),
                Link(Field("X_F4"), FINAL),
            ],
            {
                Field("X_F1"): deepcopy(MODULAR_INTEGER),
                Field("X_F2"): deepcopy(MODULAR_INTEGER),
                Field("X_F3"): deepcopy(RANGE_INTEGER),
                Field("X_F4"): Opaque(),
            },
        ),
    )


def test_merge_message_simple() -> None:
    assert_equal(
        deepcopy(M_SMPL_REF).merged(),
        UnprovenMessage(
            "P.Smpl_Ref",
            [
                Link(INITIAL, Field("NR_F1"), length=Number(16)),
                Link(Field("NR_F3"), FINAL, Equal(Variable("NR_F3"), Variable("P.ONE"))),
                Link(Field("NR_F4"), FINAL),
                Link(Field("NR_F1"), Field("NR_F2")),
                Link(
                    Field("NR_F2"),
                    Field("NR_F3"),
                    LessEqual(Variable("NR_F2"), Number(100)),
                    first=First("NR_F2"),
                ),
                Link(
                    Field("NR_F2"),
                    Field("NR_F4"),
                    GreaterEqual(Variable("NR_F2"), Number(200)),
                    first=First("NR_F2"),
                ),
            ],
            {
                Field("NR_F1"): Opaque(),
                Field("NR_F2"): deepcopy(MODULAR_INTEGER),
                Field("NR_F3"): deepcopy(ENUMERATION),
                Field("NR_F4"): deepcopy(RANGE_INTEGER),
            },
        ),
    )


def test_merge_message_complex() -> None:
    assert_equal(
        deepcopy(M_CMPLX_REF).merged(),
        UnprovenMessage(
            "P.Cmplx_Ref",
            [
                Link(INITIAL, Field("F1")),
                Link(Field("F1"), Field("F2"), LessEqual(Variable("F1"), Number(100))),
                Link(Field("F1"), Field("F3"), GreaterEqual(Variable("F1"), Number(200))),
                Link(
                    Field("F2"),
                    Field("NR_F1"),
                    LessEqual(Variable("F1"), Number(10)),
                    length=Number(16),
                ),
                Link(
                    Field("F3"),
                    Field("NR_F1"),
                    GreaterEqual(Variable("F1"), Number(220)),
                    length=Number(16),
                ),
                Link(
                    Field("NR_F3"),
                    Field("F5"),
                    And(
                        LessEqual(Variable("F1"), Number(100)),
                        Equal(Variable("NR_F3"), Variable("P.ONE")),
                    ),
                ),
                Link(Field("NR_F4"), Field("F5"), LessEqual(Variable("F1"), Number(100))),
                Link(
                    Field("NR_F3"),
                    Field("F6"),
                    And(
                        GreaterEqual(Variable("F1"), Number(200)),
                        Equal(Variable("NR_F3"), Variable("P.ONE")),
                    ),
                ),
                Link(Field("NR_F4"), Field("F6"), GreaterEqual(Variable("F1"), Number(200))),
                Link(Field("F5"), FINAL),
                Link(Field("F6"), FINAL),
                Link(Field("NR_F1"), Field("NR_F2")),
                Link(
                    Field("NR_F2"),
                    Field("NR_F3"),
                    LessEqual(Variable("NR_F2"), Number(100)),
                    first=First("NR_F2"),
                ),
                Link(
                    Field("NR_F2"),
                    Field("NR_F4"),
                    GreaterEqual(Variable("NR_F2"), Number(200)),
                    first=First("NR_F2"),
                ),
            ],
            {
                Field("F1"): deepcopy(MODULAR_INTEGER),
                Field("F2"): deepcopy(MODULAR_INTEGER),
                Field("F3"): deepcopy(RANGE_INTEGER),
                Field("NR_F1"): Opaque(),
                Field("NR_F2"): deepcopy(MODULAR_INTEGER),
                Field("NR_F3"): deepcopy(ENUMERATION),
                Field("NR_F4"): deepcopy(RANGE_INTEGER),
                Field("F5"): deepcopy(MODULAR_INTEGER),
                Field("F6"): deepcopy(RANGE_INTEGER),
            },
        ),
    )


def test_merge_message_recursive() -> None:
    assert_equal(
        deepcopy(M_DBL_REF).merged(),
        UnprovenMessage(
            "P.Dbl_Ref",
            [
                Link(INITIAL, Field("SR_NR_F1"), length=Number(16)),
                Link(
                    Field("SR_NR_F3"),
                    Field("NR_F1"),
                    Equal(Variable("SR_NR_F3"), Variable("P.ONE")),
                    length=Number(16),
                ),
                Link(Field("SR_NR_F4"), Field("NR_F1"), length=Number(16)),
                Link(Field("NR_F3"), FINAL, Equal(Variable("NR_F3"), Variable("P.ONE"))),
                Link(Field("NR_F4"), FINAL),
                Link(Field("SR_NR_F1"), Field("SR_NR_F2")),
                Link(
                    Field("SR_NR_F2"),
                    Field("SR_NR_F3"),
                    LessEqual(Variable("SR_NR_F2"), Number(100)),
                    first=First("SR_NR_F2"),
                ),
                Link(
                    Field("SR_NR_F2"),
                    Field("SR_NR_F4"),
                    GreaterEqual(Variable("SR_NR_F2"), Number(200)),
                    first=First("SR_NR_F2"),
                ),
                Link(Field("NR_F1"), Field("NR_F2")),
                Link(
                    Field("NR_F2"),
                    Field("NR_F3"),
                    LessEqual(Variable("NR_F2"), Number(100)),
                    first=First("NR_F2"),
                ),
                Link(
                    Field("NR_F2"),
                    Field("NR_F4"),
                    GreaterEqual(Variable("NR_F2"), Number(200)),
                    first=First("NR_F2"),
                ),
            ],
            {
                Field("SR_NR_F1"): Opaque(),
                Field("SR_NR_F2"): deepcopy(MODULAR_INTEGER),
                Field("SR_NR_F3"): deepcopy(ENUMERATION),
                Field("SR_NR_F4"): deepcopy(RANGE_INTEGER),
                Field("NR_F1"): Opaque(),
                Field("NR_F2"): deepcopy(MODULAR_INTEGER),
                Field("NR_F3"): deepcopy(ENUMERATION),
                Field("NR_F4"): deepcopy(RANGE_INTEGER),
            },
        ),
    )


def test_merge_message_simple_derived() -> None:
    assert_equal(
        deepcopy(M_SMPL_REF_DERI).merged(),
        UnprovenDerivedMessage(
            "P.Smpl_Ref_Deri",
            M_SMPL_REF,
            [
                Link(INITIAL, Field("NR_F1"), length=Number(16)),
                Link(Field("NR_F3"), FINAL, Equal(Variable("NR_F3"), Variable("P.ONE"))),
                Link(Field("NR_F4"), FINAL),
                Link(Field("NR_F1"), Field("NR_F2")),
                Link(
                    Field("NR_F2"),
                    Field("NR_F3"),
                    LessEqual(Variable("NR_F2"), Number(100)),
                    first=First("NR_F2"),
                ),
                Link(
                    Field("NR_F2"),
                    Field("NR_F4"),
                    GreaterEqual(Variable("NR_F2"), Number(200)),
                    first=First("NR_F2"),
                ),
            ],
            {
                Field("NR_F1"): Opaque(),
                Field("NR_F2"): deepcopy(MODULAR_INTEGER),
                Field("NR_F3"): deepcopy(ENUMERATION),
                Field("NR_F4"): deepcopy(RANGE_INTEGER),
            },
        ),
    )


def test_merge_message_error_name_conflict() -> None:

    m2_f2 = Field(ID("F2", Location((10, 5))))

    m2 = UnprovenMessage(
        "P.M2",
        [Link(INITIAL, m2_f2), Link(m2_f2, FINAL)],
        {Field("F2"): MODULAR_INTEGER},
        Location((15, 3)),
    )

    m1_f1 = Field(ID("F1", Location((20, 8))))
    m1_f1_f2 = Field(ID("F1_F2", Location((30, 5))))

    m1 = UnprovenMessage(
        "P.M1",
        [Link(INITIAL, m1_f1), Link(m1_f1, m1_f1_f2), Link(m1_f1_f2, FINAL)],
        {Field("F1"): m2, Field("F1_F2"): MODULAR_INTEGER},
        Location((2, 9)),
    )

    assert_type(
        m1.merged(),
        r"^"
        r'<stdin>:30:5: model: error: name conflict for "F1_F2" in "P.M1"\n'
        r'<stdin>:15:3: model: info: when merging message "P.M2"\n'
        r'<stdin>:20:8: model: info: into field "F1"$',
    )


def test_refinement_invalid_package() -> None:
    assert_type(
        Refinement(ID("A.B", Location((22, 10))), ETHERNET_FRAME, Field("Payload"), ETHERNET_FRAME),
        r'^<stdin>:22:10: model: error: unexpected format of package name "A.B"$',
    )


def test_field_locations() -> None:

    f2 = Field(ID("F2", Location((2, 2))))
    f3 = Field(ID("F3", Location((3, 2))))

    message = UnprovenMessage(
        "P.M",
        [Link(INITIAL, f2), Link(f2, f3), Link(f3, FINAL)],
        {Field("F2"): MODULAR_INTEGER, Field("F3"): MODULAR_INTEGER},
        Location((17, 9)),
    )
    assert message.fields == (f2, f3)


def test_opaque_aggregate_out_of_range() -> None:
    f = Field("F")
    message = Message(
        "P.M",
        [
            Link(INITIAL, f, length=Number(24)),
            Link(
                f,
                FINAL,
                condition=Equal(
                    Variable("F"),
                    Aggregate(Number(1), Number(2), Number(256, location=Location((44, 3)))),
                ),
            ),
        ],
        {Field("F"): Opaque()},
    )

    assert_type(
        message, r"^<stdin>:44:3: model: error: aggregate element out of range 0 .. 255",
    )


def test_array_aggregate_out_of_range() -> None:
    array_type = Array("P.Array", ModularInteger("P.Element", Number(64)))

    f = Field("F")
    message = Message(
        "P.M",
        [
            Link(INITIAL, f, length=Number(18)),
            Link(
                f,
                FINAL,
                condition=Equal(
                    Variable("F"),
                    Aggregate(Number(1), Number(2), Number(64, location=Location((44, 3)))),
                ),
            ),
        ],
        {Field("F"): array_type},
    )
    assert_type(message, r"^<stdin>:44:3: model: error: aggregate element out of range 0 .. 63")


def test_array_aggregate_invalid_element_type() -> None:
    inner = Message(
        "P.I", [Link(INITIAL, Field("F")), Link(Field("F"), FINAL)], {Field("F"): MODULAR_INTEGER},
    )
    array_type = Array("P.Array", inner)

    f = Field("F")
    message = Message(
        "P.M",
        [
            Link(INITIAL, f, length=Number(18)),
            Link(
                f,
                FINAL,
                condition=Equal(
                    Variable("F"), Aggregate(Number(1), Number(2), Number(64)), Location((90, 10)),
                ),
            ),
        ],
        {Field("F"): array_type},
    )

    assert_type(
        message,
        r"^<stdin>:90:10: model: error: invalid array element type"
        ' "P.I" for aggregate comparison$',
    )


class NewType(Type):
    pass


@pytest.mark.skipif(not __debug__, reason="depends on contract")
def test_invalid_message_field_type() -> None:
    with pytest.raises(ViolationError, match=r"rflx/model.py"):
        Message(
            "P.M", [Link(INITIAL, Field("F")), Link(Field("F"), FINAL)], {Field("F"): NewType("T")},
        )
