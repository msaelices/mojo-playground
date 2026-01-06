from playground.mlir import MyTrue, MyFalse


fn main():
    var b = MyTrue
    if b:
        print("b is True")
    else:
        print("b is False")
    var b2 = MyFalse
    if b2:
        print("b2 is True")
    else:
        print("b2 is False")
    print(b == b2)
