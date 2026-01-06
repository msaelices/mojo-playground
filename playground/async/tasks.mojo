import time


async fn task1():
    print("Task 1 started")
    time.sleep(2.0)
    print("Task 1 completed")


async fn task2():
    print("Task 2 started")
    time.sleep(1.0)
    print("Task 2 completed")


fn main():
    start = time.perf_counter_ns()
    await task1()
    t = task2()
    elapsed = time.perf_counter_ns() - start
    print("Task1 Finished in ", elapsed / 1_000_000_000, "seconds")
    await t^
    elapsed = time.perf_counter_ns() - start
    print("Task2 Finished in ", elapsed / 1_000_000_000, "seconds")


