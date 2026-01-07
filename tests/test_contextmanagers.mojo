from testing import assert_equal

from playground.contextmanagers import Server, serve


def test_server():
    var server = Server("localhost:3000")
    assert_equal(server.address, "localhost:3000")


def main():
    test_server()
