from playground.origins import random_pointer


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
