fn print_char():
    var s = String("ab")
    var p = s.unsafe_ptr()
    
    print('Char: ', chr(Int(p.load())))
    # This assignment is needed to avoid destroying the s variable by Mojo compiler
    # and causing the s.unsafe_ptr() to be a dangling pointer.
    _ = s

