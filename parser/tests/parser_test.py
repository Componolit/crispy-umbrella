import re

import librflxlang
import pytest

from language.lexer import rflx_lexer
from tests.utils import to_dict


def parse_buffer(
    data: str, rule: librflxlang.GrammarRule = librflxlang.GrammarRule.main_rule_rule
) -> librflxlang.AnalysisUnit:
    ctx = librflxlang.AnalysisContext()
    unit = ctx.get_from_buffer("text.rflx", data, rule=rule)
    del ctx
    return unit


def test_empty_file() -> None:
    unit = parse_buffer("")
    assert unit.root is None


def test_empty_package() -> None:
    unit = parse_buffer(
        """
            package Empty_Package is
            end Empty_Package;
        """,
    )
    assert to_dict(unit.root) == {
        "context_clause": [],
        "_kind": "Specification",
        "package_declaration": {
            "declarations": [],
            "end_identifier": {"_kind": "UnqualifiedID", "_value": "Empty_Package"},
            "identifier": {"_kind": "UnqualifiedID", "_value": "Empty_Package"},
            "_kind": "PackageNode",
        },
    }


def test_modular_type() -> None:
    unit = parse_buffer(
        """
            type Modular_Type is mod 2 ** 9;
        """,
        rule=librflxlang.GrammarRule.type_declaration_rule,
    )
    assert to_dict(unit.root) == {
        "_kind": "TypeDecl",
        "definition": {
            "_kind": "ModularTypeDef",
            "mod": {
                "_kind": "BinOp",
                "left": {"_kind": "NumericLiteral", "_value": "2"},
                "op": {"_kind": "OpPow", "_value": "**"},
                "right": {"_kind": "NumericLiteral", "_value": "9"},
            },
        },
        "identifier": {"_kind": "UnqualifiedID", "_value": "Modular_Type"},
    }


def test_checksum_attributes() -> None:
    unit = parse_buffer(
        """
            A'Valid_Checksum and B'Valid_Checksum;
        """,
        rule=librflxlang.GrammarRule.expression_rule,
    )
    assert to_dict(unit.root) == {
        "_kind": "BinOp",
        "left": {
            "_kind": "Attribute",
            "expression": {
                "_kind": "Variable",
                "identifier": {
                    "_kind": "ID",
                    "name": {"_kind": "UnqualifiedID", "_value": "A"},
                    "package": None,
                },
            },
            "kind": {"_kind": "AttrValidChecksum", "_value": "Valid_Checksum"},
        },
        "op": {"_kind": "OpAnd", "_value": "and"},
        "right": {
            "_kind": "Attribute",
            "expression": {
                "_kind": "Variable",
                "identifier": {
                    "_kind": "ID",
                    "name": {"_kind": "UnqualifiedID", "_value": "B"},
                    "package": None,
                },
            },
            "kind": {"_kind": "AttrValidChecksum", "_value": "Valid_Checksum"},
        },
    }


def test_operator_precedence() -> None:
    unit = parse_buffer(
        """
            A / 8 >= 46 and A / 8 <= 1500
        """,
        rule=librflxlang.GrammarRule.expression_rule,
    )
    assert to_dict(unit.root) == {
        "_kind": "BinOp",
        "left": {
            "_kind": "BinOp",
            "left": {
                "_kind": "BinOp",
                "left": {
                    "identifier": {
                        "_kind": "ID",
                        "name": {"_kind": "UnqualifiedID", "_value": "A"},
                        "package": None,
                    },
                    "_kind": "Variable",
                },
                "op": {"_kind": "OpDiv", "_value": "/"},
                "right": {"_kind": "NumericLiteral", "_value": "8"},
            },
            "op": {"_kind": "OpGe", "_value": ">="},
            "right": {"_kind": "NumericLiteral", "_value": "46"},
        },
        "op": {"_kind": "OpAnd", "_value": "and"},
        "right": {
            "_kind": "BinOp",
            "left": {
                "_kind": "BinOp",
                "left": {
                    "identifier": {
                        "_kind": "ID",
                        "name": {"_kind": "UnqualifiedID", "_value": "A"},
                        "package": None,
                    },
                    "_kind": "Variable",
                },
                "op": {"_kind": "OpDiv", "_value": "/"},
                "right": {"_kind": "NumericLiteral", "_value": "8"},
            },
            "op": {"_kind": "OpLe", "_value": "<="},
            "right": {"_kind": "NumericLiteral", "_value": "1500"},
        },
    }


