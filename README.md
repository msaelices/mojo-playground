# Personal playground to experiment with the Mojo programming language

## Disclaimer ⚠️

This software is just for self-educational purposes, and it's using the Mojo nightly version.

## Installation

1. **Install [pixi](https://pixi.sh/latest/)** package manager

2. **Clone the repository**

```bash
git clone git@github.com:msaelices/mojo-playground.git
cd mojo-playground
```

3. Install dependencies and start the pixi shell

```bash
pixi install
pixi shell
```

## Usage

### Running Examples

```bash
# Run a standalone example from examples/
pixi run mojo -I . examples/sort/bubble_demo.mojo

### Testing

```bash
# Run tests for a specific module (requires -I . for module resolution)
pixi run mojo -I . tests/test_sort.mojo
```

### Using as a Library

The `playground/` directory contains reusable library modules. To use them:

```mojo
from playground import sort

# Use the module
sort.bubble_sort(my_list)
```

## Project Structure

```
mojo-playground/
├── examples/           # Standalone demonstration code
│   ├── async/         # Async programming examples
│   ├── bytes/         # Byte manipulation
│   ├── closures/      # Closure examples
│   ├── compile/       # Compilation examples
│   ├── contextmanagers/
│   ├── dicts/         # Dictionary operations
│   ├── geom/          # Geometry examples
│   ├── gpu/           # GPU computing examples
│   ├── hash/          # Hash implementations
│   ├── interop/       # Python-Mojo interoperability
│   ├── iterators/     # Iterator implementations
│   ├── linkedlist/    # Linked list data structure
│   ├── mem/           # Memory management
│   ├── mlir/          # MLIR (Multi-Level Intermediate Representation)
│   ├── origins/       # Origin tracking examples
│   ├── sort/          # Sorting algorithms
│   ├── strings/       # String manipulation
│   ├── sys/           # System operations
│   └── traits/        # Trait implementations
├── playground/         # Reusable library modules (mirror of examples/)
├── tests/             # Test suite for each module
└── pixi.toml          # Pixi package manager configuration
```

## License

mojo-playground is licensed under the [MIT license](LICENSE).
