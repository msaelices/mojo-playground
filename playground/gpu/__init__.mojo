from .buffers import demo_buffers
from .gpuinfo import demo_gpuinfo
from .hellothread import demo_hellothread, kernel
from .mandelbrot import demo_mandelbrot
from .matrix_multiply import (
    demo_matrix_multiply,
    matrix_multiply_kernel,
    matrix_multiply_shared_kernel,
)
from .matrix_transpose import (
    demo_matrix_transpose,
    naive_transpose_kernel,
    tiled_transpose_kernel,
)
from .multiply import demo_multiply, print_values_kernel, multiply_kernel
from .nbody import demo_nbody, update_particles_kernel
from .reduce_shared import demo_reduce_shared, sum_reduce_kernel
from .reduce_simd import demo_reduce_simd, simd_reduce_kernel
from .reduce_warp import demo_reduce_warp, warp_reduce_kernel
from .rl_maze import demo_rl_maze
from .scheduling import demo_scheduling
