from gpu import thread_idx, block_idx, barrier
from gpu.host import DeviceContext, DeviceBuffer, HostBuffer
from gpu.memory import AddressSpace
from layout import Layout, LayoutTensor
from memory import stack_allocation, UnsafePointer
from sys import size_of
import math
import random

# Maze dimensions and reinforcement learning parameters
comptime MAZE_SIZE = 8  # 8x8 maze
comptime NUM_STATES = MAZE_SIZE * MAZE_SIZE  # Total number of states (64)
comptime NUM_ACTIONS = 4  # 4 actions (up, right, down, left)
comptime GAMMA = 0.9  # Discount factor
comptime EPISODES = 1000  # Number of episodes to simulate
comptime MAX_STEPS = 100  # Maximum steps per episode
comptime EPSILON = 0.1  # Exploration rate
comptime NUM_THREADS = 128  # Number of threads per block
comptime NUM_BLOCKS = 16  # Number of blocks

# Layout definitions for our GPU tensors
comptime q_table_layout = Layout.row_major(NUM_STATES, NUM_ACTIONS)
comptime QTable = LayoutTensor[DType.float32, q_table_layout, MutAnyOrigin]
comptime Maze = LayoutTensor[
    DType.int32, Layout.row_major(NUM_STATES), MutAnyOrigin
]
comptime ValidActions = LayoutTensor[
    DType.int32, Layout.row_major(NUM_STATES, NUM_ACTIONS), MutAnyOrigin
]
comptime EpisodeSeeds = LayoutTensor[
    DType.int32, Layout.row_major(NUM_BLOCKS * NUM_THREADS), MutAnyOrigin
]

# Maze definition - 0 is empty, 1 is wall, 2 is goal
comptime UP = 0
comptime RIGHT = 1
comptime DOWN = 2
comptime LEFT = 3


fn initialize_maze(maze_buffer: HostBuffer[DType.int32]):
    """Initialize an 8x8 maze with walls, start, and goal positions."""
    var maze_ptr = maze_buffer.unsafe_ptr()

    # First, make all cells empty (0)
    for i in range(NUM_STATES):
        maze_ptr[i] = 0

    # Add walls (1)
    # Outer walls
    for i in range(MAZE_SIZE):
        # Top wall
        maze_ptr[i] = 1
        # Bottom wall
        maze_ptr[(MAZE_SIZE - 1) * MAZE_SIZE + i] = 1
        # Left wall
        maze_ptr[i * MAZE_SIZE] = 1
        # Right wall
        maze_ptr[i * MAZE_SIZE + MAZE_SIZE - 1] = 1

    # Some interior walls for complexity
    # Horizontal walls
    for i in range(2, 6):
        maze_ptr[2 * MAZE_SIZE + i] = 1  # Third row
        maze_ptr[5 * MAZE_SIZE + i] = 1  # Sixth row

    # Vertical walls
    for i in range(1, 3):
        maze_ptr[i * MAZE_SIZE + 3] = 1  # Fourth column

    for i in range(4, 7):
        maze_ptr[i * MAZE_SIZE + 5] = 1  # Sixth column

    # Set the goal position (2) - bottom right corner inner cell
    maze_ptr[6 * MAZE_SIZE + 6] = 2


fn get_valid_actions_kernel(
    maze: Maze,
    valid_actions: ValidActions,
):
    """Compute valid actions for each state in the maze.

    Each thread handles one state in the maze.
    1 in valid_actions means the action is valid, 0 means it's invalid.
    """
    var state_idx = block_idx.x * NUM_THREADS + thread_idx.x

    if state_idx >= NUM_STATES:
        return

    # Get the row and column for this state
    var row = state_idx // MAZE_SIZE
    var col = state_idx % MAZE_SIZE

    # Check each direction
    # UP
    if row > 0:
        var next_state = (row - 1) * MAZE_SIZE + col
        valid_actions[state_idx, UP] = (
            1 - maze[next_state][0]
        )  # Valid if not a wall (0 or 2)
    else:
        valid_actions[state_idx, UP] = 0

    # RIGHT
    if col < MAZE_SIZE - 1:
        var next_state = row * MAZE_SIZE + (col + 1)
        valid_actions[state_idx, RIGHT] = 1 - maze[next_state][0]
    else:
        valid_actions[state_idx, RIGHT] = 0

    # DOWN
    if row < MAZE_SIZE - 1:
        var next_state = (row + 1) * MAZE_SIZE + col
        valid_actions[state_idx, DOWN] = 1 - maze[next_state][0]
    else:
        valid_actions[state_idx, DOWN] = 0

    # LEFT
    if col > 0:
        var next_state = row * MAZE_SIZE + (col - 1)
        valid_actions[state_idx, LEFT] = 1 - maze[next_state][0]
    else:
        valid_actions[state_idx, LEFT] = 0


