import sys
from compile import _internal_compile_code as compile_code

@export  # this generates cleaner names
fn f() -> Int:
    var x: Int = 0
    for i in range(10):
        x += 1
    return x

fn main():
    args = sys.argv()
    format = "llvm" if len(args) > 1 and String(args[1]).lower() == "llvm" else "asm"

    if format == "llvm":
        print(compile_code[f, emission_kind="llvm"]())
    else:
        print(compile_code[f, emission_kind="asm"]())
