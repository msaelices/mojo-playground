from std.testing import assert_true

from playground.bytes import folded_multiply


def test_folded_multiply() raises:
    # Test that folded_multiply can be called
    _ = folded_multiply(42, 24)
    assert_true(True)


def main() raises:
    test_folded_multiply()
