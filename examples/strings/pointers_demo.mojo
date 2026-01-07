from playground.strings import join_str


fn main():
    var s: String = ", "
    var l: List[String] = ["12", "23"]
    joined = join_str(s, l)
    print("Joined: ", joined)
    _ = joined
