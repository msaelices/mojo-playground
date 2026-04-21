from std.sys.info import _current_target, size_of


def print_cpu_info() raises:
    bits = size_of[Int]() * 8
    print(String("CPU Architecture: {} bits").format(bits))
