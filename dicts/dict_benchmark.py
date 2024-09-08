from time import time as now


def get_wds(file) -> list[str]:
    input = open(file).read()
    return input.upper().split(" ")


def get_freqs(wds: list[str]) -> dict[str, int]:
    freqs = {}
    for wd in wds:
        if wd in freqs:
            freqs[wd] = freqs[wd] + 1
        else:
            freqs[wd] = 1
    return freqs


def main():
    wds: list[str] = get_wds('big_text.txt')
    n_wds = len(wds)

    out_path = "report_py.csv"
    with open(out_path, "w") as outfile:
        outfile.write(str("version,n_wds,n_keys,the,sec\n"))
        for _ in range(10):
            t0 = now()
            freqs = get_freqs(wds)
            t1 = now()
            duration = (t1-t0)
            the = freqs["THE"]
            n_keys = len(freqs.keys())
            out_str = str(n_wds) + "," + str(n_keys) + "," + str(the) + "," + str(duration) + "\n"
            outfile.write(out_str)
    print("DONE, saved to", out_path)


if __name__ == "__main__":
    main()
