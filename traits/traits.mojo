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

    fn __init__(inout self, owned key: K):
        self.key = key
        self.hash = hash(key)

    fn __init__[U: SizedHashable](inout self: HashedKey[U], key: U):
        self.key = key
        self.hash = sized_hash(key)


fn main() raises:
    var x = DummyInt()
    print(HashedKey(x).hash)