from gpu import thread_idx, block_idx
from gpu.host import DeviceContext, DeviceBuffer
from layout import Layout, LayoutTensor
import math
from memory import memset

# Image dimensions - keep them small for quicker testing
alias WIDTH = 400
alias HEIGHT = 300
alias MAX_ITER = 100  # Reduced from 1000 for faster execution
alias BLOCK_SIZE = 16

# Define the layout for our output image
alias layout_out = Layout.row_major(HEIGHT, WIDTH)
alias OutputImage = LayoutTensor[DType.uint8, layout_out, StaticConstantOrigin]


# Complex number structure for mandelbrot calculations
struct Complex:
    var real: Float64
    var imag: Float64

    fn __init__(mut self, r: Float64, i: Float64):
        self.real = r
        self.imag = i

    fn add(self, other: Complex) -> Complex:
        return Complex(self.real + other.real, self.imag + other.imag)

    fn mul(self, other: Complex) -> Complex:
        var r = self.real * other.real - self.imag * other.imag
        var i = self.real * other.imag + self.imag * other.real
        return Complex(r, i)

    fn abs_squared(self) -> Float64:
        return self.real * self.real + self.imag * self.imag


fn mandelbrot_kernel(output: OutputImage):
    # Get thread and block indices
    var x = block_idx.x * BLOCK_SIZE + thread_idx.x
    var y = block_idx.y * BLOCK_SIZE + thread_idx.y

    # Check boundaries
    if x >= WIDTH or y >= HEIGHT:
        return

    # Map pixel coordinates to the complex plane
    # The mandelbrot set is typically viewed in the region [-2.5, 1] x [-1, 1]
    var x_pos = 3.5 * x / Float64(WIDTH) - 2.5
    var y_pos = 2.0 * y / Float64(HEIGHT) - 1.0

    # Mandelbrot iteration
    var c = Complex(x_pos, y_pos)
    var z = Complex(0.0, 0.0)

    var iter = 0
    while iter < MAX_ITER and z.abs_squared() < 4.0:
        z = z.mul(z).add(c)
        iter += 1

    # Color mapping (simple grayscale)
    var color: UInt8
    if iter == MAX_ITER:
        color = 0  # Black for points in the set
    else:
        # Smooth coloring based on escape iteration count
        # Map the iteration count to a value between 0 and 255
        var smoothed = Float64(iter) / Float64(MAX_ITER)
        color = UInt8(255.0 * (1.0 - smoothed))

    # Write the color to the output image
    output[y, x] = color


fn save_ppm(filename: String, buffer: DeviceBuffer[DType.uint8]) raises:
    # Create a tensor view for easier access
    var image = LayoutTensor[DType.uint8, layout_out](buffer)

    # Open the file - we'll use PPM (P3) text format which is easier to write
    with open(filename, "w") as f:
        # Write PPM header (P3 format: width, height, max color value)
        # P3 is ASCII PPM format which is easier to write but larger files
        f.write(String("P3\n" + String(WIDTH) + " " + String(HEIGHT) + "\n255\n"))

        # Write image data as RGB triplets (grayscale, so R=G=B)
        for y in range(HEIGHT):
            for x in range(WIDTH):
                var pixel = image[y, x][0]
                f.write(
                    String(pixel) + " " + String(pixel) + " " + String(pixel) + "\n"
                )


fn main() raises:
    print("Rendering Mandelbrot set...")
    print("Image dimensions:", WIDTH, "x", HEIGHT)
    print("Maximum iterations:", MAX_ITER)

    with DeviceContext() as ctx:
        # Allocate host buffer for the output image
        var host_buffer = ctx.enqueue_create_host_buffer[DType.uint8](WIDTH * HEIGHT)

        # Allocate device buffer for the output image
        var device_buffer = ctx.enqueue_create_buffer[DType.uint8](WIDTH * HEIGHT)

        # Create tensor view of the device buffer
        var output = LayoutTensor[DType.uint8, layout_out](device_buffer)

        # Calculate grid and block dimensions
        var grid_dim = (
            (WIDTH + BLOCK_SIZE - 1) // BLOCK_SIZE,
            (HEIGHT + BLOCK_SIZE - 1) // BLOCK_SIZE,
        )
        var block_dim = (BLOCK_SIZE, BLOCK_SIZE)

        # Clear the output buffer
        ctx.enqueue_memset(device_buffer, 0)

        print("Starting GPU computation...")
        print("Grid dimensions:", grid_dim[0], "x", grid_dim[1])
        print("Block dimensions:", block_dim[0], "x", block_dim[1])

        # Launch the kernel
        ctx.enqueue_function[mandelbrot_kernel](
            output, grid_dim=grid_dim, block_dim=block_dim
        )

        # Copy result back to host
        device_buffer.enqueue_copy_to(host_buffer)
        ctx.synchronize()

        print("GPU computation completed.")

        # Save image to file
        var filename = "mandelbrot.ppm"
        print("Saving output to:", filename)
        save_ppm(filename, host_buffer)
        print("Done!")
        print(
            "To view the image, you can use tools like 'display' from ImageMagick,"
            " GIMP, or convert to PNG."
        )
