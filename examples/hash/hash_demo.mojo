from playground.hash import djbx33a_hash


fn main():
    string_to_hash = "Hello, World!"
    hash_result = djbx33a_hash(string_to_hash)
    print(string_to_hash)
    print(hash_result)
