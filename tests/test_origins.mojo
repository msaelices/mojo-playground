from std.testing import assert_equal, assert_true

from playground.origins import (
    Point,
    PointBox,
    random_pointer,
    mutate_through_interior_ref,
    interior_ref_aliases_payload,
)


def test_point() raises:
    var p = Point(1.0, 2.0)
    assert_true(p.x == 1.0)
    assert_true(p.y == 2.0)


def test_interior_origins() raises:
    # Writing through an interior reference mutates the container in place.
    assert_equal(mutate_through_interior_ref(), 100)
    # An interior reference aliases the container's live payload.
    assert_true(interior_ref_aliases_payload())


def main() raises:
    test_point()
    test_interior_origins()
