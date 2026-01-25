struct ReaderIter:
    var lines: List[String]
    var idx: Int

    fn __init__(out self, lines: List[String]):
        self.lines = lines.copy()
        self.idx = 0

    fn __iter__(self) -> Self:
        return self

    fn __next__(mut self) -> String:
        var line = self.lines[self.idx]
        self.idx += 1
        return line


struct Reader:
    var lines: List[String]

    fn __init__(out self, file: FileHandle) raises:
        var content = file.read()
        var slices = content.split("\n")
        self.lines = List[String]()
        for i in range(len(slices)):
            self.lines.append(String(slices[i]))

    fn into_iter(self) -> ReaderIter:
        return ReaderIter(self.lines.copy())
