from testing import assert_true

from playground.traits import DummyInt, FooElement, One


def test_traits_imports():
    # Test that trait types can be imported
    _ = DummyInt()
    _ = FooElement(10)
    _ = One(123)
    assert_true(True)


def main():
    test_traits_imports()
