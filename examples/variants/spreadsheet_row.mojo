"""Runnable demo of Variant: a mixed-type spreadsheet row.

Run with:
    pixi run mojo -I . examples/variants/spreadsheet_row.mojo
"""

from playground.variants.cells import Cell, describe, sum_ints
from playground.variants.reassign import reassign


def main():
    var row: List[Cell] = [
        Cell(42),
        Cell(3.14),
        Cell(String("name")),
        Cell(True),
    ]

    print("A row of mixed-type cells:")
    for ref cell in row:
        print("  ", describe(cell))

    print("sum of the Int cells:", sum_ints(row))
    print(reassign())
