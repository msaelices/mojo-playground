fn djbx33a_hash(st: String) -> Int:
    hash_value = 5381
    for char in st.as_bytes().get_immutable():
        hash_value = ((hash_value << 5) + hash_value) + Int(char)  # hash * 33 + ord(char)
    return hash_value


fn main():
    string_to_hash = "Hello, World!"
    hash_result = djbx33a_hash(string_to_hash)
    print(string_to_hash)
    print(hash_result)


