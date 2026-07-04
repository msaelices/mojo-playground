from std.testing import assert_equal, assert_true

from playground.traits import (
    DummyInt,
    FooElement,
    One,
    formatted_pack,
    unformattable_pack,
    packet_is_serializable,
    packet_is_json_serializable,
    int_packet_is_serializable,
)


def test_traits_imports() raises:
    # Test that trait types can be imported
    _ = DummyInt()
    _ = FooElement(10)
    _ = One(123)
    assert_true(True)


def test_variadic_conformance() raises:
    # An all-Writable pack is refined and concatenated; a pack with a
    # non-Writable element takes the fallback branch.
    assert_equal(formatted_pack(), String("1 + 2 = 3"))
    assert_equal(unformattable_pack(), String("<not all writable>"))
    # Pack-level conditional conformance with trait-hierarchy implication:
    # Packet[Payload] conforms to JsonSerializable and (by implication) its
    # parent Serializable; Packet[Int] conforms to neither.
    assert_true(packet_is_json_serializable())
    assert_true(packet_is_serializable())
    assert_true(not int_packet_is_serializable())


def main() raises:
    test_traits_imports()
    test_variadic_conformance()
