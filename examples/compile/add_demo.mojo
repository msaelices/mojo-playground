import sys
from compile import compile_info
from playground.compile import add_fn


fn main() raises:
    args = sys.argv()
    format = "llvm" if len(args) > 1 and String(args[1]).lower() == "llvm" else "asm"

    if format == "llvm":
        print(compile_info[add_fn, emission_kind="llvm"]())
    else:
        print(compile_info[add_fn, emission_kind="asm"]())
