import numpy as np


def random_full_write_full_read(filename) :
    # Generate 16 arrays of arrays of 64 linex with two 32 bits number 
    Array = np.random.randint(0, 2**32, (16, 64, 2), dtype=np.uint32) 
    with open(filename, "a") as file:
        file.write(f"write | 2004 | {1:08X}\n")
        file.write(f"read | 2004 | {1:08X}\n") # small register read test 
        for i in range(16) : 
            for j in range(64) : 
                for k in range(2) : 
                    address = i*64*2 + j*2 + k
                    file.write(f"write | {4*address :04X} | {Array[i][j][k]:08X}\n")
        file.write(f"write | 2004 | {0:08X}\n")
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

def random_full_write_and_inference(filename, num_test=1000) :
    # Generate 16 arrays of arrays of 64 linex with two 32 bits number 
    Array = np.random.randint(0, 2**6, (16, 64, 8), dtype=np.uint8) 
    Array[0][1][0] = 1
    Array[1][1][1] = 2
    Array[2][1][2] = 3
    Array[3][1][3] = 4
    with open(filename, "a") as file : 
        file.write(f"write | 2004 | {1:08X}\n")
        for i in range(16) : 
            for j in range(64) : 
                for k in range(2) : 
                    address = i*64*2 + j*2 + k
                    data = Array[i][j][k*4+3] << 24 | Array[i][j][k*4+2] << 16 | Array[i][j][k*4+1] << 8 | Array[i][j][k*4]
                    file.write(f"write | {4*address :04X} | {data:08X}\n")

        file.write(f"write | 2004 | {0:08X}\n")
        for i in range(16) : 
            for j in range(64) : 
                for k in range(2) : 
                    address = i*64*2 + j*2 + k
                    data = Array[i][j][k*4+3] << 24 | Array[i][j][k*4+2] << 16 | Array[i][j][k*4+1] << 8 | Array[i][j][k*4]
                    file.write(f"write | {4*address :04X} | {data:08X}\n")

        # log mode first
        file.write(f"write | 201C | {1:08X}\n")
        
        def inference( obs1, obs2, obs3, obs4, array) : 
            array = array.astype(np.uint16)
            file.write(f"write | 200C | {obs1:08X}\n")
            file.write(f"write | 2010 | {obs2:08X}\n")
            file.write(f"write | 2014 | {obs3:08X}\n")
            file.write(f"write | 2018 | {obs4:08X}\n")
            expected_data0 = array[0][obs1//8][obs1%8] + array[1][obs2//8][obs2%8] + array[2][obs3//8][obs3%8] + array[3][obs4//8][obs4%8]
            expected_data1 = array[4][obs1//8][obs1%8] + array[5][obs2//8][obs2%8] + array[6][obs3//8][obs3%8] + array[7][obs4//8][obs4%8]
            expected_data2 = array[8][obs1//8][obs1%8] + array[9][obs2//8][obs2%8] + array[10][obs3//8][obs3%8] + array[11][obs4//8][obs4%8]
            expected_data3 = array[12][obs1//8][obs1%8] + array[13][obs2//8][obs2%8] + array[14][obs3//8][obs3%8] + array[15][obs4//8][obs4%8]
            expected_array = np.array([expected_data0, expected_data1, expected_data2, expected_data3], dtype=np.uint32)
            expected_clip = np.clip(expected_array, 0, 255)
            
            expected_data = expected_clip[0] | expected_clip[1] << 8 | expected_clip[2] << 16 | expected_clip[3] <<24
            file.write(f"read | 2000 | {expected_data:08X}\n")

        inference(0, 0, 0, 0, Array)
        print(Array[0][0][0], Array[1][0][0], Array[2][0][0], Array[3][0][0])
        inference(0, 1, 2, 3, Array)
        print(Array[0][0][0], Array[1][0][1], Array[2][0][2], Array[3][0][3])
        inference(8, 9, 10, 11, Array)

        test_points = np.random.randint(0, 512, (num_test, 4))

        for i in range(num_test) :
            inference(test_points[i][0], test_points[i][1], test_points[i][2], test_points[i][3], Array)
            
        return Array

if __name__ == "__main__": 
    import os
    filename = "test_vector.txt"
    # create file
    if not os.path.isfile(filename):
        pass
    else: 
        open(filename, 'w').close() #erase

    np.random.seed(0)
    memory = random_full_write_full_read(filename)
    memory = random_full_write_and_inference(filename)
