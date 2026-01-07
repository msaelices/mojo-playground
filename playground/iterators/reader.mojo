struct ReaderIter:
    var reader: Reader
    var idx: Int

    def __iter__(self) -> Self:
        return self

    def __next__(self) -> String:
        var line = self.reader.lines[self.idx]
        self.idx += 1
        return line


struct Reader:
    var lines: List[String]
    var idx: Int

    def __init__(out self, file: FileHandle):
        self.lines = file.read().split("\n")
        self.idx = 0

    def __iter__(self) -> ReaderIter:
        return ReaderIter(self, 0)