fn monte_carlo_episode_kernel(
    maze: Maze,
    valid_actions: ValidActions,
    q_table: QTable,
    episode_seeds: EpisodeSeeds,
):
    """Run Monte Carlo episodes to update the Q-table.

    Each thread simulates one episode starting from a random position.
    """
    var thread_id = block_idx.x * NUM_THREADS + thread_idx.x

    if thread_id >= NUM_BLOCKS * NUM_THREADS:
        return

    # Use different seeds for each thread for randomness
    var seed = episode_seeds[thread_id][0]
    var rng = thread_id + seed * 17  # Simple pseudo-random number generator

    # Shared memory for storing the episode trajectory
    var states_memory = stack_allocation[
        MAX_STEPS * size_of[Int32](), Int32, address_space = AddressSpace.SHARED
    ]()

    var actions_memory = stack_allocation[
        MAX_STEPS * size_of[Int32](), Int32, address_space = AddressSpace.SHARED
    ]()

    var rewards_memory = stack_allocation[
        MAX_STEPS * size_of[Float32](),
        Float32,
        address_space = AddressSpace.SHARED,
    ]()

    # Find a valid starting state (not a wall or the goal)
    var steps = 0
    var is_done = False

    # Start at position (1,1) - just inside the walls
    state = MAZE_SIZE + 1

    # Epsilon-greedy policy for action selection
    while not is_done and steps < MAX_STEPS:
        # Get available actions
        var valid_count = 0
        var valid_action_indices = SIMD[DType.int32, 4](0, 0, 0, 0)

        for action in range(NUM_ACTIONS):
            # Use integers for indexing
            var state_idx = Int(state)
            var action_idx = Int(action)
            if valid_actions[state_idx, action_idx] == 1:
                valid_action_indices[valid_count] = action
                valid_count += 1

        # No valid actions
        if valid_count == 0:
            break

        # Epsilon-greedy action selection
        var action: Int32

        # Generate a random value for exploration
        rng = (
            rng * 1664525 + 1013904223
        ) % 2147483647  # Simple LCG for randomness
        var random_value = rng % 100

        if Int(random_value) < Int(EPSILON * 100):  # Explore
            var random_idx = Int(rng % valid_count)
            action = Int(valid_action_indices[random_idx])
        else:  # Exploit - choose the best action
            var best_action = Int(valid_action_indices[0])
            var state_idx = Int(state)
            var best_value = q_table[state_idx, best_action]

            for i in range(1, valid_count):
                var current_action = Int(valid_action_indices[i])
                var current_value = q_table[state_idx, current_action]

                if current_value > best_value:
                    best_action = current_action
                    best_value = current_value

            action = best_action

        # Get next state based on action
        var next_state = state

        if action == UP and state // MAZE_SIZE > 0:
            next_state = state - MAZE_SIZE
        elif action == RIGHT and state % MAZE_SIZE < MAZE_SIZE - 1:
            next_state = state + 1
        elif action == DOWN and state // MAZE_SIZE < MAZE_SIZE - 1:
            next_state = state + MAZE_SIZE
        elif action == LEFT and state % MAZE_SIZE > 0:
            next_state = state - 1

        # Default reward is -1 (penalty for each step)
        var reward = Float32(-1.0)

        # Check if goal reached
        if maze[Int(next_state)] == 2:  # Goal
            reward = Float32(100.0)  # High reward for reaching the goal
            is_done = True

        # Store step in trajectory
        states_memory[steps] = state
        actions_memory[steps] = action
        rewards_memory[steps] = reward

        # Move to the next state
        state = next_state
        steps += 1

    # Monte Carlo update - working backwards from the end of the episode
    # First compute returns (discounted rewards)
    if steps > 0:
        # Synchronize threads for shared memory operations
        barrier()

        var returns = Float32(0.0)

        for t in range(steps - 1, -1, -1):  # Reverse order
            returns = rewards_memory[t] + GAMMA * returns

            var curr_state = states_memory[t]
            var curr_action = actions_memory[t]

            # Update Q-table - note this is not thread-safe but acceptable for RL
            var state_idx = Int(curr_state)
            var action_idx = Int(curr_action)
            var current_q = q_table[state_idx, action_idx]
            var learning_rate = Float32(
                1.0 / (1.0 + 0.01 * Float32(thread_id % 10))
            )  # Vary learning rate
            q_table[state_idx, action_idx] = current_q + learning_rate * (
                returns - current_q
            )

        # Ensure all threads finished their updates before exiting
        barrier()


