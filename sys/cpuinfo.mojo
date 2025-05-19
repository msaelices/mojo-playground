from sys.info import _current_target, sizeof

fn main() raises:
    bits = sizeof[DType.index]() * 8
    print(String("CPU Architecture: {} bits").format(bits))
