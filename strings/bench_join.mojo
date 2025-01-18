from time import perf_counter_ns as now

fn main():
    l = List[String](capacity=100_000)
    for i in range(100_000):
        l.append(String(i))
    start = now()
    s = String(",").join(l)
    end = now()
    print('Len: ', len(s), 'Time: ', (end - start) / 1_000_000_000, 'seconds')
