# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Mojo programming language playground for educational and experimentation purposes. It uses the nightly version of Mojo (via Pixi package manager).

## How to learn about Mojo and this codebase

* Read the Mojo API docs: https://docs.modular.com/llms-mojo.txt
* Read the README.md document.

Notes: for testing the implementation, place the files in the playground/ directory

## Environment Setup

## Common Commands

### Testing
```bash
pixi run mojo -I . tests/test_<module>.mojo             # Run tests for a specific module
```

### Building Shared Libraries (Python Interop)
```bash
pixi run mojo build source.mojo --emit shared-lib -o output.so
```

## Architecture

### Dual Directory Structure
- `examples/` - Standalone demonstration code that can be run directly
- `playground/` - Reusable library modules (mirrors `examples/` structure)

This dual structure exists because Mojo requires explicit module paths for imports. The `playground/` modules are designed to be imported by other code, while `examples/` contains runnable demonstrations.

### Module Organization

Each feature is organized in its own directory under both `examples/` and `playground/`:

- **Language features**: `async/`, `closures/`, `traits/`, `contextmanagers/`
- **Data structures**: `linkedlist/`, `dicts/`, `bytes/`
- **Algorithms**: `sort/`, `hash/`
- **System-level**: `sys/`, `mem/`, `gpu/`, `mlir/`
- **Interop**: `interop/` - Python-Mojo interoperability examples

### Python Interoperability

The `interop/` examples demonstrate how to:
1. Compile Mojo code to shared libraries (`.so` files)
2. Call Mojo functions from Python
3. Use the `python` module from within Mojo

### Testing Structure

Tests are located in `tests/` and follow the naming convention `test_<module>.mojo`. Each module has corresponding tests.

## Mojo Notes

- Mojo uses `fn` for functions (with strict typing) and `def` for Python-style functions
- Type annotations use syntax like `List[Int]`, `String`, etc.
- Variables are immutable by default; use `mut` keyword for mutable variables
- The project targets `linux-64` platform only
