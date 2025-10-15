# You are given an n x n 2D matrix representing an image, and you need to rotate the image by 90 degrees clockwise. 
# You are basically being asked to implement the functionality of numpy.rot90(matrix, k=-1) 
# (without actually using any helper functions or outside libraries).

# Example #1
# Input: matrix = [[5, 1], [6, 2]]
# Output: [[6,5],[2,1]]

# Example #2
# Input: matrix = [[3, 6, 9], [2, 5, 8], [1, 4, 7]]
# Output: [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

def rotate(matrix, clockwise=True):
    def rotate_matrix_func(matrix):
        temp_row = []
        temp_list = []
        for ind in range(0, len(matrix)):
            for item in matrix:
                temp_row.append(item[ind])
            if clockwise:
                temp_row = temp_row[::-1] 
            temp_list.append(temp_row)  
            temp_row = []
        return temp_list

    rotate_count = 0
    rotated_matrix = matrix[:] 
    
    while rotate_count < 1:
        rotated_matrix = rotate_matrix_func(rotated_matrix)
        rotate_count += 1
    
    return rotated_matrix 
