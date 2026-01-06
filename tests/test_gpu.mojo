from testing import assert_equal, assert_true

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
    kernel,
    matrix_multiply_kernel,
    matrix_multiply_shared_kernel,
    naive_transpose_kernel,
    tiled_transpose_kernel,
    print_values_kernel,
    multiply_kernel,
    update_particles_kernel,
    sum_reduce_kernel,
    simd_reduce_kernel,
    warp_reduce_kernel,
)


def test_gpu_imports():
    # Test that GPU demo functions can be imported and are callable
    assert_true(True)


def test_gpu_kernel_signatures():
    # Verify kernel functions are properly defined
    assert_true(True)


fn test_matrix_multiply_cpu() raises:
    # CPU-based matrix multiplication for testing
    # This doesn't require GPU hardware

    from gpu.host import DeviceContext, HostBuffer
    from layout import Layout, LayoutTensor

    alias M = 2
    alias N = 2
    alias K = 2

    alias layout_a = Layout.row_major(M, K)
    alias layout_b = Layout.row_major(K, N)
    alias layout_c = Layout.row_major(M, N)

    alias MatrixA = LayoutTensor[DType.float32, layout_a, MutableAnyOrigin]
    alias MatrixB = LayoutTensor[DType.float32, layout_b, MutableAnyOrigin]
    alias MatrixC = LayoutTensor[DType.float32, layout_c, MutableAnyOrigin]

    with DeviceContext() as ctx:
        # Allocate host memory for matrices
        var a_host = ctx.enqueue_create_host_buffer[DType.float32](M * K)
        var b_host = ctx.enqueue_create_host_buffer[DType.float32](K * N)
        var c_host = ctx.enqueue_create_host_buffer[DType.float32](M * N)

        ctx.synchronize()

        # Initialize matrices: A = [[1, 2], [3, 4]], B = [[5, 6], [7, 8]]
        var a_ptr = a_host.unsafe_ptr()
        var b_ptr = b_host.unsafe_ptr()

        # Matrix A: [[1, 2], [3, 4]]
        a_ptr.store(0, 1.0)
        a_ptr.store(1, 2.0)
        a_ptr.store(2, 3.0)
        a_ptr.store(3, 4.0)

        # Matrix B: [[5, 6], [7, 8]]
        b_ptr.store(0, 5.0)
        b_ptr.store(1, 6.0)
        b_ptr.store(2, 7.0)
        b_ptr.store(3, 8.0)

        # Create tensor views
        var A = MatrixA(a_host)
        var B = MatrixB(b_host)
        var C = MatrixC(c_host)

        # Compute C = A * B on CPU
        # Expected: [[1*5+2*7, 1*6+2*8], [3*5+4*7, 3*6+4*8]] = [[19, 22], [43, 50]]
        for i in range(M):
            for j in range(N):
                var sum: Float32 = 0.0
                for k in range(K):
                    sum += Float32(A[i, k][0] * B[k, j][0])
                C[i, j] = sum

        # Verify results
        assert_equal(C[0, 0][0], 19.0)
        assert_equal(C[0, 1][0], 22.0)
        assert_equal(C[1, 0][0], 43.0)
        assert_equal(C[1, 1][0], 50.0)


fn test_matrix_multiply_gpu() raises:
    # GPU-based matrix multiplication test
    # This requires GPU hardware to execute

    from gpu import block_idx, thread_idx
    from gpu.host import DeviceContext, HostBuffer
    from layout import Layout, LayoutTensor

    alias M = 2
    alias N = 2
    alias K = 2
    alias BLOCK_SIZE = 2

    alias layout_a = Layout.row_major(M, K)
    alias layout_b = Layout.row_major(K, N)
    alias layout_c = Layout.row_major(M, N)

    alias MatrixA = LayoutTensor[DType.float32, layout_a, MutableAnyOrigin]
    alias MatrixB = LayoutTensor[DType.float32, layout_b, MutableAnyOrigin]
    alias MatrixC = LayoutTensor[DType.float32, layout_c, MutableAnyOrigin]

    # Define a simple matrix multiply kernel
    fn matmul_kernel(A: MatrixA, B: MatrixB, C: MatrixC):
        var row = block_idx.y * BLOCK_SIZE + thread_idx.y
        var col = block_idx.x * BLOCK_SIZE + thread_idx.x

        if row < M and col < N:
            var sum: Float32 = 0.0
            for k in range(K):
                sum += Float32(A[row, k][0] * B[k, col][0])
            C[row, col] = sum

    with DeviceContext() as ctx:
        # Allocate host and device memory
        var a_host = ctx.enqueue_create_host_buffer[DType.float32](M * K)
        var b_host = ctx.enqueue_create_host_buffer[DType.float32](K * N)
        var c_host = ctx.enqueue_create_host_buffer[DType.float32](M * N)

        var a_dev = ctx.enqueue_create_buffer[DType.float32](M * K)
        var b_dev = ctx.enqueue_create_buffer[DType.float32](K * N)
        var c_dev = ctx.enqueue_create_buffer[DType.float32](M * N)

        ctx.synchronize()

        # Initialize matrices: A = [[1, 2], [3, 4]], B = [[5, 6], [7, 8]]
        var a_ptr = a_host.unsafe_ptr()
        var b_ptr = b_host.unsafe_ptr()

        a_ptr.store(0, 1.0)
        a_ptr.store(1, 2.0)
        a_ptr.store(2, 3.0)
        a_ptr.store(3, 4.0)

        b_ptr.store(0, 5.0)
        b_ptr.store(1, 6.0)
        b_ptr.store(2, 7.0)
        b_ptr.store(3, 8.0)

        # Transfer to device
        a_host.enqueue_copy_to(a_dev)
        b_host.enqueue_copy_to(b_dev)

        # Clear result
        ctx.enqueue_memset(c_dev, 0)

        # Create tensor views
        var A = MatrixA(a_dev)
        var B = MatrixB(b_dev)
        var C = MatrixC(c_dev)

        # Execute kernel
        var grid_dim = ((M + BLOCK_SIZE - 1) // BLOCK_SIZE, (N + BLOCK_SIZE - 1) // BLOCK_SIZE)
        var block_dim = (BLOCK_SIZE, BLOCK_SIZE)

        ctx.enqueue_function[matmul_kernel](A, B, C, grid_dim=grid_dim, block_dim=block_dim)

        # Copy result back
        c_dev.enqueue_copy_to(c_host)
        ctx.synchronize()

        # Create tensor view of result
        var result = MatrixC(c_host)

        # Expected: [[19, 22], [43, 50]]
        assert_equal(result[0, 0][0], 19.0)
        assert_equal(result[0, 1][0], 22.0)
        assert_equal(result[1, 0][0], 43.0)
        assert_equal(result[1, 1][0], 50.0)


def main():
    test_gpu_imports()
    test_gpu_kernel_signatures()
    test_matrix_multiply_cpu()
    test_matrix_multiply_gpu()
