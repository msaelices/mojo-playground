"""Linear types: compiler-enforced explicit deallocation.

The `Allocation` from `alloc` is an `@explicit_destroy` (linear) type: it has
no implicit destructor, so the compiler proves on every control-flow path that
it is consumed exactly once, via `dealloc(handle^)` or `handle^.unsafe_leak()`.
Forgetting it is a compile-time error, not a runtime leak; unlike affine types
(e.g. Rust values), dropping it on the floor simply does not compile.
"""

from std.memory.alloc import alloc, dealloc, Layout


def fill_and_sum() -> Int32:
    """Allocate, use, then explicitly deallocate (sum of squares 0..<8)."""
    var layout = Layout[Int32](count=8)
    var a = alloc(layout)
    # `unsafe_ptr()` borrows a view of the storage; it does NOT consume the
    # linear handle, so `a` still has to be released below.
    var ptr = a.unsafe_ptr()
    for i in range(layout.count()):
        (ptr + i).init_pointee_move(Int32(i) * Int32(i))

    var total = Int32(0)
    for i in range(layout.count()):
        total += ptr[i]

    dealloc(a^)  # required: consume the linear handle on this path
    return total


def first_or_release(produce: Bool) -> Int32:
    """Every branch must consume the handle: removing `dealloc` from either
    one fails to compile. The release is explicit yet statically guaranteed."""
    var a = alloc(Layout[Int32](count=1))
    var ptr = a.unsafe_ptr()
    ptr.init_pointee_move(Int32(42))

    if not produce:
        dealloc(a^)  # branch A consumes it
        return Int32(-1)

    var value = ptr[0]
    dealloc(a^)  # branch B consumes it
    return value


def manual_lifetime() -> Int32:
    """`unsafe_leak` consumes the handle and hands you the bare pointer, so
    satisfying the compiler now makes you responsible for calling `free()`."""
    var a = alloc(Layout[Int32](count=3))
    var raw = a^.unsafe_leak()  # consumes `a`, yields the raw UnsafePointer

    raw.init_pointee_move(Int32(10))
    (raw + 1).init_pointee_move(Int32(20))
    (raw + 2).init_pointee_move(Int32(30))
    var total = raw[0] + raw[1] + raw[2]

    raw.free()  # now it is on us, not the compiler
    return total
