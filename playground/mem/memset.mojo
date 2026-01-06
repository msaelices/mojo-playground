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

fn main():
    var array = InlineArray[Int64, 10](fill=0)
    memset(array.unsafe_ptr(), 2, len(array))
    # Should print: [2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
    # TODO: It0s not because it's filling all the bytes in the b64 value with twos
    for i in range(len(array)):
        print(array[i])  
