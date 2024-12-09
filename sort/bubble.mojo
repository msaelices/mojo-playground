from time import perf_counter_ns as now

    
fn bubble_sort(mut arr: List[Int]):
    for i in range(len(arr)):
        for j in range(len(arr) - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]


def main():
    l = List[Int]()
    for i in range(1000, 0, step=-1):
        l.append(i)

    start = now()
    bubble_sort(l)
    end = now()
    print((end - start) / 1000_000_000)
    # print(str(l))
