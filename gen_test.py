import numpy as np


def random_full_write_full_read(filename) :
    # Generate 16 arrays of arrays of 64 linex with two 32 bits number 
    Array = np.random.randint(0, 2**32, (16, 64, 2), dtype=np.uint32) 
    with open(filename, "a") as file:
        file.write(f"write | 2000 | {0:08X}\n")
        for i in range(16) : 
            for j in range(64) : 
                for k in range(2) : 
                    address = i*64*2 + j*2 + k
                    file.write(f"write | {4*address :04X} | {Array[i][j][k]:08X}\n")
        file.write(f"write | 2000 | {1:08X}\n")
        for i in range(16) : 
            for j in range(64) : 
                for k in range(2) : 
                    address = i*64*2 + j*2 + k
                    file.write(f"write | {4*address :04X} | {Array[i][j][k]:08X}\n")

        for i in range(16) : 
            for j in range(64) : 
                for k in range(2) : 
                    address = i*64*2 + j*2 + k
                    file.write(f"read | {4*address :04X} | {Array[i][j][k]:08X}\n")
    return Array

if __name__ == "__main__": 
    import os
    filename = "test.txt"
    # create file
    if not os.path.isfile(filename):
        pass
    else: 
        open(filename, 'w').close() #erase

    np.random.seed(0)
    memory = random_full_write_full_read(filename)
