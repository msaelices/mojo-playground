from playground.origins import random_pointer


def main() raises:
    var point_box = random_pointer()
    print(
        t"PointBox contains a point at:"
        t" ({point_box.point_ptr[].x}, {point_box.point_ptr[].y})"
    )
    # Modify the point through the pointer
    point_box.point_ptr[].x += 1.0
    point_box.point_ptr[].y += 1.0
    print(
        t"After modification:"
        t" ({point_box.point_ptr[].x}, {point_box.point_ptr[].y})"
    )
