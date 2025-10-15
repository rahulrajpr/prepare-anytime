# Given two n x n binary matrices mat and target, return true if it is possible to make mat equal to target 
# by rotating mat in 90-degree increments, or false otherwise.

# Example #1
# Input: mat = [[1,0,1],[0,0,1],[1,0,1]], target = [[1,0,1],[1,0,0],[1,0,1]]
# Output: true
# Explanation: We can rotate mat 180 degrees to go from the input mat to the target

# Example #2
# Input: mat = [[0, 1],[1, 0]], target = [[1, 1],[0, 0]]
# Output: false
# Explanation: It is impossible to make mat equal to target by rotating mat.

def find_rotation(mat, target):
    def rotate_matrix_func(matrix):
        temp_row = []
        temp_list = []
        for ind in range(0, len(matrix)):
            for item in matrix:
                temp_row.append(item[ind]) # Reverse to make it clockwise
            temp_row = temp_row[::-1]
            temp_list.append(temp_row)  
            temp_row = []
        return temp_list

    rotate_count = 0
    rotated_matrix = mat[:]
    
    # Check all 4 rotations (0°, 90°, 180°, 270°)
    while rotate_count < 4:
        if rotated_matrix == target:
            return True
        rotated_matrix = rotate_matrix_func(rotated_matrix)
        rotate_count += 1
    
    return False
