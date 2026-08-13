from playground.hash import djbx33a_hash


def main():
    var string_to_hash = "Hello, World!"
    var hash_result = djbx33a_hash(string_to_hash)
    print(string_to_hash)
    print(hash_result)
