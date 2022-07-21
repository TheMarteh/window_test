import os
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../../../assets/LowpolyHouse.obj")

file1 = open('C:\\Users\\Steal\\Downloads\\LowPolyHouse2.obj',
           'r')

file2 = open(filename, 'x')
for line in file1.readlines():
    x = line.split(" ")
    if (x[0] == "f" or x[0] == "v"):
        print(line);
        file2.write(line)

file1.close()
file2.close()