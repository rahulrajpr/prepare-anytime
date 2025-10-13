
# Write a function fizz_buzz_sum to find the sum of all multiples of 3 or 5 below a target value.
# For example, if the target value was 10, the multiples of 3 or 5 below 10 are 3, 5, 6, and 9.
# Because 3 + 5 + 6 + 9 = 23, our function would return 23.

def fizz_buzz_sum(target):
  three_multiples = [x for x in range(0,target) if x%3 == 0]
  five_multiples = [x for x in range(0,target) if x%5 == 0]
  all_multiple = three_multiples + five_multiples
  all_multiple_unique = set(all_multiple)
  return sum(all_multiple_unique)