fn find_optimal_path_kernel(
    maze: Maze,
    valid_actions: ValidActions,
    q_table: QTable,
    path_length: LayoutTensor[
        DType.int32, Layout.row_major(1), MutAnyOrigin
    ],
    optimal_path: LayoutTensor[
        DType.int32, Layout.row_major(MAX_STEPS), MutAnyOrigin
    ],
):
    """Find the optimal path based on the learned Q-table.

    Single-threaded kernel run once at the end.
    """
    # Only the first thread does the work
    if block_idx.x > 0 or thread_idx.x > 0:
        return

    # Start from the starting position (1,1)
    var state = MAZE_SIZE + 1
    var steps = 0
    var is_done = False

    while not is_done and steps < MAX_STEPS:
        # Store current state in path
        optimal_path[steps] = state

        # Find best action for current state
        var best_action = -1
        var best_value = Float32(-1000000.0)

        for action in range(NUM_ACTIONS):
            # Use integers for indexing
            var state_idx = Int(state)
            var action_idx = Int(action)
            if valid_actions[state_idx, action_idx] == 1:
                var action_value = q_table[state_idx, action_idx]
                # Convert SIMD to scalar value for comparison
                var scalar_value = action_value[0]
                if scalar_value > best_value:
                    best_value = scalar_value
                    best_action = action

        if best_action == -1:
            break  # No valid actions

        # Get next state
        var next_state = state

        if best_action == UP and state // MAZE_SIZE > 0:
            next_state = state - MAZE_SIZE
        elif best_action == RIGHT and state % MAZE_SIZE < MAZE_SIZE - 1:
            next_state = state + 1
        elif best_action == DOWN and state // MAZE_SIZE < MAZE_SIZE - 1:
            next_state = state + MAZE_SIZE
        elif best_action == LEFT and state % MAZE_SIZE > 0:
            next_state = state - 1

        # Move to next state
        state = next_state
        steps += 1

        # Check if goal reached
        if maze[state] == 2:
            optimal_path[steps] = state  # Add goal to path
            steps += 1
            is_done = True

    path_length[0] = steps


