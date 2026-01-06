from testing import assert_true

from playground.gpu import (
    demo_buffers,
    demo_gpuinfo,
    demo_hellothread,
    demo_mandelbrot,
    demo_matrix_multiply,
    demo_matrix_transpose,
    demo_multiply,
    demo_nbody,
    demo_reduce_shared,
    demo_reduce_simd,
    demo_reduce_warp,
    demo_rl_maze,
    demo_scheduling,
)


def test_gpu_imports():
    # Test that GPU demo functions can be imported
    assert_true(True)


def main():
    test_gpu_imports()
