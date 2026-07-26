def djbx33a_hash(st: String) -> Int:
    hash_value = 5381
    for char in st.as_bytes().as_imm():
        hash_value = ((hash_value << 5) + hash_value) + Int(
            char
        )  # hash * 33 + ord(char)
    return hash_value
