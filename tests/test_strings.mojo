from testing import assert_equal

from playground.strings import print_char, join_str


def test_join_str():
    var delimiter = ", "
    var elems: List[String] = ["hello", "world"]
    var result = join_str(delimiter, elems)
    assert_equal(result, "hello, world")


def main():
    test_join_str()
