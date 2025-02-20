from time import time as now


def main():
    l = []
    for i in range(1_000_000):
        l.append(str(i))
    start = now()
    s = ",".join(l)
    end = now()
    print("Len: ", len(s), "Time: ", (end - start), "seconds")


if __name__ == "__main__":
    main()
