## find the triangular sum of a list
## Input: nums = [1, 3, 5, 7]

# Iteration #1: Form newNums = [(1 + 3) % 10, (3 + 5) % 10, (5 + 7) % 10] = [4, 8, 2].
# Iteration #2: Form newNums = [(4 + 8) % 10, (8 + 2) % 10] = [2, 0].
# Iteration #3: Form newNums = [(2 + 0) % 10] = [2].
# The triangular sum of nums is 2.

def triangular_sum(ls):  
  if len(ls) == 1:
    return ls[0]
  
  chunk_size = 2
  result = []
  for i in range(0,len(ls)):
    item = ls[i:i+chunk_size]
    if len(item) == chunk_size:
      append_items = sum(item)%10
      result.append(append_items)

  if len(result)  > 1:
      return triangular_sum(result)
  else:
    return result[0]
