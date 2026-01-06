from gpu.host import DeviceContext
from math import iota


fn demo_buffers() raises:
    alias dtype = DType.uint32
    alias blocks = 4
    alias threads = 4
    alias num_elems = blocks * threads
    with DeviceContext() as ctx:
        # In host buffer:
        # Allocate data on the host and return a buffer which owns that data
        var in_host = ctx.enqueue_create_host_buffer[dtype](num_elems)

        # Ensure that the buffer is filled with data before we use it
        ctx.synchronize()

        # Fill in the buffer with values from 0 to 15 and print it
        iota(in_host.unsafe_ptr(), num_elems)
        print(in_host)

        # In GPU device buffer:
        # Allocate a buffer for the GPU
        var in_dev = ctx.enqueue_create_buffer[dtype](num_elems)

        # Copy the data from the CPU to the GPU buffer
        # This is allocating global memory which can be accessed from any block and thread,
        # this memory is relatively slow compared to shared memory which is shared between all of the threads in a block
        in_host.enqueue_copy_to(in_dev)
        print(in_dev)
