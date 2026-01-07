from testing import assert_equal

from playground.sort import bubble_sort


def test_bubble_sort():
    var l: List[Int] = [64, 34, 25, 12, 22, 11, 90]
    bubble_sort(l)
    assert_equal(l, [11, 12, 22, 25, 34, 64, 90])


def main():
    test_bubble_sort()
