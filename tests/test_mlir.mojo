from std.testing import assert_true

from playground.mlir import MyBool, MyTrue, MyFalse


def test_mybool() raises:
    var b = MyTrue
    if b:
        assert_true(True)
    else:
        assert_true(False)

    var b2 = MyFalse
    if b2:
        assert_true(False)
    else:
        assert_true(True)


def main() raises:
    test_mybool()
