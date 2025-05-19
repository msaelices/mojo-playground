from memory import UnsafePointer


@value
struct LinkedList[T: KeyElement & Representable]:
    var _data_ptr: UnsafePointer[T]
    var _next_ptr: UnsafePointer[LinkedList[T]]

    @implicit
    fn __init__(out self, elements: List[T]):
        if not elements:
            # Null pointers
            self._data_ptr = UnsafePointer[T]()
            self._next_ptr = UnsafePointer[LinkedList[T]]()
            return

        self._data_ptr = UnsafePointer[T].alloc(1)
        self._data_ptr.init_pointee_move(elements[0])

        self._next_ptr = UnsafePointer[LinkedList[T]].alloc(1)
        self._next_ptr.init_pointee_move(
            LinkedList[T](elements[1:])
        )

    fn get_data(self) -> T:
        """Get the data of the current element."""
        return self._data_ptr[]

    fn has_next(self) -> Bool:
        """Check if the next element exists."""
        return Bool(self._next_ptr)

    fn get_next(self) -> ref [__origin_of(self)] LinkedList[T]:
        """Get the next element as an auto-dereferenced ref (aka safe pointer)."""
        return self._next_ptr[]
        
    fn get_next_ptr(self) -> UnsafePointer[LinkedList[T]]:
        """Get the next element as an UnsafePointer."""
        return self._next_ptr

def main():
    var elements: List[Int] = [1, 2, 3, 4, 5, 6, 6, 7, 8, 9, 10]
    var list: LinkedList[Int] = elements
    var ptr = UnsafePointer(to=list)

    print('Iterating using pointers:')
    while ptr[].has_next():
        print(ptr[].get_data())
        ptr = ptr[].get_next_ptr()

    print('\nIterating using refs:')
    while list.has_next():
        print(list.get_data())
        list = list.get_next() 
