from playground.mem import memset


fn main():
    var array = InlineArray[Int64, 10](fill=0)
    memset(array.unsafe_ptr(), 2, len(array))
    # Should print: [2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
    # TODO: It's not because it's filling all the bytes in the b64 value with twos
    for i in range(len(array)):
        print(array[i])
