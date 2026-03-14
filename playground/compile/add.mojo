import sys
from compile import compile_info


@export
def add_fn(x: Int, y: Int) -> Int:
    return x + y


def demo_add() raises:
    args = sys.argv()
    format = (
        "llvm" if len(args) > 1 and String(args[1]).lower() == "llvm" else "asm"
    )

    if format == "llvm":
        print(compile_info[add_fn, emission_kind="llvm"]())
    else:
        print(compile_info[add_fn, emission_kind="asm"]())
