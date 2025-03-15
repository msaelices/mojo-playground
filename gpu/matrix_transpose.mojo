from gpu import barrier, thread_idx, block_idx
from gpu.host import DeviceContext, DeviceBuffer
from gpu.memory import AddressSpace
from layout import Layout, LayoutTensor
from memory import stack_allocation
from sys import sizeof

# Matrix dimensions
alias M = 6  # rows of input matrix
alias N = 4  # cols of input matrix
alias BLOCK_SIZE = 2  # tile size for shared memory implementation

# Define the layouts for our matrices
alias layout_in = Layout.row_major(M, N)  # Input matrix layout
alias layout_out = Layout.row_major(N, M)  # Output (transposed) matrix layout

alias InputMatrix = LayoutTensor[DType.float32, layout_in, StaticConstantOrigin]
alias OutputMatrix = LayoutTensor[DType.float32, layout_out, StaticConstantOrigin]


fn naive_transpose_kernel(input: InputMatrix, output: OutputMatrix):
    # Get our thread and block indices
    var row = block_idx.y * BLOCK_SIZE + thread_idx.y
    var col = block_idx.x * BLOCK_SIZE + thread_idx.x

    # Each thread transposes one element
    if row < M and col < N:
        # Output has dimensions N x M
        output[col, row] = input[row, col]


fn tiled_transpose_kernel(input: InputMatrix, output: OutputMatrix):
    # Allocate shared memory for the tile
    var tile = stack_allocation[
        BLOCK_SIZE * BLOCK_SIZE * sizeof[DType.float32](),
        Scalar[DType.float32],
        address_space = AddressSpace.SHARED,
    ]()

    # Get our block and thread indices
    var bx = block_idx.x
    var by = block_idx.y
    var tx = thread_idx.x
    var ty = thread_idx.y

    # Input row and column
    var in_row = by * BLOCK_SIZE + ty
    var in_col = bx * BLOCK_SIZE + tx

    # Load data into shared memory if within bounds
    if in_row < M and in_col < N:
        # Load element from global memory to shared memory
        tile[ty * BLOCK_SIZE + tx] = input[in_row, in_col][0]

    # Ensure all threads in the block have loaded their data
    barrier()

    # Calculate output coordinates where this thread will write
    # For the output, we swap dimensions: output is N x M
    var out_col = by * BLOCK_SIZE + tx
    var out_row = bx * BLOCK_SIZE + ty

    # Write transposed data to output matrix
    if out_row < N and out_col < M:
        output[out_row, out_col] = tile[tx * BLOCK_SIZE + ty]


fn verify_transpose(
    input_host: DeviceBuffer[DType.float32],
    output_host: DeviceBuffer[DType.float32],
) -> Bool:
    var input = LayoutTensor[DType.float32, layout_in](input_host)
    var output = LayoutTensor[DType.float32, layout_out](output_host)

    var correct = True

    for i in range(M):
        for j in range(N):
            if input[i, j][0] != output[j, i][0]:
                print(
                    "Error at [",
                    i,
                    ",",
                    j,
                    "]: Input =",
                    input[i, j][0],
                    "Output =",
                    output[j, i][0],
                )
                correct = False

    return correct


fn print_matrix(tensor: LayoutTensor, rows: Int, cols: Int):
    for i in range(rows):
        for j in range(cols):
            print(tensor[i, j][0], end=" ")
        print("")


fn main() raises:
    with DeviceContext() as ctx:
        # Allocate host memory for matrices
        var input_host = ctx.enqueue_create_host_buffer[DType.float32](M * N)
        var output_host = ctx.enqueue_create_host_buffer[DType.float32](M * N)

        # Allocate device memory
        var input_dev = ctx.enqueue_create_buffer[DType.float32](M * N)
        var output_dev = ctx.enqueue_create_buffer[DType.float32](M * N)

        ctx.synchronize()

        # Initialize input matrix with simple values
        var input_ptr = input_host.unsafe_ptr()

        for i in range(M):
            for j in range(N):
                input_ptr.offset(i * N + j).store(Float32(i * 10 + j))

        # Transfer data to device
        input_host.enqueue_copy_to(input_dev)

        # Clear the output matrix
        ctx.enqueue_memset(output_dev, 0)

        # Create tensor views of the device buffers
        var input_tensor = LayoutTensor[DType.float32, layout_in](input_dev)
        var output_tensor = LayoutTensor[DType.float32, layout_out](output_dev)

        # Calculate grid and block dimensions
        # We need to cover the entire input matrix with thread blocks
        var grid_dim = (
            (N + BLOCK_SIZE - 1) // BLOCK_SIZE,
            (M + BLOCK_SIZE - 1) // BLOCK_SIZE,
        )
        var block_dim = (BLOCK_SIZE, BLOCK_SIZE)

        print("Running matrix transposition...")
        print("Input matrix:", M, "x", N)
        print("Output matrix:", N, "x", M)
        print("Block size:", BLOCK_SIZE, "x", BLOCK_SIZE)

        # Run the naive transpose kernel
        print("\nNaive matrix transposition:")
        ctx.enqueue_function[naive_transpose_kernel](
            input_tensor, output_tensor, grid_dim=grid_dim, block_dim=block_dim
        )

        # Copy result back to host and verify
        output_dev.enqueue_copy_to(output_host)
        ctx.synchronize()

        # Create tensor views of the host buffers for printing
        var host_input = LayoutTensor[DType.float32, layout_in](input_host)
        var host_output = LayoutTensor[DType.float32, layout_out](output_host)

        print("Input matrix:")
        print_matrix(host_input, M, N)

        print("\nTransposed matrix:")
        print_matrix(host_output, N, M)

        var result = verify_transpose(input_host, output_host)
        print("Verification:", "Passed" if result else "Failed")

        # Run the shared memory (tiled) version
        print("\nTiled matrix transposition:")
        ctx.enqueue_memset(output_dev, 0)  # Clear the output matrix

        ctx.enqueue_function[tiled_transpose_kernel](
            input_tensor, output_tensor, grid_dim=grid_dim, block_dim=block_dim
        )

        # Copy result back to host and verify
        output_dev.enqueue_copy_to(output_host)
        ctx.synchronize()

        print("Transposed matrix:")
        print_matrix(host_output, N, M)

        result = verify_transpose(input_host, output_host)
        print("Verification:", "Passed" if result else "Failed")
