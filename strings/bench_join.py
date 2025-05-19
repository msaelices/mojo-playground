from time import time as now


def main():
    l = []
    for i in range(1_000):
        l.append(str(i))
    start = now()
    for _ in range(10_000):
        s = ",".join(l)
    end = now()
    print("Len: ", len(s), "Time: ", (end - start), "seconds")


if __name__ == "__main__":
    main()
