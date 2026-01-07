from playground.geom import Point, Line, Path


fn main():
    var p1 = Point(1, 2)
    var p2 = Point(4, 6)
    var l = Line(p1, p2)
    print("Line length:", l.length())
    var points: List[Point] = [Point(1, 2), Point(3, 4)]
    var poly = Path(points^)
    print("Polygon length:", poly.length())
