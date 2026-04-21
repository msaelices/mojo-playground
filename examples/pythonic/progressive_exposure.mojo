"""
This file was an great example by @rd4com of how to progressively expose Mojo features
to Python programmers.

Follows the "progressive exposure to complexity" principle, where the syntax is
gradually introduced to the user.
"""


# print
def demo_print():
    print("hello world")


# create variable (not learned types yet)
def demo_variables():
    a = "hello world"
    b = 1
    print(a, b)


# print trough function
def printer(a: String):
    print(a)


def demo_function_call():
    a = "hello world"
    printer(a)


# modify variables
def add_one(mut a: Int):
    a += 1


def demo_mut_argument():
    a = 0
    add_one(a)
    print(a)


# here there is another gradual step (currently worked on)
# (create auto dereferenced reference and not learned origin yet)


# create safe reference (not learned origin yet)
def demo_pointer():
    a = 0
    b = Pointer(to=a)
    a += 1
    print(b[])


# return auto dereference (not learned origin yet)
def return_ref(arg: List[Int]) -> ref[arg] List[Int]:
    return arg


def demo_return_ref():
    a = [1, 2, 3]
    a.append(4)
    print(return_ref(a)[3])


# return mutable auto dereference (not learned origin yet)
def return_mut_ref(mut arg: List[Int]) -> ref[arg] List[Int]:
    return arg


def demo_return_mut_ref():
    a = [1, 2, 3]
    return_mut_ref(a).append(4)
    print(len(a))


# return inferred mutability auto dereference (not learned origin yet)
def return_inferred_mut_ref(ref arg: List[Int]) -> ref[arg] List[Int]:
    return arg


def demo_inferred_mut_ref():
    a = [1, 2, 3]
    return_mut_ref(a).append(4)
    print(len(a))


# return immutable auto dereference
def return_immutable_ref(ref[_] arg: List[Int]) -> ref[arg] List[Int]:
    return arg


def demo_immutable_ref():
    a = [1, 2, 3]
    a.append(4)
    print(return_immutable_ref(a)[3])
    print(len(a))


# return mutable reference
def return_mutable_ref2(
    ref[_] arg: List[Int],
) -> Pointer[List[Int], origin_of(arg)]:
    return Pointer(to=arg)


def demo_mutable_pointer():
    a = [1, 2, 3]
    b = return_mutable_ref2(a)
    c = b
    c[].append(4)
    print(len(a))
