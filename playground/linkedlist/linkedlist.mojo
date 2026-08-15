from std.memory import Pointer
from std.memory.alloc import unsafe_alloc


# Simplified singly-linked list: heap-allocated nodes with explicitly managed
# lifetimes (hence `MutUntrackedOrigin`). Each node points at the next via a
# `Pointer[Self, _]` field.


struct _Node[ElementType: Movable & Deinitable](Movable):
    comptime _Ptr = Optional[Pointer[Self, MutUntrackedOrigin]]

    var data: Self.ElementType
    var next: Self._Ptr

    @always_inline
    def __init__(out self, var data: Self.ElementType):
        self.data = data^
        self.next = None


struct LinkedList[T: Movable & Deinitable](Sized):
    var _head: _Node[Self.T]._Ptr
    var _size: Int

    def __init__(out self):
        self._head = None
        self._size = 0

    def __deinit__(deinit self):
        """Clean up the list by freeing all nodes."""
        var curr = self._head
        while curr:
            var ptr = curr.value()
            var next = ptr[].next
            ptr.unsafe_deinit_pointee()
            ptr.unsafe_free()
            curr = next

    def append(mut self, var value: Self.T):
        """Add an element to the end of the list."""
        var node_ptr = unsafe_alloc[_Node[Self.T]](1)
        node_ptr.unsafe_write(_Node[Self.T](value^))

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
