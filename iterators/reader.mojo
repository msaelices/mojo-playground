@value
struct ReaderIter:
    var reader: Reader
    var idx: Int

    def __iter__(self) -> Self:
        return self

    def __next__(self) -> String:
        var line = self.reader.lines[self.idx]
        self.idx += 1
        return line


@value
struct Reader:
    var lines: List[String]
    var idx: Int

    def __init__(out self, file: FileHandle):
        self.lines = file.read().split("\n")
        self.idx = 0

    def __iter__(self) -> ReaderIter:
        return ReaderIter(self, 0)


fn main() raises:
    with open("input.txt", "r") as f:
        var r = Reader(f)
        var r_it = r.__iter__()
        print(r_it.__next__())
        print(r_it.__next__())
