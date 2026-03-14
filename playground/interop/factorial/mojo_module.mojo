from std.python import PythonObject
from std.python.bindings import PythonModuleBuilder
from std import math
from std.os import abort


@export
def PyInit_mojo_module() -> PythonObject:
    try:
        var m = PythonModuleBuilder("mojo_module")
        m.def_function[factorial]("factorial", docstring="Compute n!")
        return m.finalize()
    except e:
        abort("error creating Python Mojo module: " + String(e))


def factorial(py_obj: PythonObject) raises -> PythonObject:
    # Raises an exception if `py_obj` is not convertible to a Mojo `Int`.
    var n = Int(py=py_obj)

    return math.factorial(n)
