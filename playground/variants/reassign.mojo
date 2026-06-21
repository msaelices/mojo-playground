"""Reassigning a Variant: switching between its types at runtime.

A Variant variable keeps a single static type, but the concrete value it holds
may change to any of the enumerated types.
"""

from std.utils import Variant


def reassign() -> String:
    """The same `a` holds an Int and then a String, staying a Variant."""
    comptime StringOrInt = Variant[String, Int]
    var a: StringOrInt = 1
    var first = String("int ", a[Int])
    a = "now text"
    return String(first, " -> string ", a[String])
