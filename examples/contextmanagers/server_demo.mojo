from playground.contextmanagers import serve


fn main():
    with serve("localhost:8000") as server:
        print("Serving requests on", server.address)
    print("Server has been shut down")
