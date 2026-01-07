import sys
from compile import compile_info


@no_inline  # no inline helper function for cleaner IR
fn print_fn(x: Int):
    print(x)


fn demo_print() raises:
    args = sys.argv()
    format = (
        "llvm" if len(args) > 1 and String(args[1]).lower() == "llvm" else "asm"
    )

    if format == "llvm":
        print(compile_info[print_fn, emission_kind="llvm"]())
    else:
        print(compile_info[print_fn, emission_kind="asm"]())
