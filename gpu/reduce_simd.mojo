from gpu import barrier, thread_idx, block_idx
from gpu.host import DeviceContext, DeviceBuffer
from gpu.memory import AddressSpace
from layout import Layout, LayoutTensor
from math import iota
from memory import stack_allocation
from sys import sizeof

alias dtype = DType.uint32
alias blocks = 4
alias threads = 4
alias num_elems = blocks * threads

alias layout = Layout.row_major(blocks, threads)
alias InputLayoutTensor = LayoutTensor[dtype, layout, StaticConstantOrigin]


fn simd_reduce_kernel(tensor: InputLayoutTensor, out_buffer: DeviceBuffer[dtype]):
    out_buffer[block_idx.x] = tensor.load[4](block_idx.x, 0).reduce_add()


fn main() raises:
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

        ctx.enqueue_function[simd_reduce_kernel](
            tensor,
            out_dev,
            grid_dim=blocks,
            block_dim=threads,
        )

        # Ensure we have the same result
        out_dev.enqueue_copy_to(out_host)
        ctx.synchronize()

        print(out_host)
