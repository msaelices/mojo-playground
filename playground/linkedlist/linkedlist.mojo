from memory import UnsafePointer


struct LinkedListIter[
    mut: Bool, //,
    ElementType: KeyElement & Representable & Writable,
    origin: Origin[mut],
](Iterator):
    alias Element = ElementType  # This shouldn't be needed if Mojo compiler improves

    var _src: Pointer[LinkedList[ElementType], origin=origin]
    var _curr: UnsafePointer[LinkedList[ElementType]]

    fn __init__(out self, linked_list_ptr: Pointer[LinkedList[ElementType], origin]):
        self._src = linked_list_ptr
        self._curr = UnsafePointer(to=self._src[])

    fn __has_next__(self) -> Bool:
        return self._curr and self._curr[].has_next()

    fn __next__(mut self) -> Self.Element:
        next_ptr = self._curr[].get_next_ptr()
        self._curr = next_ptr
        return next_ptr[].get_data()




struct LinkedList[T: KeyElement & Representable & Writable](Copyable, Movable, Iterable):
    var _data_ptr: UnsafePointer[T]
    var _next_ptr: UnsafePointer[LinkedList[T]]
    var _size: Int

    alias IteratorType[
        iterable_mut: Bool, //, iterable_origin: Origin[iterable_mut]
    ]: Iterator = LinkedListIter[ElementType=T, origin=iterable_origin]

    @implicit
    fn __init__(out self, var elements: List[T]):
        self._size = len(elements)

        self._data_ptr = UnsafePointer[T].alloc(1)
        self._data_ptr.init_pointee_copy(elements[0])

        if self._size == 1:
            # Null pointer
            self._next_ptr = UnsafePointer[LinkedList[T]]()
            return

        self._next_ptr = UnsafePointer[LinkedList[T]].alloc(1)
        self._next_ptr.init_pointee_copy(
            LinkedList[T](elements[1:])
        )

    fn __iter__(ref self) -> Self.IteratorType[__origin_of(self)]:
        return LinkedListIter(Pointer(to=self))

    fn __len__(self) -> Int:
        return self._size

    fn get_data(self) -> T:
        """Get the data of the current element."""
        return self._data_ptr[].copy()

    fn has_next(self) -> Bool:
        """Check if the next element exists."""
        return Bool(self._next_ptr)

    fn get_next(self) -> ref [__origin_of(self)] LinkedList[T]:
        """Get the next element as an auto-dereferenced ref (aka safe pointer)."""
        return self._next_ptr[]
        
    fn get_next_ptr(self) -> UnsafePointer[LinkedList[T]]:
        """Get the next element as an UnsafePointer."""
        return self._next_ptr

