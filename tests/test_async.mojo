from testing import assert_true

from playground.async_module import task1, task2


def test_async_imports():
    # Test that async functions can be imported
    assert_true(True)


def main():
    test_async_imports()
