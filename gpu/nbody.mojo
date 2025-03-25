from gpu import thread_idx, block_idx
from gpu.host import DeviceContext, DeviceBuffer
from layout import Layout, LayoutTensor
import math

# Simulation parameters
alias NUM_PARTICLES = 512  # Number of particles in the simulation
alias BLOCK_SIZE = 64      # Threads per block
alias DT = 0.01            # Time step
alias SOFTENING = 0.01     # Softening factor to avoid division by zero
alias NUM_ITERATIONS = 10  # Number of simulation steps to run

# Define layouts for particle data
alias vec_layout = Layout.row_major(NUM_PARTICLES)
alias VecData = LayoutTensor[DType.float32, vec_layout, StaticConstantOrigin]


fn update_particles_kernel(
    pos_x: VecData, pos_y: VecData, pos_z: VecData,
    vel_x: VecData, vel_y: VecData, vel_z: VecData
):
    """Compute gravitational forces and update particle positions.
    
    Each thread computes the forces and position for one particle.
    This is a simplified N-body simulation where we've combined the force 
    computation and integration into a single kernel for simplicity.
    """
    # Get the particle index this thread is responsible for
    var i = block_idx.x * BLOCK_SIZE + thread_idx.x
    
    # Check boundaries
    if i >= NUM_PARTICLES:
        return
    
    # Get current particle position
    var pos_i_x = pos_x[i][0]
    var pos_i_y = pos_y[i][0]
    var pos_i_z = pos_z[i][0]
    
    # Get current particle velocity
    var vel_i_x = vel_x[i][0]
    var vel_i_y = vel_y[i][0]
    var vel_i_z = vel_z[i][0]
    
    # Compute gravitational forces
    var acc_x: Float32 = 0.0
    var acc_y: Float32 = 0.0
    var acc_z: Float32 = 0.0
    
    # Compute forces with all other particles
    for j in range(NUM_PARTICLES):
        if i == j:  # Skip self-interaction
            continue
        
        # Compute distance vector
        var dx = pos_x[j][0] - pos_i_x
        var dy = pos_y[j][0] - pos_i_y
        var dz = pos_z[j][0] - pos_i_z
        
        # Compute distance squared with softening to avoid division by zero
        var distance_squared = dx*dx + dy*dy + dz*dz + SOFTENING*SOFTENING
        
        # Compute force strength: G*m_j/r^3 (G and m_j are 1.0 in our simplified simulation)
        var force = 1.0 / (math.sqrt(distance_squared) * distance_squared)
        
        # Accumulate accelerations (F=ma, but m=1 in our simulation)
        acc_x += Float32(force * dx)
        acc_y += Float32(force * dy)
        acc_z += Float32(force * dz)
    
    # Update velocity with computed acceleration
    vel_i_x += acc_x * DT
    vel_i_y += acc_y * DT
    vel_i_z += acc_z * DT
    
    # Update position with new velocity
    pos_i_x += vel_i_x * DT
    pos_i_y += vel_i_y * DT
    pos_i_z += vel_i_z * DT
    
    # Store updated positions and velocities
    pos_x[i] = pos_i_x
    pos_y[i] = pos_i_y
    pos_z[i] = pos_i_z
    vel_x[i] = vel_i_x
    vel_y[i] = vel_i_y
    vel_z[i] = vel_i_z


fn initialize_uniform_sphere(
    buffer_pos_x: DeviceBuffer[DType.float32],
    buffer_pos_y: DeviceBuffer[DType.float32],
    buffer_pos_z: DeviceBuffer[DType.float32],
    buffer_vel_x: DeviceBuffer[DType.float32],
    buffer_vel_y: DeviceBuffer[DType.float32],
    buffer_vel_z: DeviceBuffer[DType.float32]
):
    """Initialize particles in a uniform sphere with some initial velocity.
    
    We use a deterministic pattern rather than random values to ensure reproducibility.
    """
    var pos_x_ptr = buffer_pos_x.unsafe_ptr()
    var pos_y_ptr = buffer_pos_y.unsafe_ptr()
    var pos_z_ptr = buffer_pos_z.unsafe_ptr()
    var vel_x_ptr = buffer_vel_x.unsafe_ptr()
    var vel_y_ptr = buffer_vel_y.unsafe_ptr()
    var vel_z_ptr = buffer_vel_z.unsafe_ptr()
    
    for i in range(NUM_PARTICLES):
        # Initialize position in a sphere with radius 1
        var r = 1.0
        # Longitude in spherical coordinates (0 to 2*pi)
        var theta = 2.0 * math.pi * i / NUM_PARTICLES
        # Latitude in spherical coordinates (0 to pi)
        var phi = math.pi * (i % 100) / 100.0
        
        # Convert spherical coordinates to Cartesian coordinates
        var pos_x = r * math.sin(phi) * math.cos(theta)
        var pos_y = r * math.sin(phi) * math.sin(theta)
        var pos_z = r * math.cos(phi)
        
        # Initialize with small deterministic velocities
        var vel_x = 0.1 * math.sin(theta * 2.5)
        var vel_y = 0.1 * math.cos(phi * 3.0)
        var vel_z = 0.01 * (i % 10)
        
        # Store in buffers
        pos_x_ptr.offset(i).store(Float32(pos_x))
        pos_y_ptr.offset(i).store(Float32(pos_y))
        pos_z_ptr.offset(i).store(Float32(pos_z))
        vel_x_ptr.offset(i).store(Float32(vel_x))
        vel_y_ptr.offset(i).store(Float32(vel_y))
        vel_z_ptr.offset(i).store(Float32(vel_z))


