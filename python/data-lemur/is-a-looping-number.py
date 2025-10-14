# Given an integer n, check if it is a looping number. A looping number has the following properties:

# It is repeatedly replaced by the sum of the squares of its digits.
# This process continues until:
# The number becomes 1, in which case it is not a looping number.
# The number starts repeating in a cycle that does not include 1, making it a looping number.
# Return True if n is a looping number, otherwise return False.

# Example #1
# Input: n = 4
# Output: True
# Explanation:
# 4^2 = 16
# 1^2 + 6^2 = 1 + 36 = 37
# 3^2 + 7^2 = 9 + 49 = 58
# 5^2 + 8^2 = 25 + 64 = 89
# 8^2 + 9^2 = 64 + 81 = 145
# 1^2 + 4^2 + 5^2 = 1 + 16 + 25 = 42
# 4^2 + 2^2 = 16 + 4 = 20
# 2^2 + 0^2 = 4 + 0 = 4
# Since the number loops back to 4, it is a looping number.

# Example #2
# Input: n = 19
# Output: False
# Explanation:
# 1^2 + 9^2 = 1 + 81 = 82
# 8^2 + 2^2 = 64 + 4 = 68
# 6^2 + 8^2 = 36 + 64 = 100
# 1^2 + 0^2 + 0^2 = 1 + 0 + 0 = 1
# Since the number reaches 1, it is not a looping number.

def is_looping(n):
    if n == 1:
        return False 

    def is_looping_inner(num, seen=None):
        if seen is None:
            seen = set()
        
        n_item_list = list(str(num))
        n_item_list = [int(x) for x in n_item_list]
        n_item_square_sum = sum([x**2 for x in n_item_list])
        
        if n_item_square_sum in seen:
            return True
        elif n_item_square_sum == 1:
            return False
        else:
            seen.add(n_item_square_sum)
            return is_looping_inner(n_item_square_sum, seen)
    
    return is_looping_inner(num=n)
