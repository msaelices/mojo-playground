from std.python import PythonObject
from std.python.bindings import PythonModuleBuilder
from std.os import abort


@export
def PyInit_mojo_module() -> PythonObject:
    try:
        var m = PythonModuleBuilder("mojo_module")
        m.def_function[hello_world](
            "hello_world", docstring="Prints 'Hello, World' from Mojo"
        )
        return m.finalize()
    except e:
        abort("Failed to initialize mojo_module: " + String(e))


def hello_world(name: PythonObject) raises:
    print("Hello to", name, "from Mojo 👋")
