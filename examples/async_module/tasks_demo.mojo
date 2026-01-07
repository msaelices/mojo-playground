import time
from playground.async_module import task1, task2


fn main():
    start = time.perf_counter_ns()
    await task1()
    t = task2()
    elapsed = time.perf_counter_ns() - start
    print("Task1 Finished in ", elapsed / 1_000_000_000, "seconds")
    await t^
    elapsed = time.perf_counter_ns() - start
    print("Task2 Finished in ", elapsed / 1_000_000_000, "seconds")
