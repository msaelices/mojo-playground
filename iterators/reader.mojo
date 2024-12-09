@value
struct readeriter:
    var reader: reader
    var idx: Int

    def __iter__(self) -> Self:
        return self

    def __next__(out self) -> String:
        var line = self.reader.lines[self.idx]
        self.idx += 1
        return line


@value
struct reader:
    var lines: List[String]
    var idx: Int

    def __init__(out self, file: FileHandle):
        self.lines = file.read().split("\n")
        self.idx = 0

    def __iter__(self) -> readeriter:
        return readeriter(self, 0)


fn main() raises:
    with open("input.txt", "r") as f:
        var r = reader(f)
        var r_it = iter(r)
        print(next(r_it))
        print(next(r_it))
