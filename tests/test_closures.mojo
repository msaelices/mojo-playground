from std.testing import assert_equal, assert_true

from playground.closures import (
    use_closure,
    create_closure,
    high_order_func,
    apply_thin,
    squared,
    scaled,
    sum_of_squares,
)


def test_closures_imports() raises:
    # Test that closure functions can be imported
    assert_true(True)


def test_lambdas() raises:
    # Thin lambda passed as a compile-time function parameter.
    assert_equal(apply_thin[lambda (x: Int) -> Int: x + 1](41), 42)
    # Thin lambda bound to a var and called.
    assert_equal(squared(9), 81)
    # Capturing lambda closes over `factor`.
    assert_equal(scaled(10, 3), 30)
    # Compose transform + reduce with inline lambdas: 1+4+9+16 = 30.
    assert_equal(sum_of_squares([1, 2, 3, 4]), 30)


def main() raises:
    test_closures_imports()
    test_lambdas()
