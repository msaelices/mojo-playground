# Self-educational example of a simple geometry library in Mojo

import math

@value
struct Point:
    var x: Float64
    var y: Float64

    fn distance(self, other: Point) -> Float64:
        var x_diff = self.x - other.x
        var y_diff = self.y - other.y
        return math.sqrt(x_diff * x_diff + y_diff * y_diff)


@value
struct Line:
    var start: Point
    var end: Point

    fn length(self) -> Float64:
        return self.start.distance(self.end)


@value
struct Path:
    var points: List[Point]

    fn length(self) -> Float64:
        var total = 0.0
        for i in range(len(self.points) - 1):
            var p = self.points[i]
            total += p.distance(self.points[i + 1])
        return total


fn main():
    var p1 = Point(1, 2)
    var p2 = Point(4, 6)
    var l = Line(p1, p2)
    print('Line length:', l.length())
    var poly = Path(List(p1, p2, Point(3, 3)))
    print('Polygon length:', poly.length())

