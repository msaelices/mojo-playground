struct Server(ImplicitlyCopyable):
    var address: String

    fn __init__(out self, address: String):
        self.address = address

    fn __moveinit__(out self, deinit other: Server):
        self.address = other.address^

    fn listen(self):
        print("Listening on", self.address)

    fn shutdown(self):
        print("Shutting down server at", self.address)


struct serve:
    var server: Server

    fn __init__(out self, address: String):
        self.server = Server(address)

    fn __enter__(mut self) -> Server:
        self.server.listen()
        return self.server

    fn __exit__(self):
        self.server.shutdown()
