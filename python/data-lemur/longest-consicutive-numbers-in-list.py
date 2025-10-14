# Given an array of integers nums, return the length of the longest consecutive sequence of elements 
# that can be formed from the array.

# A consecutive sequence consists of elements where each element is exactly 1 greater than the previous element. 
# The elements in the sequence can be selected from any position in the array and do not need to appear 
# in their original order.

# Example #1
# Input: nums = [100, 4, 200, 1, 3, 2]
# Output: 4
# Explanation: The longest consecutive is [1, 2, 3, 4] which have a length of 4

# Example #2
# Input: nums = [3, 2]
# Output: 2
# Explanation: The longest consecutive is [2, 3] which have a length of 2

def longest_consecutive(nums):
  if not nums:
    return 0
  if len(nums) == 1:
    return 1
  else:
    nums = sorted(nums)
    longest_streak = 1
    current_streak = 1
    
    for i in range(0,len(nums)):
      if i == len(nums)-1:
        break
      if nums[i] + 1 == nums[i+1]:
        current_streak +=1
        longest_streak = max(current_streak, longest_streak)
      else:
        current_streak = 1
  return longest_streak
