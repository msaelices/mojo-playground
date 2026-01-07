from playground.pythonic import (
    demo_print,
    demo_variables,
    printer,
    add_one,
    return_ref,
    return_mut_ref,
    return_immutable_ref,
    return_mutable_ref2,
)


fn test_pythonic_imports():
    # Test that pythonic module functions can be imported
    pass


fn demo_function_with_return() -> Int:
    return 42


fn test_demo_functions_run():
    # Just verify the demo functions can be called without error
    demo_print()
    demo_variables()
    printer("test")


def main():
    test_pythonic_imports()
    test_demo_functions_run()
