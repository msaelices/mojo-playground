from std.memory import memset

from .linear_alloc import fill_and_sum, first_or_release, manual_lifetime
from .conditional_deletability import (
    wrap_and_read,
    int_box_is_deletable,
    handle_box_is_deletable,
    consume_linear_box,
)
