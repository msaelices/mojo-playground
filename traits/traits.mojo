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



@value
struct One[Type: CollectionElement]:
    var value: Type

    fn __init__(out self, value: Type):
        self.value = value

def use_one():
    s1 = One(123)
    s2 = One("Hello")

struct Two[Type: Writable & CollectionElement]:
    var val1: Type
    var val2: Type

    fn __init__(out self, one: One[Type], another: One[Type]):
        self.val1 = one.value
        self.val2 = another.value
        print(String(self.val1), String(self.val2))

    @staticmethod
    fn fire(thing1: One[Type], thing2: One[Type]):
        print("🔥", String(thing1.value), String(thing2.value))

def use_two():
    s3 = Two(One(String("infer")), One(String("me")))
    Two.fire(One(1), One(2))


fn main() raises:
    var x = DummyInt()
    print(HashedKey(x).hash)
    var y = FooElement(10)
    print(y.value)
    use_one()
    use_two()
