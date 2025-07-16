from random import random_float64


struct Point[origin: Origin]:
    var x: Float64
    var y: Float64

    fn __init__(out self, x: Float64, y: Float64):
        self.x = x
        self.y = y


struct PointBox[
    origin: Origin,
]:
    var point_ptr: Pointer[Point[origin], origin]

    fn __init__(out self, ref [origin] point: Point[origin]):
        self.point_ptr = Pointer[Point[origin]](to=point)


fn random_pointer[origin: Origin]() -> PointBox[origin]:
    var point = Point[origin](
        x=random_float64(),
        y=random_float64(),
    )
    var point_box = PointBox[origin](
        point=point,
    )
    return point_box


fn random_pointer2() -> PointBox:
    var point = Point(
        x=random_float64(),
        y=random_float64(),
    )
    var point_box = PointBox(
        point=point,
    )
    return point_box

