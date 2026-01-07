from gpu import barrier, thread_idx, block_idx
from gpu.host import DeviceContext, HostBuffer, DeviceBuffer
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
comptime out_layout = Layout.row_major(blocks)
comptime InTensor = LayoutTensor[dtype, layout, MutAnyOrigin]
comptime OutTensor = LayoutTensor[dtype, out_layout, MutAnyOrigin]


fn simd_reduce_kernel(
    tensor: InTensor, out_tensor: OutTensor
):
    var result = tensor.load[4](Int(block_idx.x), 0).reduce_add()
    out_tensor[block_idx.x] = result


fn demo_reduce_simd() raises:
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

        var tensor = InTensor(in_dev)
        var out_tensor = OutTensor(out_dev)

        # Reset the output values first
        ctx.enqueue_memset(out_dev, 0)

        ctx.enqueue_function_checked[simd_reduce_kernel, simd_reduce_kernel](
            tensor,
            out_tensor,
            grid_dim=blocks,
            block_dim=threads,
        )

        # Ensure we have the same result
        out_dev.enqueue_copy_to(out_host)
        ctx.synchronize()

        print(out_host)
