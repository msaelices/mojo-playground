from bit import byte_swap
from bit import rotate_bits_left

alias U256 = SIMD[DType.uint64, 4]
alias U128 = SIMD[DType.uint64, 2]
alias ROT = 23


@always_inline
fn folded_multiply(lhs: UInt64, rhs: UInt64) -> UInt64:
    """A fast function to emulate a folded multiply of two 64 bit uints.
    Used because we don't have UInt128 type.
    Args:
        lhs: 64 bit uint.
        rhs: 64 bit uint.
    Returns:
        A value which is similar in its bitpattern to result of a folded multply.
    """
    var b1 = lhs * byte_swap(rhs)
    var b2 = byte_swap(lhs) * (~rhs)
    return b1 ^ byte_swap(b2)

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
