trait CopiableHashable(Hashable, Copyable):
    pass


trait SizedHashable(Sized, CopiableHashable):
    pass

@value
struct HashedInt(CopiableHashable):
    var x: Int

    fn __hash__(self) -> UInt:
        return self.x

@value
struct DummyInt(SizedHashable):  # dummy example with minimum code
    fn __hash__(self) -> UInt:
        return 10 * len(self)

    fn __len__(self) -> Int:
        return 2


fn sized_hash[T: SizedHashable](x: T) -> Int:
    return hash(x) * len(x)


struct HashedKey[K: CopiableHashable]:
    var key: K
    var hash: Int

    fn __init__(out self, owned key: K):
        self.key = key
        self.hash = hash(key)

    fn __init__[U: SizedHashable](out self: HashedKey[U], key: U):
        self.key = key
        self.hash = sized_hash(key)


@value
struct FooElement[Type: Writable & CollectionElement]:
    """Example of trait composition."""
    var value: Type

    fn __init__(out self, value: Type):
        self.value = value

fn main() raises:
    var x = DummyInt()
    print(HashedKey(x).hash)
    var y = FooElement(10)
    print(y.value)
