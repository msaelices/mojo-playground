from playground.traits import (
    DummyInt,
    HashedKey,
    FooElement,
    use_one,
    use_two,
)


fn main() raises:
    var x = DummyInt()
    print(HashedKey(x).hash)
    var y = FooElement(10)
    print(y.value)
    use_one()
    use_two()
