import std.sys as sys
from std.compile import compile_info
from playground.compile import print_fn


def main() raises:
    var args = sys.argv()
    var format = (
        "llvm" if len(args) > 1 and String(args[1]).lower() == "llvm" else "asm"
    )

    if format == "llvm":
        print(compile_info[print_fn, emission_kind="llvm"]())
    else:
        print(compile_info[print_fn, emission_kind="asm"]())
