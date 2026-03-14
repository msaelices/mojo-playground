struct Server(ImplicitlyCopyable):
    var address: String

    def __init__(out self, address: String):
        self.address = address

    def __moveinit__(out self, deinit take: Server):
        self.address = take.address^

    def listen(self):
        print("Listening on", self.address)

    def shutdown(self):
        print("Shutting down server at", self.address)


struct serve:
    var server: Server

    def __init__(out self, address: String):
        self.server = Server(address)

    def __enter__(mut self) -> Server:
        self.server.listen()
        return self.server

    def __exit__(self):
        self.server.shutdown()
