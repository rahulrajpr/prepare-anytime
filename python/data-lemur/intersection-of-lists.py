# Write a function to get the intersection of two lists.
# For example, if A = [1, 2, 3, 4, 5], and B = [0, 1, 3, 7] then you should return [1, 3].

def intersection(a, b):
  a_set = set(a)
  b_set = set(b)
  set_intersection = a_set.intersection(b_set)
  return list(set_intersection)
