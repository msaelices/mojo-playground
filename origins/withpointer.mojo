from random import random_float64


struct Point:
    var x: Float64
    var y: Float64

    fn __init__(out self, x: Float64, y: Float64):
        self.x = x
        self.y = y


struct PointBox[
    point_origin: Origin,
](Movable):
    var point_ptr: Pointer[Point, point_origin]

    fn __init__(
        out self,
        ref [point_origin]point: Point,
    ):
        self.point_ptr = Pointer(to=point)

fn random_pointer() -> PointBox[MutableAnyOrigin]:
    var point: Point = Point(
        x=random_float64(),
        y=random_float64(),
    )
    var point_box = PointBox[MutableAnyOrigin](
        point=point,
    )
    return point_box^

fn main() raises:
    var point_box = random_pointer()
    print("PointBox contains a point at: ({}, {})".format(
        point_box.point_ptr[].x,
        point_box.point_ptr[].y,
    ))
    # Modify the point through the pointer
    point_box.point_ptr[].x += 1.0
    point_box.point_ptr[].y += 1.0
    print("After modification: ({}, {})".format(
        point_box.point_ptr[].x,
        point_box.point_ptr[].y,
    ))
