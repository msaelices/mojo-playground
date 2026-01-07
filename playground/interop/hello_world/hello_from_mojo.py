import os
import sys

sys.path.insert(0, "")
os.environ["MOJO_PYTHON_LIBRARY"] = ""
import mojo_module

mojo_module.hello_world("Python")
