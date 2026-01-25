from playground.iterators import Reader


fn main() raises:
    with open("playground/iterators/input.txt", "r") as f:
        var r = Reader(f)
        var r_it = r.into_iter()
        print(r_it.__next__())
        print(r_it.__next__())
