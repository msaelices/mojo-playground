import sys
from compile import _internal_compile_code as compile_code


@export
fn f(x: Int, y: Int) -> Int:
    return x + y


fn main():
    args = sys.argv()
    format = "llvm" if len(args) > 1 and String(args[1]).lower() == "llvm" else "asm"

    if format == "llvm":
        print(compile_code[f, emission_kind="llvm"]())
    else:
        print(compile_code[f, emission_kind="asm"]())
