from std.testing import assert_equal

from playground.variants.cells import Cell, describe, sum_ints
from playground.variants.reassign import reassign


def test_describe() raises:
    assert_equal(describe(Cell(42)), "int: 42")
    assert_equal(describe(Cell(3.5)), "float: 3.5")
    assert_equal(describe(Cell(String("hi"))), "string: hi")
    assert_equal(describe(Cell(True)), "bool: True")


def test_sum_ints() raises:
    var row: List[Cell] = [Cell(10), Cell(2.0), Cell(String("x")), Cell(5)]
    assert_equal(sum_ints(row), 15)


def test_reassign() raises:
    assert_equal(reassign(), "int 1 -> string now text")


def main() raises:
    test_describe()
    test_sum_ints()
    test_reassign()
