from gpu import barrier, thread_idx, block_idx
from gpu.host import DeviceContext, HostBuffer
from gpu.memory import AddressSpace
from layout import Layout, LayoutTensor
from math import iota
from memory import stack_allocation
from sys import size_of

# Matrix dimensions
comptime M = 4  # rows of A and rows of C
comptime N = 4  # cols of B and cols of C
comptime K = 4  # cols of A and rows of B
comptime BLOCK_SIZE = 2  # tile size

# Define the layouts for our matrices
comptime layout_a = Layout.row_major(M, K)
comptime layout_b = Layout.row_major(K, N)
comptime layout_c = Layout.row_major(M, N)

comptime MatrixA = LayoutTensor[DType.float32, layout_a, MutAnyOrigin]
comptime MatrixB = LayoutTensor[DType.float32, layout_b, MutAnyOrigin]
comptime MatrixC = LayoutTensor[DType.float32, layout_c, MutAnyOrigin]


fn matrix_multiply_kernel(A: MatrixA, B: MatrixB, C: MatrixC):
    # Get our thread and block indices
    var row = block_idx.y * BLOCK_SIZE + thread_idx.y
    var col = block_idx.x * BLOCK_SIZE + thread_idx.x

    # Each thread computes one element of C
    if row < M and col < N:
        var sum: Float32 = 0.0
        for k in range(K):
            sum += Float32(A[row, k][0] * B[k, col][0])
        C[row, col] = sum


