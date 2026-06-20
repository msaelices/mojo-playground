"""Variant: one static type that can hold several concrete types.

A `Variant[A, B, ...]` is a type-safe tagged union. The variable stays
statically typed as the `Variant`, but the concrete value it holds may be any
of the listed types. Check the active type with `isa[T]()` and read it with the
typed subscript `v[T]`. This is how a single `List` can hold mixed values, the
closest Mojo analog to a Python list of heterogeneous objects.
"""

from std.utils import Variant

comptime Cell = Variant[Int, Float64, String, Bool]
"""A spreadsheet-like cell: an integer, float, string, or boolean."""


def describe(cell: Cell) -> String:
    """Render a cell as `"<type>: <value>"` by inspecting its active type."""
    if cell.isa[Int]():
        return String("int: ", cell[Int])
    elif cell.isa[Float64]():
        return String("float: ", cell[Float64])
    elif cell.isa[String]():
        return String("string: ", cell[String])
    else:
        return String("bool: ", cell[Bool])


def sum_ints(values: List[Cell]) -> Int:
    """Sum only the Int cells in a mixed list, skipping the other types."""
    var total = 0
    for ref item in values:
        if item.isa[Int]():
            total += item[Int]
    return total


def reassign() -> String:
    """A Variant variable can switch between its types while keeping a single
    static type: the same `a` holds an Int and then a String."""
    comptime StringOrInt = Variant[String, Int]
    var a: StringOrInt = 1
    var first = String("int ", a[Int])
    a = "now text"
    return String(first, " -> string ", a[String])
