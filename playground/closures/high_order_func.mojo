struct Foo:
    fn myfunc(self) -> Int:
        return 42


# Note: capturing [_] for lifetimes/origin !
fn high_order_func[f: fn () capturing [_] -> Int]() -> Int:
    return f()


fn demo_high_order_func():
    foo = Foo()

    @parameter
    fn foo_myfunc() -> Int:
        return foo.myfunc()

    # __type_of(foo).__del__(foo^)
    print(high_order_func[foo_myfunc]())
