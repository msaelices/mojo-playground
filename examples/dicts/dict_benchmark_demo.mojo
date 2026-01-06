from time import perf_counter_ns as now
from collections import Dict

from playground.dicts import get_wds, get_freqs


fn main() raises:
    var wds: List[String] = get_wds()
    var n_wds = len(wds)

    var out_path = "report.csv"
    with open(out_path, "w") as outfile:
        outfile.write("version,n_wds,n_keys,the,sec\n")
        for _ in range(10):
            var t0 = now()
            var freqs = get_freqs(wds)
            var t1 = now()
            var duration = (t1 - t0) / 1_000_000_000
            var the: UInt64
            the = freqs["THE"]
            var n_keys = len(freqs.keys())
            var out_str = String(n_wds, n_keys, the, duration, "\n", sep=",")
            outfile.write(out_str)
    print("DONE, saved to", out_path)