fn matrix_multiply_shared_kernel(A: MatrixA, B: MatrixB, C: MatrixC):
    # Allocate shared memory for the tiles
    var A_tile = stack_allocation[
        BLOCK_SIZE * BLOCK_SIZE * size_of[DType.float32](),
        Scalar[DType.float32],
        address_space = AddressSpace.SHARED,
    ]()

    var B_tile = stack_allocation[
        BLOCK_SIZE * BLOCK_SIZE * size_of[DType.float32](),
        Scalar[DType.float32],
        address_space = AddressSpace.SHARED,
    ]()

    # Get our block and thread indices
    var bx = block_idx.x
    var by = block_idx.y
    var tx = thread_idx.x
    var ty = thread_idx.y

    # Calculate global row and column for this thread
    var row = by * BLOCK_SIZE + ty
    var col = bx * BLOCK_SIZE + tx

    var sum: Float32 = 0.0

    # Loop over tiles
    for tile in range((K + BLOCK_SIZE - 1) // BLOCK_SIZE):
        # Load tiles into shared memory
        if row < M and tile * BLOCK_SIZE + Int(tx) < K:
            A_tile[Int(ty) * BLOCK_SIZE + Int(tx)] = A[
                row, Int(tile * BLOCK_SIZE) + Int(tx)
            ][0]
        else:
            A_tile[Int(ty) * BLOCK_SIZE + Int(tx)] = 0.0

        if tile * BLOCK_SIZE + Int(ty) < K and col < N:
            B_tile[Int(ty) * BLOCK_SIZE + Int(tx)] = B[
                Int(tile * BLOCK_SIZE) + Int(ty), col
            ][0]
        else:
            B_tile[Int(ty) * BLOCK_SIZE + Int(tx)] = 0.0

        # Synchronize to make sure tiles are loaded
        barrier()

        # Compute the partial dot product
        for k in range(BLOCK_SIZE):
            sum += Float32(
                A_tile[Int(ty) * BLOCK_SIZE + k]
                * B_tile[k * BLOCK_SIZE + Int(tx)]
            )

        # Synchronize before loading next tile
        barrier()

    # Write the result
    if row < M and col < N:
        C[row, col] = sum


fn verify_result(
    host_a: HostBuffer[DType.float32],
    host_b: HostBuffer[DType.float32],
    host_c: HostBuffer[DType.float32],
) -> Bool:
    # Verify the result with a simple CPU implementation
    var A = LayoutTensor[DType.float32, layout_a](host_a)
    var B = LayoutTensor[DType.float32, layout_b](host_b)
    var C = LayoutTensor[DType.float32, layout_c](host_c)

    var correct = True

    for i in range(M):
        for j in range(N):
            var expected: Float32 = 0.0
            for k in range(K):
                expected += Float32(A[i, k][0] * B[k, j][0])

            var diff = Float32(C[i, j][0] - expected)
            if diff < -0.01 or diff > 0.01:
                print(
                    "Error at [",
                    i,
                    ",",
                    j,
                    "]: Got",
                    C[i, j][0],
                    "Expected",
                    expected,
                )
                correct = False

    return correct


fn print_matrix(tensor: LayoutTensor):
    # Since we know our dimension, we can use them directly
    for i in range(M):
        for j in range(N):
            print(tensor[i, j][0], end=" ")
        print("")


fn demo_matrix_multiply() raises:
    with DeviceContext() as ctx:
        # Allocate host memory for matrices
        var a_host = ctx.enqueue_create_host_buffer[DType.float32](M * K)
        var b_host = ctx.enqueue_create_host_buffer[DType.float32](K * N)
        var c_host = ctx.enqueue_create_host_buffer[DType.float32](M * N)

        # Allocate device memory
        var a_dev = ctx.enqueue_create_buffer[DType.float32](M * K)
        var b_dev = ctx.enqueue_create_buffer[DType.float32](K * N)
        var c_dev = ctx.enqueue_create_buffer[DType.float32](M * N)

        ctx.synchronize()

        # Initialize matrices with simple values
        var a_ptr = a_host.unsafe_ptr()
        var b_ptr = b_host.unsafe_ptr()

        for i in range(M):
            for j in range(K):
                a_ptr.offset(i * K + j).store(Float32(i + j))

        for i in range(K):
            for j in range(N):
                b_ptr.offset(i * N + j).store(Float32(i - j))

        # Transfer data to device
        a_host.enqueue_copy_to(a_dev)
        b_host.enqueue_copy_to(b_dev)

        # Clear the result matrix
        ctx.enqueue_memset(c_dev, 0)

        # Create tensor views of the device buffers
        var A = LayoutTensor[DType.float32, layout_a](a_dev)
        var B = LayoutTensor[DType.float32, layout_b](b_dev)
        var C = LayoutTensor[DType.float32, layout_c](c_dev)

        # Calculate grid and block dimensions
        var grid_dim = (
            (M + BLOCK_SIZE - 1) // BLOCK_SIZE,
            (N + BLOCK_SIZE - 1) // BLOCK_SIZE,
        )
        var block_dim = (BLOCK_SIZE, BLOCK_SIZE)

        print("Running matrix multiplication...")
        print("Matrix A:", M, "x", K)
        print("Matrix B:", K, "x", N)
        print("Block size:", BLOCK_SIZE, "x", BLOCK_SIZE)

        # Run the standard matrix multiplication kernel
        print("\nStandard matrix multiplication:")
        ctx.enqueue_function_checked[
            matrix_multiply_kernel, matrix_multiply_kernel
        ](A, B, C, grid_dim=grid_dim, block_dim=block_dim)

        # Copy result back to host and verify
        c_dev.enqueue_copy_to(c_host)
        ctx.synchronize()

        # Create tensor views of the host buffers for printing
        var host_A = LayoutTensor[DType.float32, layout_a](a_host)
        var host_B = LayoutTensor[DType.float32, layout_b](b_host)
        var host_C = LayoutTensor[DType.float32, layout_c](c_host)

        print("Matrix A:")
        print_matrix(host_A)

        print("\nMatrix B:")
        print_matrix(host_B)

        print("\nResult matrix C:")
        print_matrix(host_C)

        var result = verify_result(a_host, b_host, c_host)
        print("Verification:", "Passed" if result else "Failed")

        # Run the shared memory version
        print("\nShared memory matrix multiplication:")
        ctx.enqueue_memset(c_dev, 0)  # Clear the result matrix

        ctx.enqueue_function_checked[
            matrix_multiply_shared_kernel, matrix_multiply_shared_kernel
        ](A, B, C, grid_dim=grid_dim, block_dim=block_dim)

        # Copy result back to host and verify
        c_dev.enqueue_copy_to(c_host)
        ctx.synchronize()

        print("Result matrix C:")
        print_matrix(host_C)

        result = verify_result(a_host, b_host, c_host)
        print("Verification:", "Passed" if result else "Failed")
