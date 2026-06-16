"""Runnable demo of compile-time Fibonacci, with a link to linear allocation.

Run with:
    pixi run mojo -I . examples/metaprogramming/fibonacci_demo.mojo
"""

from std.memory.alloc import alloc, dealloc, Layout


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


def main():
    comptime N = 10
    # The array length is a Fibonacci number computed at compile time.
    comptime LENGTH = fib[N]()

    print("comptime: the compiler runs `fib[n]()` while building the binary.\n")

    # The whole sequence is materialised at compile time.
    comptime SEQ = fib_sequence[N]()
    print("fib_sequence[", N, "]() =", sep="", end=" ")
    comptime for i in range(N):
        print(SEQ[i], end=" " if i + 1 < N else "\n")

    # Proof it is compile-time: LENGTH can be used where a constant is required.
    print("LENGTH = fib[", N, "]() = ", LENGTH, sep="")
    var buf = InlineArray[Int, LENGTH](fill=0)
    print("used as a type size: InlineArray[Int, LENGTH], len =", len(buf))

    # Bridge to linear types: we allocate LENGTH Ints and must release them.
    var a = alloc(Layout[Int](count=LENGTH))
    var data = a.unsafe_span()  # a list-like view over the allocation
    for i in range(LENGTH):
        data[i] = Int(i)

    var total: Int = 0
    for value in data:
        total += value
    dealloc(a^)  # linear handle consumed; checked by the compiler
    print(
        "allocated ", LENGTH, " Ints, sum 0..<", LENGTH, " = ", total, sep=""
    )
