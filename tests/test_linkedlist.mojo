from std.testing import assert_true, assert_equal

from playground.linkedlist import LinkedList


def test_linkedlist() raises:
    var list = LinkedList[Int]()

    # Test basic append
    for i in range(3):
        list.append(i + 1)

    # Verify length
    assert_equal(len(list), 3)


def main() raises:
    test_linkedlist()
