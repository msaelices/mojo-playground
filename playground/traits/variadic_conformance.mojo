"""Pack-level conditional conformance: `Ts.all_conforms_to[Trait]()`.

The variadic counterpart to conditional deletability. Mojo can reason about a
trait check applied to an *entire* variadic parameter pack `*Ts`, via
`Ts.all_conforms_to[Trait]()` (backed by `conforms_to(Ts.values, Trait)`).
Two things this unlocks:

1. Per-element refinement. Inside `comptime if` / `comptime for`, once
   `Ts.all_conforms_to[Writable]()` is proven, every element of the pack is
   known to be `Writable`, so you can call `write_to` on each argument.

2. Pack-level conditional conformance with trait-hierarchy implication. A
   `Packet[*Ts]` can conditionally conform to `JsonSerializable` when its whole
   pack does. Because the check preserves proof structure, writing only the
   `JsonSerializable` condition is enough for the compiler to also prove the
   inherited `Serializable` conformance, without repeating the condition.
"""


struct Opaque(Movable):
    """A `Movable` type that is deliberately NOT `Writable`, used to exercise
    the `else` branch of the refinement below."""

    var x: Int

    def __init__(out self, x: Int):
        self.x = x


def format_all[*Ts: Movable](*args: *Ts) -> String:
    """Concatenate every argument's written form, but only when the whole pack
    is `Writable`. The `comptime if` refines each `args[i]` to `Writable` inside
    the branch; otherwise a fallback string is returned."""
    comptime if Ts.all_conforms_to[Writable]():
        var out = String()
        comptime for i in range(args.__len__()):
            args[i].write_to(out)
        return out
    else:
        return String("<not all writable>")


trait Serializable:
    pass


trait JsonSerializable(Serializable):
    pass


struct Packet[*Ts: Movable](
    JsonSerializable where Ts.all_conforms_to[JsonSerializable](),
    Movable,
):
    """Conditionally `JsonSerializable` when every packed type is.

    Only the `JsonSerializable` condition is written; the compiler proves the
    inherited `Serializable` conformance from it, so the redundant
    `Serializable where Ts.all_conforms_to[Serializable]()` clause is
    unnecessary.
    """

    pass


struct Payload(JsonSerializable, Movable):
    """A concrete packed element that satisfies the pack condition."""

    pass


def formatted_pack() -> String:
    """A pack of all-`Writable` values formats to their concatenation."""
    return format_all(1, " + ", 2, " = ", 3)


def unformattable_pack() -> String:
    """A pack containing the non-`Writable` `Opaque` takes the fallback path."""
    return format_all(Opaque(1), 2)


def packet_is_serializable() -> Bool:
    """`Packet[Payload]` conforms to `Serializable` — proven via the written
    `JsonSerializable` condition and trait-hierarchy implication."""
    return conforms_to(Packet[Payload], Serializable)


def packet_is_json_serializable() -> Bool:
    """`Packet[Payload]` conforms to `JsonSerializable` (its whole pack does).
    """
    return conforms_to(Packet[Payload], JsonSerializable)


def int_packet_is_serializable() -> Bool:
    """`Int` is not `JsonSerializable`, so `Packet[Int]` conforms to neither
    `JsonSerializable` nor its parent `Serializable`."""
    return conforms_to(Packet[Int], Serializable)
