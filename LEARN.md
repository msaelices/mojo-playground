# Learning index

A map of this playground for learning Mojo by reading and running small,
focused examples. Each topic lives in two mirrored places:

- `playground/<topic>/` — the reusable module (the concept, importable and tested).
- `examples/<topic>/` — a runnable demo you can execute directly.

Run any demo with:

```bash
pixi run mojo -I . examples/<topic>/<file>_demo.mojo
```

The tests under `tests/test_<topic>.mojo` are also worth reading: they show the
modules used in isolation.

## For Python developers

| Topic | What you learn | Code |
|-------|----------------|------|
| `pythonic` | Mojo introduced gradually for Python programmers: `var`, value semantics vs. references, mutability, and where pointers start to matter. | `examples/pythonic/progressive_exposure.mojo` |

## Core language features

| Topic | What you learn | Code |
|-------|----------------|------|
| `traits` | Trait composition (`A & B`), generic bounds, and self-qualified struct parameters. | `playground/traits/traits.mojo` |
| `closures` | Capturing closures and higher-order functions (passing functions as parameters). | `playground/closures/closure.mojo`, `playground/closures/high_order_func.mojo` |
| `contextmanagers` | The `with` protocol via `__enter__` / `__exit__` for guaranteed cleanup. | `playground/contextmanagers/server.mojo` |
| `iterators` | The iterator protocol (`__iter__` / `__next__`) for lazy iteration. | `playground/iterators/reader.mojo` |
| `variants` | `Variant[...]` tagged unions: type-safe heterogeneous values, `isa[T]()` and the safe `v[T]` accessor, and reassigning across types. | `playground/variants/cells.mojo`, `playground/variants/reassign.mojo` |
| `metaprogramming` | Compile-time evaluation: `comptime` parameters/constants, `comptime if`/`for`, and parameter recursion that bakes results into the binary. | `playground/metaprogramming/fibonacci.mojo` |
| `compile` | Inspecting generated LLVM IR / assembly with `@export` (`abi("C")`) and `compile_info`. | `playground/compile/add.mojo`, `playground/compile/forloop.mojo` |
| `mlir` | Building a type directly on MLIR primitives (`__mlir_type`, `__mlir_attr`, `__mlir_op`). | `playground/mlir/mybool.mojo` |

## Memory, pointers and ownership

| Topic | What you learn | Code |
|-------|----------------|------|
| `mem` | Linear types: `@explicit_destroy` `alloc`/`dealloc` where the compiler forces every allocation to be released on every path, plus the `unsafe_span()` view. | `playground/mem/linear_alloc.mojo` |
| `origins` | The origin system (reference provenance) and parametric pointer types that encode borrowing. | `playground/origins/withpointer.mojo` |
| `linkedlist` | A heap-backed singly linked list with `UnsafePointer`, manual `alloc`/`free`, and `__del__` cleanup. | `playground/linkedlist/linkedlist.mojo` |
| `strings` | Byte-level string access, `UnsafePointer`, and `memcpy`; plus a join micro-benchmark. | `playground/strings/str_and_bytes.mojo`, `playground/strings/pointers.mojo`, `playground/strings/bench_join.mojo` |

## Data structures and algorithms

| Topic | What you learn | Code |
|-------|----------------|------|
| `dicts` | The stdlib `Dict` and a lookup benchmark. | `playground/dicts/dict_benchmark.mojo` |
| `sort` | A bubble sort showing in-place mutation of `List`. | `playground/sort/bubble.mojo` |
| `hash` | A byte-level hash function over strings. | `playground/hash/hash.mojo` |
| `bytes` | Bitwise/`SIMD` byte operations (folds, rotations). | `playground/bytes/bytes_ops.mojo` |
| `geom` | Composing structs and methods (Point / Line / Path). | `playground/geom/geom.mojo` |

## System and performance

| Topic | What you learn | Code |
|-------|----------------|------|
| `sys` | Querying target/CPU properties at compile time (`size_of`, target info). | `playground/sys/cpuinfo.mojo` |

## Concurrency

| Topic | What you learn | Code |
|-------|----------------|------|
| `async_module` | `async`/`await` tasks and synchronization. | `playground/async_module/tasks.mojo` |

## GPU programming

The `gpu/` topic is the largest, building up from a hello-world kernel to full
algorithms. All kernels are launched through `DeviceContext`.

| File | What you learn |
|------|----------------|
| `gpuinfo.mojo`, `hellothread.mojo` | Thread/block indices and launching a kernel with a grid/block configuration. |
| `buffers.mojo`, `scheduling.mojo`, `multiply.mojo` | Device buffers, host/device transfers, and elementwise kernels. |
| `reduce_simd.mojo`, `reduce_shared.mojo`, `reduce_warp.mojo` | Three reduction strategies: SIMD lanes, shared memory + barriers, and warp primitives. |
| `matrix_multiply.mojo`, `matrix_transpose.mojo` | Tiled matmul/transpose with shared memory. |
| `mandelbrot.mojo`, `nbody.mojo`, `rl_maze.mojo` | Larger end-to-end kernels (fractal, N-body, parallel reinforcement-learning maze). |

Code lives under `playground/gpu/` with demos in `examples/gpu/`.
GPU examples need a supported GPU; they fail at link time on machines without one.

## Python interoperability

| Topic | What you learn | Code |
|-------|----------------|------|
| `interop` | Exporting Mojo functions as a Python extension module with `PythonModuleBuilder` and `PythonObject`. | `playground/interop/hello_world/mojo_module.mojo`, `playground/interop/factorial/mojo_module.mojo` |
