"""Runnable demo of compile-time Fibonacci, with a link to linear allocation.

Run with:
    pixi run mojo -I . examples/metaprogramming/fibonacci_demo.mojo
"""

from std.memory.alloc import alloc, dealloc, Layout

from playground.metaprogramming import fib, fib_sequence


def main():
    comptime N = 10

    print("comptime: the compiler runs `fib[n]()` while building the binary.\n")

    # The whole sequence is materialised at compile time.
    comptime SEQ = fib_sequence[N]()
    print("fib_sequence[", N, "]() =", sep="", end=" ")
    comptime for i in range(N):
        print(SEQ[i], end=" " if i + 1 < N else "\n")

    # Proof it is compile-time: a type's size must be a constant.
    var buf = InlineArray[Int32, fib[N]()](fill=0)
    print("InlineArray[Int32, fib[", N, "]()] has length ", len(buf), sep="")

    # Bridge to linear types: the amount of heap we allocate is itself a
    # compile-time Fibonacci number, and the handle must still be released.
    comptime COUNT = fib[N]()
    var a = alloc(Layout[Int32](count=COUNT))
    var ptr = a.unsafe_ptr()
    for i in range(COUNT):
        (ptr + i).init_pointee_move(Int32(i))
    var total = Int32(0)
    for i in range(COUNT):
        total += ptr[i]
    dealloc(a^)  # linear handle consumed; checked by the compiler
    print(
        "allocated fib[",
        N,
        "]() = ",
        COUNT,
        " Int32s, sum 0..<",
        COUNT,
        " = ",
        total,
        sep="",
    )
