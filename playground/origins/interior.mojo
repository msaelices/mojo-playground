"""Interior origins: memory safety for references into container storage.

Containers rarely store elements inline in the value you hold. `List` keeps
elements in heap storage; `Deque` uses a ring buffer; `String` owns a byte
buffer; a `Variant` keeps its payload in a discriminated buffer. A reference
handed out by such a container points at memory the container *owns* and may
free or reallocate -- the classic memory-safety hole.

Interior origins close it. An accessor vends a reference whose origin is an
*interior sub-origin* derived from the container's own origin, so the base
origin governs the reference's validity. Mutating or reassigning the container
invalidates every interior reference taken from it, and using one afterwards is
a compile-time error instead of undefined behavior.

The guarantee now covers the standard collections. Each of these is rejected at
compile time (the `note: origin was invalidated here` points at the mutation):

    var xs: List[Int] = [1, 2, 3]
    ref e = xs[0]
    xs.append(4)   # may reallocate the element buffer
    return e       # error: use of invalidated interior reference 'xs["element"]'

    var s = String("hello")
    ref b = s.as_bytes()[0]
    s += " world"  # may reallocate the byte buffer
    print(b)       # error: use of invalidated interior reference 's["bytes"]'

And it is available to *your* types too, not just the stdlib's -- see `Cell`
below, a hand-rolled heap-backed container that earns the same protection.

--------------------------------------------------------------------------
Contrast with Rust: same safety, less ceremony
--------------------------------------------------------------------------

Rust prevents the same dangling references, but its borrow checker is far more
restrictive: a reference into a collection borrows the *whole* collection for
that reference's entire lifetime, so it forbids aliasing patterns outright --
even ones that never touch invalidated memory. The two functions below compile
and run fine in Mojo, yet neither is accepted by Rust:

    // Rust -- two mutable element references at once: rejected.
    let mut xs = vec![1, 2, 3];
    let a = &mut xs[0];
    let b = &mut xs[1];        // error[E0499]: cannot borrow `xs` as mutable
    *a = 10;                   //               more than once at a time
    *b = 20;                   // (you must reach for `split_at_mut`, etc.)

    // Rust -- read one element while a mutable reference is live: rejected.
    let mut xs = vec![1, 2, 3];
    let r = &mut xs[0];
    let other = xs[1];         // error[E0502]: cannot borrow `xs` as immutable
    *r = 100;                  //               because it is also borrowed as mutable

Mojo's interior origins are lazier and more permissive: disjoint references and
reads are fine, and the compiler only objects when you actually *use* a
reference that a mutation invalidated. Rust rejects the aliasing structurally;
Mojo rejects the unsafe *use*. Same dangling-pointer guarantee, fewer false
positives.

The functions below exercise the valid patterns. The rejected cases above are
compile errors by design, so they cannot appear in runnable code.

Note: the vending helpers (`Origin._get_owned_interior`,
`UnsafePointer._get_ref_with_unsafe_interior_origin`) and the
`@__unsafe_nested_origins_read_only` decorator are experimental and still
evolving, hence the underscores.
"""

from std.collections import Deque, List
from std.memory import UnsafePointer


struct Cell[T: Copyable & ImplicitlyDeletable](Movable):
    """A minimal container owning a single heap-allocated `T`.

    Deliberately hand-rolled rather than wrapping a stdlib collection, to show
    that interior origins are available to ordinary user-defined types.
    """

    var _ptr: UnsafePointer[Self.T, MutUntrackedOrigin]

    def __init__(out self, var value: Self.T):
        self._ptr = alloc[Self.T](1)
        self._ptr.unsafe_write(value^)

    def __del__(deinit self):
        # Frees the storage that any interior reference would name, which is
        # exactly why handing those references out has to be tracked.
        self._ptr.unsafe_deinit_pointee()
        self._ptr.free()

    @__unsafe_nested_origins_read_only
    @always_inline
    def get(
        ref self,
    ) -> ref[origin_of(self)._get_owned_interior["value"]] Self.T:
        """Vend a reference to the owned payload.

        The result's origin is an interior sub-origin of `self`'s origin, tagged
        `"value"`, so the compiler ties the reference's validity to `self`
        rather than to the raw pointer. Reassigning the `Cell` runs `__del__`,
        freeing this storage; a reference taken earlier is then a use-after-free
        that the compiler rejects (`invalidated interior reference 'c["value"]'`).
        """
        return self._ptr._get_ref_with_unsafe_interior_origin[
            "value", origin_of(self)
        ]()


def mutate_cell_payload() -> Int:
    """Writing through a custom container's interior reference mutates its
    payload in place, observed by reading it back."""
    var c = Cell[Int](42)
    ref r = c.get()
    r = 100
    return c.get()


def mutate_list_element() -> Int:
    """`xs[0]` yields an interior reference into the list's element buffer;
    writing through it mutates the list in place."""
    var xs: List[Int] = [1, 2, 3]
    ref e = xs[0]
    e = 100
    return xs[0]


def mutate_deque_element() -> Int:
    """The same holds for a `Deque`'s ring buffer."""
    var q = Deque[Int]()
    q.append(1)
    ref e = q[0]
    e = 100
    return q[0]


def first_string_byte() -> Int:
    """`String` vends interior references into its byte buffer (tag `"bytes"`).
    Reading through one is fine; mutating the string first would invalidate it.
    'h' is 104."""
    var s: String = "hello"
    ref b = s.as_bytes()[0]
    return Int(b)


def disjoint_mutable_refs() -> Int:
    """Two mutable references into distinct elements coexist happily -- Mojo
    does not lock the whole container. Rust rejects this (E0499)."""
    var xs: List[Int] = [1, 2, 3]
    ref a = xs[0]
    ref b = xs[1]
    a = 10
    b = 20
    return a + b


def read_while_borrowed() -> Int:
    """Reading one element while a mutable reference to another is live is fine.
    Rust rejects this (E0502)."""
    var xs: List[Int] = [1, 2, 3]
    ref r = xs[0]
    var other = xs[1]
    r = 100
    return r + other
