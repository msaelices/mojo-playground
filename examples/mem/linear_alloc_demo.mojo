"""Runnable demo of Mojo's linear `Allocation` type.

Run with:
    pixi run mojo -I . examples/mem/linear_alloc_demo.mojo
"""

from playground.mem import fill_and_sum, first_or_release, manual_lifetime


def main():
    print("Linear types: the compiler forces every `alloc` to be released.\n")

    print("fill_and_sum()       =", fill_and_sum())  # 0+1+4+...+49 = 140
    print("first_or_release(T)  =", first_or_release(True))  # 42
    print("first_or_release(F)  =", first_or_release(False))  # -1
    print("manual_lifetime()    =", manual_lifetime())  # 10+20+30 = 60

    print(
        "\nThe interesting part is the code that does NOT exist here: an"
        " allocation\nwithout a matching `dealloc` (or `unsafe_leak`) is a"
        " compile-time error,\non every control-flow path. See the module"
        " docstring in\nplayground/mem/linear_alloc.mojo for the rejected"
        " snippet."
    )
