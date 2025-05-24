import max._mojo.mojo_importer
import os
import sys

sys.path.insert(0, "")
os.environ["MOJO_PYTHON_LIBRARY"] = ""

import mojo_module

print(mojo_module.factorial(5))
