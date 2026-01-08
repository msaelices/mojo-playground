from gpu import thread_idx
from gpu.host import HostBuffer, DeviceContext
from layout import Layout, LayoutTensor

comptime dtype = DType.uint8
comptime num_elems = 4

comptime layout = Layout.row_major(num_elems)
comptime Tensor = LayoutTensor[dtype, layout, MutAnyOrigin]


fn kernel(tensor: Tensor):
    tensor[thread_idx.x] = thread_idx.x


fn demo_scheduling() raises:
    with DeviceContext() as ctx:
        # All of these method calls run in the order that they were enqueued
        var dev_buffer = ctx.enqueue_create_buffer[dtype](num_elems)
        var host_buffer = ctx.enqueue_create_host_buffer[dtype](num_elems)

        var tensor = Tensor(dev_buffer)
        ctx.enqueue_function_checked[kernel, kernel](
            tensor, grid_dim=1, block_dim=num_elems
        )
        dev_buffer.enqueue_copy_to(host_buffer)

        ctx.synchronize()

        print(host_buffer)
