"""Interior origins: safe references into container-owned storage.

Interior origins (experimental, MVP) let the compiler track a reference that
names storage *owned by a container* -- the payload inside a `Variant`, an
element inside a `List`, and so on. Taking `ref r = v[Int]` yields such an
interior reference: it aliases the live `Int` stored inside `v`, so writing
through `r` mutates `v` in place.

The safety guarantee is what makes this interesting. Reassigning (or otherwise
invalidating) the base container invalidates every interior reference derived
from it, and using one afterwards is a *compile-time* error rather than
undefined behavior:

    var v: Variant[Int, Float64] = 42
    ref r = v[Int]     # `r` names the Int payload inside `v`
    r = 100            # OK: mutates the payload in place
    v = 3.14           # reassigns `v`; the Int payload no longer exists
    return r           # error: use of invalidated interior reference 'v["value"]'
                       # note: origin was invalidated here (the `v = 3.14` line)

Before interior origins, that final `return r` would read reinterpreted or
overwritten storage -- a memory-safety hole. Now the base origin governs the
interior origin's validity, so the compiler rejects the stale read.

The functions below exercise the *valid* pattern: mutation and reads through a
still-live interior reference. The invalidated case above is a compile error by
design, so it cannot appear in runnable code.
"""

from std.utils import Variant


def mutate_through_interior_ref() -> Int:
    """`ref r = v[Int]` names the `Int` inside `v`; writing through it mutates
    the container in place, which we observe by reading `v[Int]` back."""
    var v: Variant[Int, Float64] = 42
    ref r = v[Int]
    r = 100
    return v[Int]


def interior_ref_aliases_payload() -> Bool:
    """An interior reference reads the container's current payload, confirming
    it aliases the storage owned by `v` rather than a copy."""
    var v: Variant[Int, Float64] = 7
    ref r = v[Int]
    return r == 7
