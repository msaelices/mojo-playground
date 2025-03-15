from gpu import thread_idx, block_idx
from gpu.host import DeviceContext
from layout import Layout, LayoutTensor
from math import iota

alias dtype = DType.uint32
alias blocks = 4
alias threads = 4
alias num_elems = blocks * threads

alias layout = Layout.row_major(blocks, threads)
alias InputLayoutTensor = LayoutTensor[dtype, layout, StaticConstantOrigin]


fn print_values_kernel(tensor: InputLayoutTensor):
    var block_id = block_idx.x
    var thread_id = thread_idx.x
    print(
        "block_id: ",
        block_id,
        " thread_id: ",
        thread_id,
        " tensor[block_id, thread_id]: ",
        tensor[block_id, thread_id],
    )


fn multiply_kernel(tensor: InputLayoutTensor):
    tensor[block_idx.x, thread_idx.x] *= 2


fn main() raises:
    with DeviceContext() as ctx:
        # In host buffer:
        # Allocate data on the host and return a buffer which owns that data
        var in_host = ctx.enqueue_create_host_buffer[dtype](num_elems)
        var in_dev = ctx.enqueue_create_buffer[dtype](num_elems)

        ctx.synchronize()
        iota(in_host.unsafe_ptr(), num_elems)

        print(in_host)

        in_host.enqueue_copy_to(in_dev)

        # Ensure that the buffer is filled with data before we use it
        ctx.synchronize()

        # In GPU device buffer:
        # Allocate a buffer for the GPU
        var tensor = LayoutTensor[dtype, layout](in_dev)

        # Print the values in the indexed tensors before multiplying them
        ctx.enqueue_function[print_values_kernel](
            tensor, grid_dim=blocks, block_dim=threads
        )

        # Multiply the values in the in dev tensor
        ctx.enqueue_function[multiply_kernel](
            tensor, grid_dim=blocks, block_dim=threads
        )

        # Copy the values back to the host buffer
        in_dev.enqueue_copy_to(in_host)

        ctx.synchronize()

        host_tensor = LayoutTensor[dtype, layout](in_host)
        print(host_tensor)
