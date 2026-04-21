# Parametric closures


def use_closure[func: def(Int) capturing -> Int](num: Int) -> Int:
    return func(num)


def create_closure():
    var x = 1

    @parameter
    def add(i: Int) -> Int:
        return x + i

    _ = x  # Silence "unused" warning; x is captured by add
    var y = use_closure[add](2)
    print(y)


def demo_closure():
    create_closure()
