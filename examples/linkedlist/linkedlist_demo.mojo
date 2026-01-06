from memory import UnsafePointer
from playground.linkedlist import LinkedList


def main():
    var elements: List[Int] = [1, 2, 3, 4, 5, 6, 6, 7, 8, 9, 10]
    var list: LinkedList[Int] = elements^
    var ptr = UnsafePointer(to=list)

    print('Iterating using pointers:')
    while ptr[].has_next():
        print(ptr[].get_data())
        ptr = ptr[].get_next_ptr()

    print('\nIterating using iterator:')
    for elem in list:
        print(elem)
