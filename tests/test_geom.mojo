from testing import assert_equal, assert_true

from playground.geom import Point, Line, Path


def test_point():
    var p1 = Point(0, 0)
    var p2 = Point(3, 4)
    # Distance between (0,0) and (3,4) is 5
    var dist = p1.distance(p2)
    # Using approximate comparison for floating point
    assert_true(dist > 4.9 and dist < 5.1)


def test_line():
    var p1 = Point(0, 0)
    var p2 = Point(3, 4)
    var line = Line(p1, p2)
    var length = line.length()
    assert_true(length > 4.9 and length < 5.1)


def test_path():
    var p1 = Point(0, 0)
    var p2 = Point(3, 0)
    var p3 = Point(6, 0)
    var points: List[Point] = [p1, p2, p3]
    var path = Path(points^)
    var length = path.length()
    assert_true(length > 5.9 and length < 6.1)


def main():
    test_point()
    test_line()
    test_path()
