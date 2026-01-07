# Self-educational example of a simple geometry library in Mojo

import math


@register_passable("trivial")
struct Point:
    var x: Float64
    var y: Float64

    fn __init__(out self, x: Float64, y: Float64):
        self.x = x
        self.y = y

    fn distance(self, other: Point) -> Float64:
        x_diff = self.x - other.x
        y_diff = self.y - other.y
        return math.sqrt(x_diff**2 + y_diff**2)


struct Line:
    var start: Point
    var end: Point

    fn __init__(out self, start: Point, end: Point):
        self.start = start
        self.end = end

    fn length(self) -> Float64:
        return self.start.distance(self.end)


struct Path:
    var points: List[Point]

    fn __init__(out self, var points: List[Point]):
        self.points = points^

    fn length(self) -> Float64:
        total = 0.0
        for i in range(len(self.points) - 1):
            p = self.points[i]
            total += p.distance(self.points[i + 1])
        return total