fn demo_rl_maze() raises:
    print("Reinforcement Learning Maze Solver (8x8)")
    print("Using Monte Carlo method with", EPISODES, "episodes")

    with DeviceContext() as ctx:
        # Allocate buffers for maze and Q-table
        var maze_buffer = ctx.enqueue_create_host_buffer[DType.int32](
            NUM_STATES
        )
        var valid_actions_buffer = ctx.enqueue_create_host_buffer[DType.int32](
            NUM_STATES * NUM_ACTIONS
        )
        var q_table_buffer = ctx.enqueue_create_host_buffer[DType.float32](
            NUM_STATES * NUM_ACTIONS
        )
        var episode_seeds_buffer = ctx.enqueue_create_host_buffer[DType.int32](
            NUM_BLOCKS * NUM_THREADS
        )

        # Initialize maze
        initialize_maze(maze_buffer)

        # Initialize Q-table to zeros
        var q_table_ptr = q_table_buffer.unsafe_ptr()
        for i in range(NUM_STATES * NUM_ACTIONS):
            q_table_ptr[i] = 0.0

        # Initialize random seeds for episodes
        var seeds_ptr = episode_seeds_buffer.unsafe_ptr()
        for i in range(NUM_BLOCKS * NUM_THREADS):
            seeds_ptr[i] = Int32(i * 17 + 42)

        # Create device buffers
        var maze_dev = ctx.enqueue_create_buffer[DType.int32](NUM_STATES)
        var valid_actions_dev = ctx.enqueue_create_buffer[DType.int32](
            NUM_STATES * NUM_ACTIONS
        )
        var q_table_dev = ctx.enqueue_create_buffer[DType.float32](
            NUM_STATES * NUM_ACTIONS
        )
        var episode_seeds_dev = ctx.enqueue_create_buffer[DType.int32](
            NUM_BLOCKS * NUM_THREADS
        )

        # Copy data to device
        maze_buffer.enqueue_copy_to(maze_dev)
        q_table_buffer.enqueue_copy_to(q_table_dev)
        episode_seeds_buffer.enqueue_copy_to(episode_seeds_dev)

        # Create tensor views
        var maze = Maze(maze_dev)
        var valid_actions = ValidActions(valid_actions_dev)
        var q_table = QTable(q_table_dev)
        var episode_seeds = EpisodeSeeds(episode_seeds_dev)

        # Precompute valid actions for all states
        ctx.enqueue_function_checked[get_valid_actions_kernel, get_valid_actions_kernel](
            maze, valid_actions, grid_dim=1, block_dim=NUM_STATES
        )

        # Print maze for visualization
        ctx.synchronize()
        maze_dev.enqueue_copy_to(maze_buffer)
        ctx.synchronize()

        print("Maze layout:")
        for i in range(MAZE_SIZE):
            for j in range(MAZE_SIZE):
                var cell = maze_buffer.unsafe_ptr()[i * MAZE_SIZE + j]
                if cell == 0:
                    print("⬜️", end="")  # Empty space
                elif cell == 1:
                    print("⬛️", end="")  # Wall
                elif cell == 2:
                    print("🏁", end="")  # Goal
            print("")  # End the line

        print("\nTraining RL agent...")

        # Monte Carlo training over multiple episodes
        for episode in range(1, EPISODES + 1, NUM_THREADS * NUM_BLOCKS):
            # Update seeds for more randomness
            var seeds_ptr = episode_seeds_buffer.unsafe_ptr()
            for i in range(NUM_BLOCKS * NUM_THREADS):
                seeds_ptr[i] = Int32(episode + i)

            episode_seeds_buffer.enqueue_copy_to(episode_seeds_dev)

            # Run Monte Carlo episodes in parallel
            ctx.enqueue_function_checked[monte_carlo_episode_kernel, monte_carlo_episode_kernel](
                maze,
                valid_actions,
                q_table,
                episode_seeds,
                grid_dim=NUM_BLOCKS,
                block_dim=NUM_THREADS,
            )

            # Print progress
            if episode % 100 == 0:
                print("  Episode", episode, "of", EPISODES)

        # Copy back Q-table
        q_table_dev.enqueue_copy_to(q_table_buffer)

        # Find optimal path
        var path_length_buffer = ctx.enqueue_create_host_buffer[DType.int32](1)
        var optimal_path_buffer = ctx.enqueue_create_host_buffer[DType.int32](
            MAX_STEPS
        )

        var path_length_dev = ctx.enqueue_create_buffer[DType.int32](1)
        var optimal_path_dev = ctx.enqueue_create_buffer[DType.int32](MAX_STEPS)

        ctx.enqueue_memset(path_length_dev, 0)
        ctx.enqueue_memset(optimal_path_dev, 0)

        var path_length = LayoutTensor[DType.int32, Layout.row_major(1)](
            path_length_dev
        )
        var optimal_path = LayoutTensor[
            DType.int32, Layout.row_major(MAX_STEPS)
        ](optimal_path_dev)

        ctx.enqueue_function_checked[find_optimal_path_kernel, find_optimal_path_kernel](
            maze,
            valid_actions,
            q_table,
            path_length,
            optimal_path,
            grid_dim=1,
            block_dim=1,
        )

        # Copy results back
        path_length_dev.enqueue_copy_to(path_length_buffer)
        optimal_path_dev.enqueue_copy_to(optimal_path_buffer)
        ctx.synchronize()

        # Get path length
        var path_len = path_length_buffer.unsafe_ptr()[0]

        # Display the optimal path
        print("\nOptimal path found! Length:", path_len)

        # Create a maze with path - use a List instead of UnsafePointer.alloc
        var maze_with_path = List[Int32](capacity=NUM_STATES)
        for _ in range(NUM_STATES):
            maze_with_path.append(0)

        # Copy maze
        for i in range(NUM_STATES):
            maze_with_path[i] = maze_buffer.unsafe_ptr()[i]

        # Mark path
        for i in range(path_len):
            var state = optimal_path_buffer.unsafe_ptr()[i]
            if (
                maze_with_path[state] == 0
            ):  # Only mark empty spaces, not start/goal
                maze_with_path[state] = 3  # Path

        # Set start
        maze_with_path[MAZE_SIZE + 1] = 4

        print("\nPath visualization:")
        for i in range(MAZE_SIZE):
            for j in range(MAZE_SIZE):
                var cell = maze_with_path[i * MAZE_SIZE + j]
                if cell == 0:
                    print("⬜️", end="")  # Empty space
                elif cell == 1:
                    print("⬛️", end="")  # Wall
                elif cell == 2:
                    print("🏁", end="")  # Goal
                elif cell == 3:
                    print("🟢", end="")  # Path
                elif cell == 4:
                    print("🟠", end="")  # Start
            print("")  # End the line

        print("\nRL Maze Solver completed successfully!")
