# Given a number n, write a formula that returns n!.
#
# In case you forgot the factorial formula, 
# n! = n * (n-1) * (n-2) * ..... * 2 * 1.
#
# For example, 5! = 5 * 4 * 3 * 2 * 1 = 120 so we'd return 120.
#
# Assume n is a non-negative integer.
#
# p.s. if this problem seems too trivial, try the follow-up Microsoft interview problem

def factorial(n):
  if n < 0:
    return ('no factorial for the negative numbers')
  if (n == 0) or (n == 1):
    return 1
  else:
    return n * factorial(n-1)
