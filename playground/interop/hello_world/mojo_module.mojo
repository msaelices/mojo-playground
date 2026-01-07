from python import PythonObject
from python.bindings import PythonModuleBuilder
from os import abort


@export
fn PyInit_mojo_module() -> PythonObject:
    try:
        var m = PythonModuleBuilder("mojo_module")
        m.def_function[hello_world](
            "hello_world", docstring="Prints 'Hello, World' from Mojo"
        )
        return m.finalize()
    except e:
        return abort[PythonObject](
            String("Failed to initialize mojo_module: ", e)
        )


fn hello_world(name: PythonObject) raises:
    print("Hello to", name, "from Mojo 👋")
