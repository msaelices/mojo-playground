struct Foo:
    def __init__(out self):
        pass

    def myfunc(self) -> Int:
        return 42


# Note: capturing [_] for lifetimes/origin !
def high_order_func[f: def() capturing[_] -> Int]() -> Int:
    return f()


def demo_high_order_func():
    foo = Foo()

    @parameter
    def foo_myfunc() -> Int:
        return foo.myfunc()

    # __type_of(foo).__del__(foo^)
    print(high_order_func[foo_myfunc]())
