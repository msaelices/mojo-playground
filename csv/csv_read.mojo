from csv import reader
from time import now

fn main() raises:

    with open('data.csv', 'r') as file:
        csv_reader = reader(file, delimiter=',', quotechar='"', doublequote=True)
        i = 0
        t_start = now()
        for row in csv_reader:
            i += 1
            # print(','.join(row))
        t_end = now()
        duration = (t_end - t_start) / 1_000_000_000
        print('Number of rows: ', i, 'Duration:', duration, 'seconds')
