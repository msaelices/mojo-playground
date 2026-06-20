"""Compile-time evaluation: Fibonacci computed by the compiler.

`n` is a parameter (`fib[n]()`), so the recursion runs during compilation and
the result is baked in as a constant -- provably so, since it can be used where
a constant is required, e.g. as a type's size: `InlineArray[Int, fib[10]()]`.
"""


def fib[n: Int]() -> Int:
    """The n-th Fibonacci number, via parameter recursion (`comptime if`)."""
    comptime if n < 2:
        return n
    else:
        return fib[n - 1]() + fib[n - 2]()


def fib_sequence[n: Int]() -> InlineArray[Int, n]:
    """The first `n` Fibonacci numbers; the `InlineArray[Int, n]` return type is
    sized by the compile-time parameter, so it fits in a `comptime` binding."""
    var arr = InlineArray[Int, n](fill=0)
    comptime if n >= 2:
        arr[1] = 1
    comptime for i in range(2, n):
        arr[i] = arr[i - 1] + arr[i - 2]
    return arr
