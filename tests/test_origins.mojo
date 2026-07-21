from std.testing import assert_equal, assert_true

from playground.origins import (
    Point,
    PointBox,
    random_pointer,
    mutate_cell_payload,
    mutate_list_element,
    mutate_deque_element,
    first_string_byte,
    disjoint_mutable_refs,
    read_while_borrowed,
)


def test_point() raises:
    var p = Point(1.0, 2.0)
    assert_true(p.x == 1.0)
    assert_true(p.y == 2.0)


def test_interior_origins() raises:
    # Mutating through an interior reference writes the container in place,
    # for a custom container and for the stdlib collections.
    assert_equal(mutate_cell_payload(), 100)
    assert_equal(mutate_list_element(), 100)
    assert_equal(mutate_deque_element(), 100)
    assert_equal(first_string_byte(), 104)  # 'h'


def test_interior_origins_permissiveness() raises:
    # Patterns Mojo accepts but Rust's borrow checker rejects.
    assert_equal(
        disjoint_mutable_refs(), 30
    )  # two mutable element refs (E0499)
    assert_equal(
        read_while_borrowed(), 102
    )  # read while a mut ref is live (E0502)


def main() raises:
    test_point()
    test_interior_origins()
    test_interior_origins_permissiveness()
