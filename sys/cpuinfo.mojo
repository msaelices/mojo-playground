from sys.info import _current_target, size_of

fn main() raises:
    bits = size_of[DType.index]() * 8
    print(String("CPU Architecture: {} bits").format(bits))
