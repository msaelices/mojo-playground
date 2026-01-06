from algorithm import vectorize
from memory import UnsafePointer
from sys import simd_width_of, size_of

fn memset(ptr: UnsafePointer[_, mut=True, **_], value: Byte, count: Int):
    _memset_impl(ptr.bitcast[Byte](), value, count * size_of[ptr.type]())


# Copied from stdlib
@always_inline("nodebug")
fn _memset_impl(
    ptr: UnsafePointer[Byte, mut=True, **_], value: Byte, count: Int
):
    @parameter
    fn fill[width: Int](offset: Int):
        print(value)
        ptr.store(offset, SIMD[DType.uint8, width](value))

    alias simd_width = simd_width_of[Byte]()
    vectorize[fill, simd_width](count)
