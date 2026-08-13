import std.time as time
from playground.async_module import task1, task2


def main():
    var start = time.perf_counter_ns()
    await task1()
    var t = task2()
    var elapsed = time.perf_counter_ns() - start
    print("Task1 Finished in ", elapsed / 1_000_000_000, "seconds")
    await t^
    elapsed = time.perf_counter_ns() - start
    print("Task2 Finished in ", elapsed / 1_000_000_000, "seconds")
