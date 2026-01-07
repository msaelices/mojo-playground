from gpu.host import DeviceContext
from gpu import block_idx, thread_idx


fn kernel():
    print(
        "hello from block idx:",
        block_idx.x,
        block_idx.y,
        block_idx.z,
        "thread:",
        thread_idx.x,
        thread_idx.y,
        thread_idx.z,
    )


fn demo_hellothread() raises:
    # The DeviceContext represents a single stream of execution on a particular accelerator (GPU)
    # it servers as the low-level interface to the GPU
    with DeviceContext() as ctx:
        # grid_dim is the number of blocks in the grid
        # block_dim is the number of threads in a block
        grid_dim = 2
        block_dim = (4, 3, 2)
        print("grid dimension:", grid_dim)
        print("block dimension:", block_dim[0], block_dim[1], block_dim[2])
        ctx.enqueue_function[kernel](grid_dim=grid_dim, block_dim=block_dim)
        # wait for the GPU to finish executing the kernel
        ctx.synchronize()
        print("This will be printed after the kernel has finished executing")
