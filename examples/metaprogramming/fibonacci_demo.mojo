"""Runnable demo of compile-time Fibonacci, with a link to linear allocation.

Run with:
    pixi run mojo -I . examples/metaprogramming/fibonacci_demo.mojo
"""

from std.memory.alloc import alloc, dealloc, Layout

from playground.metaprogramming import fib, fib_sequence


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
    var buf = InlineArray[Int32, LENGTH](fill=0)
    print("used as a type size: InlineArray[Int32, LENGTH], len =", len(buf))

    # Bridge to linear types: we allocate LENGTH Int32s and must release them.
    var a = alloc(Layout[Int32](count=LENGTH))
    var data = a.unsafe_span()  # a list-like view over the allocation
    for i in range(LENGTH):
        data[i] = Int32(i)
    var total = Int32(0)
    for value in data:
        total += value
    dealloc(a^)  # linear handle consumed; checked by the compiler
    print(
        "allocated ", LENGTH, " Int32s, sum 0..<", LENGTH, " = ", total, sep=""
    )
