from std.testing import assert_equal

from playground.contextmanagers import Server, serve


def test_server() raises:
    var server = Server("localhost:3000")
    assert_equal(server.address, "localhost:3000")


def main() raises:
    test_server()
