from hashlib import Hasher


trait CopiableHashable(Hashable, ImplicitlyCopyable):
    pass


trait SizedHashable(CopiableHashable, Sized):
    pass


struct HashedInt(CopiableHashable):
    var x: Int

    fn __hash__[H: Hasher](self, mut hasher: H):
        hasher.update(self.x)


struct DummyInt(SizedHashable):  # dummy example with minimum code
    fn __init__(out self):
        pass

    fn __hash__[H: Hasher](self, mut hasher: H):
        hasher.update(10 * len(self))

    fn __len__(self) -> Int:
        return 2


fn sized_hash[T: SizedHashable](x: T) -> Int:
    return Int(hash[T](x) * len(x))


struct HashedKey[K: CopiableHashable]:
    var key: Self.K
    var hash: Int

    fn __init__(out self, var key: Self.K):
        self.key = key
        self.hash = Int(hash(key))

    fn __init__[U: SizedHashable](out self: HashedKey[U], key: U):
        self.key = key
        self.hash = sized_hash(key)


struct FooElement[Type: Writable & ImplicitlyCopyable & Movable]:
    """Example of trait composition."""

    var value: Self.Type

    fn __init__(out self, value: Self.Type):
        self.value = value


struct One[Type: ImplicitlyCopyable & Movable]:
    var value: Self.Type

    fn __init__(out self, value: Self.Type):
        self.value = value


def use_one():
    _ = One(123)
    _ = One("Hello")


struct Two[Type: Writable & ImplicitlyCopyable & Movable]:
    var val1: Self.Type
    var val2: Self.Type

    fn __init__(out self, one: One[Self.Type], another: One[Self.Type]):
        self.val1 = one.value
        self.val2 = another.value
        print(String(self.val1), String(self.val2))

    @staticmethod
    fn fire(thing1: One[Self.Type], thing2: One[Self.Type]):
        print("🔥", String(thing1.value), String(thing2.value))


def use_two():
    _ = Two(One(String("infer")), One(String("me")))
    Two.fire(One(1), One(2))


fn demo_traits() raises:
    var x = DummyInt()
    print(HashedKey(x).hash)
    var y = FooElement(10)
    print(y.value)
    use_one()
    use_two()
