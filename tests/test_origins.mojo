from testing import assert_true

from playground.origins import Point, PointBox, random_pointer


def test_point():
    var p = Point(1.0, 2.0)
    assert_true(p.x == 1.0)
    assert_true(p.y == 2.0)


def main():
    test_point()
