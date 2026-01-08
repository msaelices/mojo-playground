from memory import UnsafePointer


# Simplified singly-linked list implementation
# This uses the new Mojo memory API with MutOrigin.external for heap-allocated nodes

struct _Node[ElementType: Copyable & ImplicitlyDestructible](Copyable):
    var data: Self.ElementType
    var next: UnsafePointer[Self, MutOrigin.external]

    @always_inline
    fn __init__(out self, var data: Self.ElementType):
        self.data = data^
        self.next = UnsafePointer[Self, MutOrigin.external]()


struct LinkedList[T: Copyable & ImplicitlyDestructible](Sized):
    var _head: UnsafePointer[_Node[Self.T], MutOrigin.external]
    var _size: Int

    fn __init__(out self):
        self._head = UnsafePointer[_Node[Self.T], MutOrigin.external]()
        self._size = 0

    fn __del__(deinit self):
        """Clean up the list by freeing all nodes."""
        var curr = self._head
        while curr:
            var next = curr[].next
            curr.destroy_pointee()
            curr.free()
            curr = next

    fn append(mut self, var value: Self.T):
        """Add an element to the end of the list."""
        var node_ptr = alloc[_Node[Self.T]](1)
        if not node_ptr:
            return

        node_ptr.init_pointee_move(_Node[Self.T](value^))

        if not self._head:
            self._head = node_ptr
        else:
            var curr = self._head
            while curr[].next:
                curr = curr[].next
            curr[].next = node_ptr
        self._size += 1

    fn __len__(self) -> Int:
        return self._size