def test_negative_number() -> None:
    unit = parse_buffer(
        """
            -16#20_000#
        """,
        rule=librflxlang.GrammarRule.expression_rule,
    )
    assert len(unit.diagnostics) == 0, "\n".join(str(d) for d in unit.diagnostics)
    assert to_dict(unit.root) == {
        "_kind": "Negation",
        "data": {"_kind": "NumericLiteral", "_value": "16#20_000#"},
    }


def test_selector_precedence1() -> None:
    unit = parse_buffer(
        "X.B = Z",
        rule=librflxlang.GrammarRule.extended_expression_rule,
    )
    assert len(unit.diagnostics) == 0, "\n".join(str(d) for d in unit.diagnostics)
    assert to_dict(unit.root) == {
        "_kind": "BinOp",
        "left": {
            "_kind": "SelectNode",
            "expression": {
                "_kind": "Variable",
                "identifier": {
                    "_kind": "ID",
                    "name": {"_kind": "UnqualifiedID", "_value": "X"},
                    "package": None,
                },
            },
            "selector": {
                "_kind": "UnqualifiedID",
                "_value": "B",
            },
        },
        "op": {"_kind": "OpEq", "_value": "="},
        "right": {
            "_kind": "Variable",
            "identifier": {
                "_kind": "ID",
                "name": {"_kind": "UnqualifiedID", "_value": "Z"},
                "package": None,
            },
        },
    }


def test_selector_precedence2() -> None:
    unit = parse_buffer(
        "X.B'Size",
        rule=librflxlang.GrammarRule.extended_expression_rule,
    )
    assert len(unit.diagnostics) == 0, "\n".join(str(d) for d in unit.diagnostics)
    assert to_dict(unit.root) == {
        "_kind": "Attribute",
        "expression": {
            "_kind": "SelectNode",
            "expression": {
                "_kind": "Variable",
                "identifier": {
                    "_kind": "ID",
                    "name": {"_kind": "UnqualifiedID", "_value": "X"},
                    "package": None,
                },
            },
            "selector": {"_kind": "UnqualifiedID", "_value": "B"},
        },
        "kind": {"_kind": "AttrSize", "_value": "Size"},
    }


def test_selector_precedence3() -> None:
    unit = parse_buffer(
        "X'Head.B",
        rule=librflxlang.GrammarRule.extended_expression_rule,
    )
    assert len(unit.diagnostics) == 0, "\n".join(str(d) for d in unit.diagnostics)
    assert to_dict(unit.root) == {
        "_kind": "SelectNode",
        "expression": {
            "_kind": "Attribute",
            "expression": {
                "_kind": "Variable",
                "identifier": {
                    "_kind": "ID",
                    "name": {"_kind": "UnqualifiedID", "_value": "X"},
                    "package": None,
                },
            },
            "kind": {"_kind": "AttrHead", "_value": "Head"},
        },
        "selector": {"_kind": "UnqualifiedID", "_value": "B"},
    }


def test_suffix_precedence() -> None:
    unit = parse_buffer(
        "2**X'Size",
        rule=librflxlang.GrammarRule.extended_expression_rule,
    )
    assert len(unit.diagnostics) == 0, "\n".join(str(d) for d in unit.diagnostics)
    assert to_dict(unit.root) == {
        "_kind": "BinOp",
        "left": {"_kind": "NumericLiteral", "_value": "2"},
        "op": {"_kind": "OpPow", "_value": "**"},
        "right": {
            "_kind": "Attribute",
            "expression": {
                "_kind": "Variable",
                "identifier": {
                    "_kind": "ID",
                    "name": {"_kind": "UnqualifiedID", "_value": "X"},
                    "package": None,
                },
            },
            "kind": {"_kind": "AttrSize", "_value": "Size"},
        },
    }


KEYWORDS = [l for l in rflx_lexer.literals_map if re.match("[A-Za-z_]+", l)]

