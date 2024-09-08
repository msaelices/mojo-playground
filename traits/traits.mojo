trait SizedHashable(Hashable, Sized):
    pass

@value
struct HashedInt(Hashable):
    var x: Int

    fn __hash__(self) -> UInt:
        return self.x

@value
struct DummyInt(SizedHashable):

    fn __hash__(self) -> UInt:
        return 10 * len(self)

    fn __len__(self) -> Int:
        return 2  # no sense 

fn sized_hash[T: SizedHashable](x: T) -> Int:
    return hash(x) * len(x)

struct HashedKey[K: Hashable]:
    var key: K
    var hash: Int

    fn __init__[K: Hashable](inout self, key: K):
        self.key = key
        self.hash = hash(key)

    fn __init__[K: SizedHashable](inout self, key: K):
        self.key = key
        self.hash = sized_hash(key)

fn main() raises:
    var x = DummyInt()
    print(HashedKey(x).hash)
