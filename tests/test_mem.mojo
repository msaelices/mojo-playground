from testing import assert_true

from playground.mem import memset


def test_memset():
    # Basic test that memset can be called
    var array = InlineArray[Int64, 5](fill=0)
    memset(array.unsafe_ptr(), 1, len(array))
    assert_true(True)


def main():
    test_memset()
