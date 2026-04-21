import sys
from compile import compile_info


@export  # this generates cleaner names
def forloop_fn() -> Int:
    var x: Int = 0
    for _ in range(10):
        x += 1
    return x


def demo_forloop() raises:
    args = sys.argv()
    format = (
        "llvm" if len(args) > 1 and String(args[1]).lower() == "llvm" else "asm"
    )

    if format == "llvm":
        print(compile_info[forloop_fn, emission_kind="llvm"]())
    else:
        print(compile_info[forloop_fn, emission_kind="asm"]())
