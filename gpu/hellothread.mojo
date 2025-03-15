from gpu.host import DeviceContext
from gpu import thread_idx


fn kernel():
    print("hello from thread:", thread_idx.x, thread_idx.y, thread_idx.z)


fn main() raises:
    # The DeviceContext represents a single stream of execution on a particular accelerator (GPU)
    # it servers as the low-level interface to the GPU
    with DeviceContext() as ctx:
        # grid_dim is the number of blocks in the grid
        # block_dim is the number of threads in a block
        ctx.enqueue_function[kernel](grid_dim=1, block_dim=(2, 2, 2))
        # wait for the GPU to finish executing the kernel
        ctx.synchronize()
        print("This will be printed after the kernel has finished executing")
