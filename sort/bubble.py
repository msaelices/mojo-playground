from time import time as now


def bubble_sort(arr):
    for i in range(len(arr)):
        for j in range(len(arr) - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]


if __name__ == '__main__':
    l = list(range(1000, 0, -1))
    start = now()
    bubble_sort(l)
    end = now()
    print(end - start)
    # print(l)
