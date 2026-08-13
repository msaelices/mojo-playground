"""Conditional deletability: a container inherits its payload's linearity.

Companion to `linear_alloc.mojo`. That example showed an *unconditional*
linear type: the stdlib `Allocation` is never `Deinitable`, so it has
no implicit destructor and the compiler forces you to consume it exactly once.

This example shows the *conditional* case. A generic wrapper is normally
deletable, but should become linear precisely when it holds a linear payload.
Mojo expresses both ends with the same tool: a `where` clause on the
`Deinitable` conformance.

    # linear: opt out unconditionally
    struct Handle(Movable, Deinitable where False):
        ...

    # conditional: deletable exactly when the payload is
    struct Box[T: Movable](
        Deinitable where conforms_to(T, Deinitable)
    ):
        ...

Mojo derives the container's deletability from its payload:
  * `Box[Int]`    is `Deinitable`  -> normal implicit cleanup.
  * `Box[Handle]` is NOT (`Handle` is linear) -> the `Box` is linear too and
    must be consumed explicitly, exactly like the resource it holds.
"""


struct Handle(Deinitable where False, Movable):
    """A linear resource: never `Deinitable`, so it must be `close`d.

    `Deinitable where False` opts the type out of implicit deletion;
    the value can still be moved (it conforms to `Movable`), but the compiler
    proves on every path that it is consumed exactly once via `close`.
    """

    var id: Int

    def __init__(out self, id: Int):
        self.id = id

    def close(deinit self) -> Int:
        """Consume the handle, returning its id so callers can observe it."""
        return self.id


struct Box[T: Movable](Deinitable where conforms_to(T, Deinitable)):
    """A wrapper whose deletability is derived from its payload `T`.

    No `@explicit_destroy` needed: the `where` clause makes the `Box`
    conditionally deletable, and linearity propagates automatically when `T`
    is itself linear.
    """

    var value: Self.T

    def __init__(out self, var value: Self.T):
        self.value = value^

    def unwrap(deinit self) -> Self.T:
        """Consume the `Box` and move its payload out. This is the explicit
        exit used when the `Box` is linear (it cannot be dropped implicitly)."""
        return self.value^


def wrap_and_read() -> Int:
    """A `Box[Int]` behaves like any ordinary value: it is `Deinitable`,
    so it is cleaned up implicitly at the end of scope. Returns the payload."""
    var b = Box[Int](7)
    return b.value  # `b` is dropped implicitly here; no explicit consume needed


def int_box_is_deletable() -> Bool:
    """`Int` is deletable, so the `where` clause makes `Box[Int]` deletable too.
    """
    return conforms_to(Box[Int], Deinitable)


def handle_box_is_deletable() -> Bool:
    """`Handle` is linear, so `Box[Handle]` is NOT deletable: the container
    inherits the linear obligation and must be consumed explicitly."""
    return conforms_to(Box[Handle], Deinitable)


def consume_linear_box() -> Int:
    """Because `Box[Handle]` is linear, the compiler requires it be consumed:
    move the payload out with `unwrap`, then `close` the handle. Dropping
    either on any path is a compile-time error. Returns the handle id."""
    var lb = Box[Handle](Handle(99))
    var handle = lb^.unwrap()  # consume the Box, recover the linear Handle
    return handle^.close()  # consume the Handle, yielding its id
