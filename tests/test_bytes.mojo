from testing import assert_true

from playground.bytes import folded_multiply


def test_folded_multiply():
    # Test that folded_multiply can be called
    _ = folded_multiply(42, 24)
    assert_true(True)


def main():
    test_folded_multiply()
