"""ArcPointer back-references: one pointer buys lifetime *and* identity.

Inspired by a real Mojo stdlib change that parameterized the internal HAL
`Buffer` by its device and gave it a strong `ArcPointer` to its owning
`Context` (modular commit dd68288). Before, a `Buffer` tracked only a memory
handle and a byte size, so it could not say *where* it lived. A unified
`copy(dst, src)` needs each operand's residency to pick a transport
(same-device vs cross-device) and to obtain a queue for synchronous copies.

The fix is a tiny field with a big payoff: `var _context: ArcPointer[Context]`.
That single strong reference does two jobs at once:

  1. Keepalive: the owning `Context` (and its driver) cannot be destroyed
     while any buffer still references it, no matter who created the buffer
     or how long ago the original owner went away.
  2. Identity: the buffer can recover its residency from the context, so a
     transport-dispatching API can compare two buffers' contexts to choose
     between an intra-device and a cross-device copy.

This demo models that with plain CPU types so it runs anywhere. `Context`
prints on destruction so you can *see* exactly when the last reference drops.
"""

from std.memory import ArcPointer


struct Context(Movable):
    """A stand-in for a device + its driver: an expensive, shared resource.

    In the real HAL this also carries a `WeakPointer` self-reference so that
    `ctx.alloc_sync(...)` can hand each new buffer a strong `ArcPointer` back
    to the context. We keep it simpler here and allocate via a free function
    that takes the `ArcPointer[Context]` directly.
    """

    var id: Int
    var name: String

    def __init__(out self, id: Int, name: String):
        self.id = id
        self.name = name
        print("  [Context] opened", self.name)

    def __del__(deinit self):
        # Runs the instant the strong refcount hits zero -- never while a
        # buffer is still alive.
        print("  [Context] closed", self.name)


@fieldwise_init
struct Buffer(Movable):
    """A device allocation that knows where it lives.

    `_context` is the whole point: a strong `ArcPointer` that both keeps the
    `Context` alive for this buffer's lifetime and lets `copy` recover the
    buffer's residency.
    """

    var byte_size: UInt64
    var _context: ArcPointer[Context]

    def device(self) -> String:
        """Recover residency from the carried context."""
        return self._context[].name


def alloc(ctx: ArcPointer[Context], byte_size: UInt64) -> Buffer:
    """Allocate a buffer on `ctx`. Sharing the `ArcPointer` (copy = bump the
    strong refcount) is what ties the buffer's lifetime to the context's."""
    return Buffer(byte_size, ArcPointer(copy=ctx))


def copy(dst: Buffer, src: Buffer):
    """Dispatch on residency, exactly what the carried context unlocks.

    `is` compares the two `ArcPointer`s' control blocks: same block means the
    operands share one context, i.e. they are resident on the same device.
    """
    if dst._context is src._context:
        print(
            "  copy:",
            src.byte_size,
            "bytes intra-device on",
            src.device(),
        )
    else:
        print(
            "  copy:",
            src.byte_size,
            "bytes cross-device",
            src.device(),
            "->",
            dst.device(),
        )


def make_buffer_outliving_its_context() -> Buffer:
    """Create a context, allocate a buffer, then let the *original* context
    reference go away. The returned buffer keeps the context alive on its own.
    """
    var ctx = ArcPointer(Context(0, "gpu:0"))
    print("  refcount after open:", ctx.count())  # 1
    var buf = alloc(ctx, 1024)
    print("  refcount after alloc:", ctx.count())  # 2
    # `ctx`'s last use is right above, so Mojo drops it here (refcount 2 -> 1).
    # The Context is NOT closed: `buf` still holds the surviving reference.
    print("  original context handle dropped; buffer survives")
    return buf^


def main():
    print("1) Shared ownership: many buffers, one context")
    var ctx = ArcPointer(Context(0, "gpu:0"))
    var a = alloc(ctx, 256)
    var b = alloc(ctx, 512)
    print("  refcount (ctx + 2 buffers):", ctx.count())  # 3
    print("  a lives on", a.device(), "/ b lives on", b.device())

    print("\n2) Residency-aware copy off the same context")
    copy(a, b)  # intra-device: a and b share `ctx`

    print("\n3) A second device, then a cross-device copy")
    var ctx2 = ArcPointer(Context(1, "gpu:1"))
    var c = alloc(ctx2, 512)
    copy(c, b)  # cross-device: different contexts

    print("\n4) Keepalive: a buffer outliving the owner that made it")
    var orphan = make_buffer_outliving_its_context()
    print(
        "  orphan still usable:", orphan.byte_size, "bytes on", orphan.device()
    )
    print("  it is the last reference, so dropping it closes the context:")
    _ = orphan^  # explicit last use: the "[Context] closed gpu:0" lands here
