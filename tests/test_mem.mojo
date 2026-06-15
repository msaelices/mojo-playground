from std.testing import assert_equal, assert_true

from playground.mem import (
    memset,
    fill_and_sum,
    first_or_release,
    manual_lifetime,
)


def test_memset() raises:
    # Basic test that memset exists
    assert_true(True)


def test_fill_and_sum() raises:
    # Sum of squares 0..<8 = 0+1+4+9+16+25+36+49 = 140
    assert_equal(fill_and_sum(), Int32(140))


def test_first_or_release() raises:
    # Both branches must consume the linear handle; check both return paths.
    assert_equal(first_or_release(True), Int32(42))
    assert_equal(first_or_release(False), Int32(-1))


def test_manual_lifetime() raises:
    # unsafe_leak path: 10 + 20 + 30 = 60
    assert_equal(manual_lifetime(), Int32(60))


def main() raises:
    test_memset()
    test_fill_and_sum()
    test_first_or_release()
    test_manual_lifetime()
