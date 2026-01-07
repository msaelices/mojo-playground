from bit import byte_swap, rotate_bits_left
from playground.bytes import folded_multiply

alias U128 = SIMD[DType.uint64, 2]
alias ROT = 23


fn main():
    var a = U128(1, 2)
    var b = U128(5, 6)
    print(a[0])
    print(byte_swap(a[0]))
    d = rotate_bits_left[1](a)
    print(d)
    # for i in range(ROT):
    #     c = c + folded_multiply(a[0], b[0])
    #     a = rotate_bits_left[1](a)
    #     b = rotate_bits_left[2](b)
    c = folded_multiply(a[0], b[0])
    print(c)
