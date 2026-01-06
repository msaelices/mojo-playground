from testing import assert_equal

from playground.linkedlist import LinkedList


def test_linkedlist():
    var elements: List[Int] = [1, 2, 3]
    var list: LinkedList[Int] = elements^
    assert_equal(len(list), 3)

    var count = 0
    for elem in list:
        count += 1
    assert_equal(count, 3)


def main():
    test_linkedlist()
