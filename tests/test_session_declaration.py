import pytest
from pyparsing import ParseException

from rflx.error import RecordFluxError
from rflx.expression import (
    FALSE,
    Argument,
    Channel,
    Field,
    PrivateDeclaration,
    Renames,
    Subprogram,
    SubprogramCall,
    Variable,
    VariableDeclaration,
)
from rflx.identifier import ID
from rflx.parser.session import SessionParser
from rflx.session import Session, SessionFile, State, Transition
from rflx.statement import Assignment


def test_simple_function_declaration() -> None:
    result = SessionParser.declaration().parseString(
        "Foo (Arg1 : Arg1_Type; Arg2 : Arg2_Type) return Foo_Type"
    )[0]
    expected = (
        ID("Foo"),
        Subprogram([Argument("Arg1", "Arg1_Type"), Argument("Arg2", "Arg2_Type")], "Foo_Type",),
    )
    assert result == expected


def test_invalid_function_name() -> None:
    with pytest.raises(ParseException):
        # pylint: disable=expression-not-assigned
        SessionParser.declaration().parseString(
            "Foo.Bar (Arg1 : Arg1_Type; Arg2 : Arg2_Type) return Foo_Type"
        )[0]


def test_invalid_parameter_name() -> None:
    with pytest.raises(ParseException):
        # pylint: disable=expression-not-assigned
        SessionParser.declaration().parseString(
            "Foo (Arg1 : Arg1_Type; Arg2.Invalid : Arg2_Type) return Foo_Type"
        )[0]


def test_private_variable_declaration() -> None:
    result = SessionParser.declaration().parseString("Hash_Context is private")[0]
    expected = (ID("Hash_Context"), PrivateDeclaration())
    assert result == expected


def test_parameterless_function_declaration() -> None:
    result = SessionParser.declaration().parseString("Foo return Foo_Type")[0]
    expected = (ID("Foo"), Subprogram([], "Foo_Type"))
    assert result == expected


def test_simple_variable_declaration() -> None:
    result = SessionParser.declaration().parseString(
        "Certificate_Authorities : TLS_Handshake.Certificate_Authorities"
    )[0]
    expected = (
        ID("Certificate_Authorities"),
        VariableDeclaration("TLS_Handshake.Certificate_Authorities"),
    )
    assert result == expected


def test_variable_declaration_with_initialization() -> None:
    result = SessionParser.declaration().parseString(
        "Certificate_Authorities_Received : Boolean := False"
    )[0]
    expected = (
        ID("Certificate_Authorities_Received"),
        VariableDeclaration("Boolean", FALSE),
    )
    assert result == expected


def test_renames() -> None:
    result = SessionParser.declaration().parseString(
        "Certificate_Message : TLS_Handshake.Certificate renames CCR_Handshake_Message.Payload"
    )[0]
    expected = (
        ID("Certificate_Message"),
        Renames("TLS_Handshake.Certificate", Field(Variable("CCR_Handshake_Message"), "Payload")),
    )
    assert result == expected


def test_channels() -> None:
    f = SessionFile()
    f.parse_string(
        "session",
        """
            channels:
                - name: Channel1_Read_Write
                  mode: Read_Write
                - name: Channel2_Read
                  mode: Read
                - name: Channel3_Write
                  mode: Write
            initial: START
            final: END
            states:
              - name: START
                transitions:
                  - target: END
                variables:
                  - "Local : Boolean"
                actions:
                  - Local := Write(Channel1_Read_Write, Read(Channel2_Read))
                  - Local := Write(Channel3_Write, Local)
              - name: END
        """,
    )
    expected = Session(
        name="session",
        initial="START",
        final="END",
        states=[
            State(
                name="START",
                transitions=[Transition(target="END")],
                declarations={ID("Local"): VariableDeclaration("Boolean")},
                actions=[
                    Assignment(
                        "Local",
                        SubprogramCall(
                            "Write",
                            [
                                Variable("Channel1_Read_Write"),
                                SubprogramCall("Read", [Variable("Channel2_Read")]),
                            ],
                        ),
                    ),
                    Assignment(
                        "Local",
                        SubprogramCall("Write", [Variable("Channel3_Write"), Variable("Local")],),
                    ),
                ],
            ),
            State(name="END"),
        ],
        declarations={
            "Channel1_Read_Write": Channel(read=True, write=True),
            "Channel2_Read": Channel(read=True, write=False),
            "Channel3_Write": Channel(read=False, write=True),
        },
    )
    assert f.sessions[0] == expected


def test_channel_with_invalid_mode() -> None:
    with pytest.raises(
        RecordFluxError,
        match="^session: error: channel Channel1_Read_Write has invalid mode Invalid",
    ):
        SessionFile().parse_string(
            "session",
            """
                channels:
                    - name: Channel1_Read_Write
                      mode: Invalid
                initial: START
                final: END
                states:
                  - name: START
                    transitions:
                      - target: END
                    variables:
                      - "Local : Boolean"
                    actions:
                      - Local := Read(Channel1_Read_Write)
                  - name: END
            """,
        )


def test_channel_without_name() -> None:
    with pytest.raises(RecordFluxError, match="^session: error: channel 0 has no name"):
        SessionFile().parse_string(
            "session",
            """
                channels:
                    - mode: Read_Write
                initial: START
                final: END
                states:
                  - name: START
                    transitions:
                      - target: END
                  - name: END
            """,
        )


def test_channel_without_mode() -> None:
    with pytest.raises(
        RecordFluxError, match="^session: error: channel Channel_Without_Mode has no mode"
    ):
        SessionFile().parse_string(
            "session",
            """
                channels:
                    - name: Channel_Without_Mode
                initial: START
                final: END
                states:
                  - name: START
                    transitions:
                      - target: END
                  - name: END
            """,
        )
