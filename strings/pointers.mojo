from memory import memcpy


fn join_str(delimiter: String, elems: List[String]) -> String:
    buf = List[UInt8](capacity=10)
    delimiter_len = len(delimiter)
    delimiter_ptr = delimiter.unsafe_ptr()
    # This is only for learning purposes to work with pointers and strings.
    # In real code we can just call buf.append(bytes)
    offset = 0
    for elem_ref in elems:
        elem = elem_ref[]
        elem_len = len(elem)
        memcpy(
            dest=buf.unsafe_ptr().offset(offset),
            src=elem.unsafe_ptr(),
            count=elem_len,
        )
        # This assignment is needed to avoid destroying the elem variable by Mojo compiler
        # and causing the elem.unsafe_ptr() to be a dangling pointer.
        _ = elem
        offset += elem_len
        buf.resize(unsafe_uninit_length=len(buf) + elem_len)
        memcpy(
            dest=buf.unsafe_ptr().offset(offset),
            src=delimiter_ptr,
            count=delimiter_len,
        )
        offset += delimiter_len
        buf.resize(unsafe_uninit_length=len(buf) + delimiter_len)
    # Terminate the string with a null character
    buf[offset] = 0
    buf.resize(unsafe_uninit_length=len(buf) + delimiter_len)
    
    return String(bytes=buf^)


fn main():
    var s: String = ", "
    var l: List[String] = ["12", "23"]
    joined = join_str(s, l)
    print("Joined: ", joined)
    _ = joined
