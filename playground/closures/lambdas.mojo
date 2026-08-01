"""Lambda expressions: anonymous, single-expression closures.

Mojo now supports `lambda` expressions, which desugar to a nested `def`. As in
Python the body is a single expression (no `return`); unlike Python the
arguments are parenthesized and typed like a `def` signature, and a non-`None`
body needs an explicit return type:

    lambda (x: Int) -> Int: x + 1

The capture list `{...}` and the return type may each be elided: an omitted
capture list imm-captures the body's free variables (and is *thin* when there
are none), and an omitted return type defaults to `None`.

Thin vs. capturing -- the distinction that governs how a lambda is passed:

  * A *thin* (capture-free) lambda is a function value, exactly like a `def`
    referenced by name: it binds to a `comptime` and passes as a `thin`
    function-typed parameter (`def(Int) thin -> Int`). `apply_thin` and the
    `transform` / `reduce` higher-order functions below take lambdas this way.

  * A *capturing* lambda closes over surrounding variables and is a runtime
    closure value with no function type. You store it in a `var` and call it
    (see `scaled`); it cannot bind to a `comptime` parameter.
"""

from std.collections import List


def apply_thin[f: def(Int) thin -> Int](x: Int) -> Int:
    """Call a thin lambda passed as a compile-time function parameter."""
    return f(x)


def squared(n: Int) -> Int:
    """A thin lambda bound to a `var` and called directly."""
    var square = lambda (x: Int) -> Int: x * x
    return square(n)


def scaled(n: Int, factor: Int) -> Int:
    """A capturing lambda: it closes over `factor`, so it is a runtime closure
    value rather than a thin function."""
    var scale = lambda (x: Int) -> Int: x * factor
    return scale(n)


def transform[f: def(Int) thin -> Int](xs: List[Int]) -> List[Int]:
    """Map a thin lambda over a list, returning a new list."""
    var out = List[Int]()
    for x in xs:
        out.append(f(x))
    return out^


def reduce[f: def(Int, Int) thin -> Int](xs: List[Int], init: Int) -> Int:
    """Left-fold a list with a two-argument thin lambda."""
    var acc = init
    for x in xs:
        acc = f(acc, x)
    return acc


def sum_of_squares(xs: List[Int]) -> Int:
    """Compose the two higher-order functions with inline lambdas: square every
    element, then add them up."""
    var squares = transform[lambda (x: Int) -> Int: x * x](xs)
    return reduce[lambda (a: Int, b: Int) -> Int: a + b](squares, 0)
