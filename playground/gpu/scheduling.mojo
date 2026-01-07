from memory import UnsafePointer
from gpu import thread_idx
from gpu.host import HostBuffer, DeviceContext

alias dtype = DType.uint8


fn kernel(buffer: UnsafePointer[Scalar[dtype]]):
    buffer[thread_idx.x] = thread_idx.x


fn demo_scheduling() raises:
    alias num_elems = 4
    with DeviceContext() as ctx:
        # All of these method calls run in the order that they were enqueued
        var dev_buffer = ctx.enqueue_create_buffer[dtype](num_elems)
        var host_buffer = ctx.enqueue_create_host_buffer[dtype](num_elems)
        ctx.enqueue_function[kernel](
            dev_buffer, grid_dim=1, block_dim=num_elems
        )
        dev_buffer.enqueue_copy_to(host_buffer)

        ctx.synchronize()

        print(host_buffer)
