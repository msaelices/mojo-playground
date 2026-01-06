# Self-educational example of a simple geometry library in Mojo

import math

struct Point:
    var x: Float64
    var y: Float64

    fn distance(self, other: Point) -> Float64:
        x_diff = self.x - other.x
        y_diff = self.y - other.y
        return math.sqrt(x_diff ** 2 + y_diff ** 2)


struct Line:
    var start: Point
    var end: Point

    fn length(self) -> Float64:
        return self.start.distance(self.end)


struct Path:
    var points: List[Point]

    fn length(self) -> Float64:
        total = 0.0
        for i in range(len(self.points) - 1):
            p = self.points[i]
            total += p.distance(self.points[i + 1])
        return total

