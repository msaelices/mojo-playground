"""Compile-time evaluation: Fibonacci computed entirely by the compiler.

`n` is a *parameter* (passed in square brackets, `fib[n]()`), so it is known
at compile time. The body runs during compilation: the recursion is unrolled
by the compiler and the result is baked into the binary as a constant.

The decisive proof that this is compile-time -- not a fast runtime call -- is
that the result can be used where the language *requires* a constant, e.g. as
the size of a type:

    var buf = InlineArray[Int32, fib[10]()](fill=0)   # type size = 55

If `fib[10]()` were a runtime value this would not compile. Few mainstream
languages let you run ordinary, recursive code at compile time like this.
"""


def fib[n: Int]() -> Int:
    """The n-th Fibonacci number, recursively, at compile time.

    Parameter recursion: `fib[n]` is resolved into `fib[n - 1]` and
    `fib[n - 2]` by the compiler via `comptime if`.
    """
    comptime if n < 2:
        return n
    else:
        return fib[n - 1]() + fib[n - 2]()


def fib_sequence[n: Int]() -> InlineArray[Int, n]:
    """The first `n` Fibonacci numbers as a stack array sized at compile time.

    The return type `InlineArray[Int, n]` itself depends on the compile-time
    parameter `n`, so the whole sequence can be materialised in a `comptime`
    binding.
    """
    var arr = InlineArray[Int, n](fill=0)
    comptime if n >= 2:
        arr[1] = 1
    for i in range(2, n):
        arr[i] = arr[i - 1] + arr[i - 2]
    return arr
