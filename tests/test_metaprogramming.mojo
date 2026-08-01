from std.collections import List
from std.testing import assert_equal

from playground.metaprogramming import fib, fib_sequence


def test_fib() raises:
    assert_equal(fib[0](), 0)
    assert_equal(fib[1](), 1)
    assert_equal(fib[10](), 55)
    assert_equal(fib[15](), 610)


def test_fib_is_comptime() raises:
    # If `fib[10]()` were not a compile-time constant, this type would not
    # even compile: a type's size must be known at compile time.
    var buf = Array[Int32, fib[10]()](fill=0)
    assert_equal(len(buf), 55)


def test_fib_sequence() raises:
    # `seq` stays a compile-time value. Each element is pulled out into its own
    # `comptime` binding (`v`) so we compare a single `Int` rather than trying to
    # materialize the whole `Array` to runtime -- `Array` is no longer
    # `ImplicitlyCopyable`, so a bulk materialization would be rejected.
    comptime seq = fib_sequence[10]()
    var expected: List[Int] = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
    comptime for i in range(10):
        comptime v = seq[i]
        assert_equal(v, expected[i])


def main() raises:
    test_fib()
    test_fib_is_comptime()
    test_fib_sequence()
