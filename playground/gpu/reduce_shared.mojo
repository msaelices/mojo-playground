from gpu import barrier, thread_idx, block_idx
from gpu.host import DeviceContext, HostBuffer
from gpu.memory import AddressSpace
from layout import Layout, LayoutTensor
from math import iota
from memory import stack_allocation, UnsafePointer
from sys import size_of

comptime dtype = DType.uint32
comptime blocks = 4
comptime threads = 4
comptime num_elems = blocks * threads

comptime layout = Layout.row_major(blocks, threads)
comptime InTensor = LayoutTensor[dtype, layout, MutableAnyOrigin]


fn sum_reduce_kernel(
    tensor: InTensor, out_buffer: UnsafePointer[Scalar[dtype]]
):
    # Allocates memory to be shared between threads once, prior to the kernel launch
    var shared = stack_allocation[
        blocks * size_of[dtype](),
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()

    # Place the corresponding value into shared memory
    shared[thread_idx.x] = tensor[block_idx.x, thread_idx.x][0]

    # Await all the threads to finish loading their values into shared memory
    barrier()

    # If this is the first thread, sum and write the result to global memory
    if thread_idx.x == 0:
        for i in range(threads):
            out_buffer[block_idx.x] += shared[i]


fn demo_reduce_shared() raises:
    with DeviceContext() as ctx:
        # In host buffer:
        # Allocate data on the host and return a buffer which owns that data
        var in_host = ctx.enqueue_create_host_buffer[dtype](num_elems)
        var in_dev = ctx.enqueue_create_buffer[dtype](num_elems)

        ctx.synchronize()

        # Fill in the buffer with values from 0 to 15 and print it
        iota(in_host.unsafe_ptr(), num_elems)

        # Copy the data from the CPU to the GPU buffer
        in_host.enqueue_copy_to(in_dev)

        # Set up the output buffer for the host and device
        var out_host = ctx.enqueue_create_host_buffer[dtype](blocks)
        var out_dev = ctx.enqueue_create_buffer[dtype](blocks)

        var tensor = LayoutTensor[dtype, layout](in_dev)

        # Reset the output values first
        ctx.enqueue_memset(out_dev, 0)

        ctx.enqueue_function_checked[sum_reduce_kernel](
            tensor,
            out_dev,
            grid_dim=blocks,
            block_dim=threads,
        )

        # Ensure we have the same result
        out_dev.enqueue_copy_to(out_host)
        ctx.synchronize()

        print(out_host)
