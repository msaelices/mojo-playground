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
    var buf = InlineArray[Int32, fib[10]()](fill=0)
    assert_equal(len(buf), 55)


def test_fib_sequence() raises:
    comptime seq = fib_sequence[10]()
    var expected: InlineArray[Int, 10] = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
    for i in range(10):
        assert_equal(seq[i], expected[i])


def main() raises:
    test_fib()
    test_fib_is_comptime()
    test_fib_sequence()