fn get_system_bounds(
    buffer_pos_x: DeviceBuffer[DType.float32],
    buffer_pos_y: DeviceBuffer[DType.float32],
    buffer_pos_z: DeviceBuffer[DType.float32]
):
    """Calculate the min/max bounds of the particle system."""
    var pos_x_ptr = buffer_pos_x.unsafe_ptr()
    var pos_y_ptr = buffer_pos_y.unsafe_ptr()
    var pos_z_ptr = buffer_pos_z.unsafe_ptr()
    
    var min_x = pos_x_ptr.load()
    var max_x = pos_x_ptr.load()
    var min_y = pos_y_ptr.load()
    var max_y = pos_y_ptr.load()
    var min_z = pos_z_ptr.load()
    var max_z = pos_z_ptr.load()
    
    for i in range(1, NUM_PARTICLES):
        var x = pos_x_ptr.offset(i).load()
        var y = pos_y_ptr.offset(i).load()
        var z = pos_z_ptr.offset(i).load()
        
        if x < min_x:
            min_x = x
        if x > max_x:
            max_x = x
        if y < min_y:
            min_y = y
        if y > max_y:
            max_y = y
        if z < min_z:
            min_z = z
        if z > max_z:
            max_z = z
    
    print("Particle distribution:")
    print("  X range:", min_x, "to", max_x)
    print("  Y range:", min_y, "to", max_y)
    print("  Z range:", min_z, "to", max_z)


fn main() raises:
    print("N-body simulation with", NUM_PARTICLES, "particles")
    print("Time step:", DT)
    print("Number of iterations:", NUM_ITERATIONS)
    
    with DeviceContext() as ctx:
        # Allocate host buffers for particle data
        var pos_x_host = ctx.enqueue_create_host_buffer[DType.float32](NUM_PARTICLES)
        var pos_y_host = ctx.enqueue_create_host_buffer[DType.float32](NUM_PARTICLES)
        var pos_z_host = ctx.enqueue_create_host_buffer[DType.float32](NUM_PARTICLES)
        var vel_x_host = ctx.enqueue_create_host_buffer[DType.float32](NUM_PARTICLES)
        var vel_y_host = ctx.enqueue_create_host_buffer[DType.float32](NUM_PARTICLES)
        var vel_z_host = ctx.enqueue_create_host_buffer[DType.float32](NUM_PARTICLES)
        
        # Initialize particle positions and velocities
        ctx.synchronize()
        initialize_uniform_sphere(
            pos_x_host, pos_y_host, pos_z_host,
            vel_x_host, vel_y_host, vel_z_host
        )
        
        # Allocate device buffers for particle data
        var pos_x_dev = ctx.enqueue_create_buffer[DType.float32](NUM_PARTICLES)
        var pos_y_dev = ctx.enqueue_create_buffer[DType.float32](NUM_PARTICLES)
        var pos_z_dev = ctx.enqueue_create_buffer[DType.float32](NUM_PARTICLES)
        var vel_x_dev = ctx.enqueue_create_buffer[DType.float32](NUM_PARTICLES)
        var vel_y_dev = ctx.enqueue_create_buffer[DType.float32](NUM_PARTICLES)
        var vel_z_dev = ctx.enqueue_create_buffer[DType.float32](NUM_PARTICLES)
        
        # Create tensor views of the device buffers
        var pos_x = LayoutTensor[DType.float32, vec_layout](pos_x_dev)
        var pos_y = LayoutTensor[DType.float32, vec_layout](pos_y_dev)
        var pos_z = LayoutTensor[DType.float32, vec_layout](pos_z_dev)
        var vel_x = LayoutTensor[DType.float32, vec_layout](vel_x_dev)
        var vel_y = LayoutTensor[DType.float32, vec_layout](vel_y_dev)
        var vel_z = LayoutTensor[DType.float32, vec_layout](vel_z_dev)
        
        # Transfer initial data to device
        pos_x_host.enqueue_copy_to(pos_x_dev)
        pos_y_host.enqueue_copy_to(pos_y_dev)
        pos_z_host.enqueue_copy_to(pos_z_dev)
        vel_x_host.enqueue_copy_to(vel_x_dev)
        vel_y_host.enqueue_copy_to(vel_y_dev)
        vel_z_host.enqueue_copy_to(vel_z_dev)
        
        # Calculate initial bounds
        ctx.synchronize()
        print("Initial particle distribution:")
        get_system_bounds(pos_x_host, pos_y_host, pos_z_host)
        
        # Calculate grid dimensions for the kernels
        var grid_dim = (NUM_PARTICLES + BLOCK_SIZE - 1) // BLOCK_SIZE
        var block_dim = BLOCK_SIZE
        
        print("Starting simulation...")
        print("Grid dimension:", grid_dim)
        print("Block dimension:", block_dim)
        
        # Run simulation for NUM_ITERATIONS steps
        for step in range(NUM_ITERATIONS):
            # Compute forces and update particles
            ctx.enqueue_function[update_particles_kernel](
                pos_x, pos_y, pos_z,
                vel_x, vel_y, vel_z,
                grid_dim=grid_dim,
                block_dim=block_dim
            )
            
            # Print progress every 2 steps
            if step % 2 == 0:
                print("Step", step, "complete")
        
        print("Simulation complete")
        
        # Copy final state back to host
        pos_x_dev.enqueue_copy_to(pos_x_host)
        pos_y_dev.enqueue_copy_to(pos_y_host)
        pos_z_dev.enqueue_copy_to(pos_z_host)
        vel_x_dev.enqueue_copy_to(vel_x_host)
        vel_y_dev.enqueue_copy_to(vel_y_host)
        vel_z_dev.enqueue_copy_to(vel_z_host)
        ctx.synchronize()
        
        # Final distribution
        print("Final particle distribution:")
        get_system_bounds(pos_x_host, pos_y_host, pos_z_host)
        
        print("Simulation completed successfully!")
