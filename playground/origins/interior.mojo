"""Interior origins: authoring a container that vends safe references.

Containers rarely store elements inline in the value you hold. `List` keeps
elements in heap storage; `Variant` keeps its payload in a discriminated
buffer. A reference handed out by such a container points at memory the
container *owns* and may free or reallocate -- the classic memory-safety hole.

Interior origins close it. An accessor can vend a reference whose origin is an
*interior sub-origin* derived from the container's own origin, so the base
origin governs the reference's validity. Mutating or reassigning the container
invalidates every interior reference taken from it, and using one afterwards is
a compile-time error instead of undefined behavior.

The interesting part is that this is available to *your* types, not just the
stdlib's. `Cell` below is an ordinary heap-backed container, and it gets the
same guarantee:

    var c = Cell[Int](42)
    ref r = c.get()    # `r` names the Int that `c` owns on the heap
    r = 100            # OK: mutates the payload in place
    c = Cell[Int](7)   # reassigns `c`, running __del__ and freeing that storage
    return r           # error: use of invalidated interior reference 'c["value"]'
                       # note: origin was invalidated here (the reassignment)

That final read is a genuine use-after-free -- the storage `r` names was freed
by the destructor -- and the compiler now rejects it outright. The `"value"`
tag is the name we chose for the interior slot; it shows up in the diagnostic
as `c["value"]`.

The functions below exercise the *valid* pattern. The rejected case above is a
compile error by design, so it cannot appear in runnable code.

Note: the vending helpers (`Origin._get_owned_interior`,
`UnsafePointer._get_ref_with_unsafe_interior_origin`) and the
`@__unsafe_nested_origins_read_only` decorator are experimental and still
evolving, hence the underscores.
"""

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
        rather than to the raw pointer.
        """
        return self._ptr._get_ref_with_unsafe_interior_origin[
            "value", origin_of(self)
        ]()


def mutate_through_interior_ref() -> Int:
    """Writing through an interior reference mutates the container's payload in
    place, which we observe by reading it back through the container."""
    var c = Cell[Int](42)
    ref r = c.get()
    r = 100
    return c.get()


def interior_ref_aliases_payload() -> Bool:
    """An interior reference reads the container's live payload, confirming it
    aliases owned storage rather than a copy."""
    var c = Cell[Int](7)
    ref r = c.get()
    return r == 7
