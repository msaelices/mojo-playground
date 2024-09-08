from csv import reader


fn main() raises:
    with open('data.csv', 'r') as file:
        csv_reader = reader(file, delimiter=',', quotechar='"', doublequote=True)
        i = 0
        for row in csv_reader:
            print(','.join(row))
