from testing import assert_equal

from playground.dicts import get_wds, get_freqs


def test_get_wds():
    var wds = get_wds()
    assert_equal(len(wds) > 0, True)


def test_get_freqs():
    var wds: List[String] = ["hello", "world", "hello"]
    var freqs = get_freqs(wds)
    assert_equal(freqs["hello"], 2)
    assert_equal(freqs["world"], 1)


def main():
    test_get_wds()
    test_get_freqs()
