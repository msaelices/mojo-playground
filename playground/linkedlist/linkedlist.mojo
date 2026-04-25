from std.memory import UnsafePointer


# Simplified singly-linked list implementation
# This uses the Mojo memory API with MutAnyOrigin for heap-allocated nodes


comptime _NodePtr[T: Copyable & ImplicitlyDestructible] = Optional[
    UnsafePointer[_Node[T], MutAnyOrigin]
]


struct _Node[ElementType: Copyable & ImplicitlyDestructible](Copyable):
    var data: Self.ElementType
    var next: _NodePtr[Self.ElementType]

    @always_inline
    def __init__(out self, var data: Self.ElementType):
        self.data = data^
        self.next = None


struct LinkedList[T: Copyable & ImplicitlyDestructible](Sized):
    var _head: _NodePtr[Self.T]
    var _size: Int

    def __init__(out self):
        self._head = None
        self._size = 0

    def __del__(deinit self):
        """Clean up the list by freeing all nodes."""
        var curr = self._head
        while curr:
            var ptr = curr.value()
            var next = ptr[].next
            ptr.destroy_pointee()
            ptr.free()
            curr = next

    def append(mut self, var value: Self.T):
        """Add an element to the end of the list."""
        var node_ptr = alloc[_Node[Self.T]](1)
        node_ptr.init_pointee_move(_Node[Self.T](value^))

        if not self._head:
            self._head = node_ptr
        else:
            var curr = self._head.value()
            while curr[].next:
                curr = curr[].next.value()
            curr[].next = node_ptr
        self._size += 1

    def __len__(self) -> Int:
        return self._size
