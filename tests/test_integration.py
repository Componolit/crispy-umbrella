import unittest
from typing import List

from generator import Generator
from parser import Parser


class TestIntegration(unittest.TestCase):
    def setUp(self) -> None:
        self.testdir = "tests"
        self.maxDiff = None  # pylint: disable=invalid-name

    def fullpath(self, testfile: str) -> str:
        return self.testdir + "/" + testfile

    def assert_dissector(self, filenames: List[str]) -> None:
        parser = Parser()
        for filename in filenames:
            parser.parse(f'{self.fullpath(filename)}.rflx')

        generator = Generator()
        generator.generate_dissector(parser.pdus, parser.refinements)

        for unit in generator.units():
            unit_name = unit.package.name.lower().replace('.', '-')
            filename = unit_name + '.ads'
            with open(self.fullpath(filename), 'r') as f:
                self.assertEqual(unit.specification(), f.read())
            if unit.definition().strip():
                filename = unit_name + '.adb'
                with open(self.fullpath(filename), 'r') as f:
                    self.assertEqual(unit.definition(), f.read())

    def test_ethernet(self) -> None:
        self.assert_dissector(['ethernet'])

    def test_ipv4(self) -> None:
        self.assert_dissector(['ipv4'])

    def test_in_ethernet(self) -> None:
        self.assert_dissector(['ethernet', 'ipv4', 'in_ethernet'])

    def test_udp(self) -> None:
        self.assert_dissector(['udp'])

    def test_in_ipv4(self) -> None:
        self.assert_dissector(['ipv4', 'udp', 'in_ipv4'])

    def test_tlv(self) -> None:
        self.assert_dissector(['tlv'])