KEYWORD_TESTS = [
    (keyword, t.format(keyword=keyword), r)
    for (t, r) in [
        (
            "for some {keyword} in Variable => {keyword} + 1",
            librflxlang.GrammarRule.quantified_expression_rule,
        ),
        (
            "[for {keyword} in Variable => {keyword} - 1 when {keyword} > 10]",
            librflxlang.GrammarRule.comprehension_rule,
        ),
        (
            "{keyword} (Variable + 1)",
            librflxlang.GrammarRule.call_rule,
        ),
        (
            "{keyword} => Data",
            librflxlang.GrammarRule.message_aggregate_association_rule,
        ),
        (
            "Data.{keyword}",
            librflxlang.GrammarRule.extended_suffix_rule,
        ),
        (
            "Data where {keyword} = 100",
            librflxlang.GrammarRule.extended_suffix_rule,
        ),
        (
            "{keyword} => True",
            librflxlang.GrammarRule.aspect_rule,
        ),
        (
            "then {keyword} with First => Previous'First if Previous > 100",
            librflxlang.GrammarRule.then_rule,
        ),
        (
            "{keyword} : Some::Type;",
            librflxlang.GrammarRule.component_item_rule,
        ),
        (
            "{keyword} => (1, 30..34)",
            librflxlang.GrammarRule.checksum_association_rule,
        ),
        (
            "{keyword}, {keyword}, Elem_1, Elem_2",
            librflxlang.GrammarRule.positional_enumeration_rule,
        ),
        (
            "{keyword} => 42",
            librflxlang.GrammarRule.element_value_association_rule,
        ),
        (
            "type {keyword} is new Other_Type",
            librflxlang.GrammarRule.type_declaration_rule,
        ),
        (
            "for Some::{keyword} use ({keyword} => Some::{keyword}) if {keyword} > 100",
            librflxlang.GrammarRule.type_refinement_rule,
        ),
        (
            "type {keyword} is private",
            librflxlang.GrammarRule.private_type_declaration_rule,
        ),
        (
            "{keyword} : Some::{keyword}",
            librflxlang.GrammarRule.function_parameter_rule,
        ),
        (
            "with function {keyword} return Some::{keyword}",
            librflxlang.GrammarRule.formal_function_declaration_rule,
        ),
        (
            "{keyword} : Channel with Readable, Writable",
            librflxlang.GrammarRule.channel_declaration_rule,
        ),
        (
            "with Initial => {keyword}, Final => {keyword}",
            librflxlang.GrammarRule.session_aspects_rule,
        ),
        (
            "{keyword} : Some::Type renames Fun",
            librflxlang.GrammarRule.renaming_declaration_rule,
        ),
        (
            "{keyword} : Some::Type := 42",
            librflxlang.GrammarRule.variable_declaration_rule,
        ),
        (
            "{keyword} := 42",
            librflxlang.GrammarRule.assignment_statement_rule,
        ),
        (
            "{keyword}'Append (42)",
            librflxlang.GrammarRule.list_attribute_rule,
        ),
        (
            "{keyword}'Reset",
            librflxlang.GrammarRule.reset_rule,
        ),
        (
            "then {keyword} if {keyword} = 42",
            librflxlang.GrammarRule.conditional_transition_rule,
        ),
        (
            'then {keyword} with Desc => "foo"',
            librflxlang.GrammarRule.transition_rule,
        ),
        (
            'then {keyword} with Desc => "foo"',
            librflxlang.GrammarRule.transition_rule,
        ),
        (
            "begin transition then {keyword} end {keyword}",
            librflxlang.GrammarRule.state_body_rule,
        ),
        (
            "state {keyword} is null state",
            librflxlang.GrammarRule.state_rule,
        ),
        (
            "generic session {keyword} with "
            "Initial => {keyword}, Final => {keyword} is begin end {keyword}",
            librflxlang.GrammarRule.session_declaration_rule,
        ),
        (
            """
                package {keyword} is
                end {keyword};
            """,
            librflxlang.GrammarRule.package_declaration_rule,
        ),
        (
            "with {keyword};",
            librflxlang.GrammarRule.context_item_rule,
        ),
    ]
    for keyword in [k.lower() for k in KEYWORDS] + [k.lower().capitalize() for k in KEYWORDS]
]


@pytest.mark.parametrize(
    "text,rule",
    [(t, r) for _, t, r in KEYWORD_TESTS],
    ids=[f"{k}->{r[:-5]}" for (k, _, r) in KEYWORD_TESTS],
)
def test_keyword_identifiers(text: str, rule: str) -> None:
    unit = parse_buffer(text, rule=rule)
    assert len(unit.diagnostics) == 0, text + "\n".join(str(d) for d in unit.diagnostics)
