from testing import assert_equal

from playground.hash import djbx33a_hash


def test_djbx33a_hash():
    # Test basic hash functionality
    var hash1 = djbx33a_hash("hello")
    var hash2 = djbx33a_hash("hello")
    var hash3 = djbx33a_hash("world")
    assert_equal(hash1, hash2)
    # Different strings should (likely) have different hashes
    assert_true(hash1 != hash3)


def main():
    test_djbx33a_hash()
