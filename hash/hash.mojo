fn djbx33a_hash(s: String) -> Int:
    hash_value = 5381
    for char in s:
        hash_value = ((hash_value << 5) + hash_value) + ord(char)  # hash * 33 + ord(char)
    return hash_value


fn main():
    string_to_hash = "Hello, World!"
    hash_result = djbx33a_hash(string_to_hash)
    print(string_to_hash)
    print(hash_result)


