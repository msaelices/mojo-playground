"""Linear types: compiler-enforced explicit deallocation.

The `Allocation` handle returned by `alloc` is an `@explicit_destroy` type,
i.e. a *linear* type. This is what makes it special:

  * Affine types (e.g. values in Rust) are dropped *automatically* when you
    stop using them. Forgetting to use a value is harmless.
  * A linear type has NO implicit destructor. The compiler proves, on every
    control-flow path, that the value is consumed exactly once -- either by
    handing it to `dealloc(handle^)`, or by taking ownership of the raw
    pointer with `handle^.unsafe_leak()`.

Forgetting to release it is a *compile-time* error, not a runtime leak.
Almost no mainstream language enforces this statically.

The leak the compiler rejects::

    def leak():
        var a = alloc(Layout[Int32](count=4))
        # no dealloc, no unsafe_leak -> does NOT compile:
        # error: 'a' abandoned without being explicitly destroyed: An
        # `Allocation` owns heap storage and must be consumed before it goes
        # out of scope. Deallocate it with `dealloc(allocation^)`, or call
        # `unsafe_leak()` to take ownership of the underlying pointer.

The check is flow-sensitive: an early `return` that skips the `dealloc` on
*one* branch is rejected too (see `first_or_release` below).
"""

from std.memory.alloc import alloc, dealloc, Layout


def fill_and_sum() -> Int32:
    """Correct usage: allocate, use, then explicitly deallocate.

    Returns the sum of squares 0..<8 computed through the raw storage.
    """
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
    """Every branch must consume the handle -- the compiler checks them all.

    Removing the `dealloc` from either branch fails to compile, which is the
    property affine/RAII systems cannot express: here the release is explicit
    yet still statically guaranteed.
    """
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
    """`unsafe_leak` is the other way to satisfy the compiler.

    It transfers ownership out of the linear handle and hands you the bare
    pointer; from then on you are responsible for calling `free()`.
    """
    var a = alloc(Layout[Int32](count=3))
    var raw = a^.unsafe_leak()  # consumes `a`, yields the raw UnsafePointer

    raw.init_pointee_move(Int32(10))
    (raw + 1).init_pointee_move(Int32(20))
    (raw + 2).init_pointee_move(Int32(30))
    var total = raw[0] + raw[1] + raw[2]

    raw.free()  # now it is on us, not the compiler
    return total
