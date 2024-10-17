import sys
from compile import _internal_compile_code as compile_code


@no_inline  # no inline helper function for cleaner IR
fn f(x: Int):
  print(x)


fn main():
    args = sys.argv()
    format = "llvm" if len(args) > 1 and str(args[1]).lower() == "llvm" else "asm"

    if format == "llvm":
        print(compile_code[f, emission_kind="llvm"]())
    else:
        print(compile_code[f, emission_kind="asm"]())
