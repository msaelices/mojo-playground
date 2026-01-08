from testing import assert_true, assert_equal

from playground.linkedlist import LinkedList


def test_linkedlist():
    var list = LinkedList[Int]()

    # Test basic append
    for i in range(3):
        list.append(i + 1)

    # Verify length
    assert_equal(len(list), 3)


def main():
    test_linkedlist()
