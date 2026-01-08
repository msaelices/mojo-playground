from memory import UnsafePointer


struct LinkedListIter[
    mut: Bool,
    //,
    ElementType: KeyElement & Representable & Writable,
    origin: Origin[mut=mut],
](Iterator):
    comptime Element = Self.ElementType  # This shouldn't be needed if Mojo compiler improves

    var _src: Pointer[LinkedList[Self.ElementType], origin=Self.origin]
    var _curr: UnsafePointer[LinkedList[Self.ElementType], origin=MutOrigin.external]

    fn __init__(
        out self, linked_list_ptr: Pointer[LinkedList[Self.ElementType], Self.origin]
    ):
        self._src = linked_list_ptr
        if len(linked_list_ptr[]) == 0:
            self._curr = UnsafePointer[LinkedList[Self.ElementType], origin=MutOrigin.external]()
        else:
            self._curr = UnsafePointer(to=linked_list_ptr[]).unsafe_origin_cast[MutOrigin.external]()

    fn __next__(mut self) raises StopIteration -> ref [Self.origin] Self.Element:
        if not self._curr:
            raise StopIteration()
        self._curr = self._curr[].get_next_ptr().unsafe_origin_cast[MutOrigin.external]()
        return self._curr[].get_data()


struct LinkedList[T: KeyElement & Representable & Writable](
    Copyable, Iterable, Movable, Sized
):
    var _data_ptr: UnsafePointer[Self.T, MutAnyOrigin]
    var _next_ptr: UnsafePointer[LinkedList[Self.T], MutAnyOrigin]
    var _size: Int

    comptime IteratorType[
        iterable_mut: Bool, //, iterable_origin: Origin[mut=iterable_mut]
    ]: Iterator = LinkedListIter[ElementType=Self.T, origin=iterable_origin]

    @implicit
    fn __init__(out self, var elements: Span[Self.T]):
        self._size = len(elements)

        self._data_ptr = alloc[Self.T](1)
        self._data_ptr.init_pointee_copy(elements[0])

        if self._size == 1:
            # Null pointer
            self._next_ptr = UnsafePointer[LinkedList[Self.T], MutAnyOrigin]()
        else:
            self._next_ptr = alloc[LinkedList[Self.T]](1)
            self._next_ptr.init_pointee_copy(LinkedList[Self.T](elements[1:]))

    fn __iter__(ref self) -> Self.IteratorType[origin_of(self)]:
        return LinkedListIter(Pointer(to=self))

    fn __len__(self) -> Int:
        return self._size

    fn get_data(self) -> ref [self] Self.T:
        """Get the data of the current element."""
        return self._data_ptr[]

    fn has_next(self) -> Bool:
        """Check if the next element exists."""
        return Bool(self._next_ptr)

    fn get_next(ref self) -> ref [self] LinkedList[Self.T]:
        """Get the next element as an auto-dereferenced ref (aka safe pointer).
        """
        return self._next_ptr[]

    fn get_next_ptr(self) -> UnsafePointer[LinkedList[Self.T], MutAnyOrigin]:
        """Get the next element as an UnsafePointer."""
        return self._next_ptr
