"""
Progressive exposure to Mojo features for Python programmers.

This demo runs all the progressive examples in order, showing how Mojo
syntax is gradually introduced from Python-like to more advanced features.
"""

from playground.pythonic import (
    demo_print,
    demo_variables,
    demo_function_call,
    demo_mut_argument,
    demo_pointer,
    demo_return_ref,
    demo_return_mut_ref,
    demo_inferred_mut_ref,
    demo_immutable_ref,
    demo_mutable_pointer,
)


fn main():
    print("=== Progressive Mojo Examples ===\n")

    print("1. Basic print:")
    demo_print()
    print()

    print("2. Variables (type inference):")
    demo_variables()
    print()

    print("3. Function call:")
    demo_function_call()
    print()

    print("4. Mutable argument (note: a is copied, so original unchanged):")
    demo_mut_argument()
    print()

    print("5. Pointer (safe reference):")
    demo_pointer()
    print()

    print("6. Return auto-dereferencing ref:")
    demo_return_ref()
    print()

    print("7. Return mutable auto-dereferencing ref:")
    demo_return_mut_ref()
    print()

    print("8. Return inferred mutability auto-dereferencing ref:")
    demo_inferred_mut_ref()
    print()

    print("9. Return immutable ref:")
    demo_immutable_ref()
    print()

    print("10. Return mutable pointer:")
    demo_mutable_pointer()
