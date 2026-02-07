from gpu import thread_idx, block_idx
from gpu.host import DeviceContext


def demo_gpuinfo():
    fn print_threads():
        print("GPU thread: [", thread_idx.x, thread_idx.y, thread_idx.z, "]")

    fn block_kernel():
        print(
            "block: [",
            block_idx.x,
            block_idx.y,
            block_idx.z,
            "]",
            "thread: [",
            thread_idx.x,
            thread_idx.y,
            thread_idx.z,
            "]",
        )

    var ctx = DeviceContext()

    ctx.enqueue_function[print_threads, print_threads](
        grid_dim=1, block_dim=2
    )
    ctx.enqueue_function[block_kernel, block_kernel](
        grid_dim=(2, 2), block_dim=2
    )

    ctx.synchronize()

    print(
        "This will be printed after the GPU has completed its work, because of"
        " the synchronize call above."
    )
