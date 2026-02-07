from playground.linkedlist import LinkedList


def main():
    var list = LinkedList[Int]()
    for i in range(1, 11):
        list.append(i)

    print("LinkedList created with", len(list), "elements")
