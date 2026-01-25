# Parametric closures


fn use_closure[func: fn (Int) capturing -> Int](num: Int) -> Int:
    return func(num)


fn create_closure():
    var x = 1

    @parameter
    fn add(i: Int) -> Int:
        return x + i

    _ = x  # Silence "unused" warning; x is captured by add
    var y = use_closure[add](2)
    print(y)


fn demo_closure():
    create_closure()
