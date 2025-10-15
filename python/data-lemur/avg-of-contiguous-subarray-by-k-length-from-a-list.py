# Your task is to find a contiguous subarray of nums whose length is exactly k that has the highest average value. 
# A subarray is simply a sequence of consecutive elements from the original array. After identifying this subarray, 
# return the average value, rounded to two decimal places.
#
# Example #1
# Input: nums = [1, 2, -5, -3, 10, 3], k = 3
# Output: 3.33
# Explanation: The subarray here is [-3, 10, 3] , so the average is 3.33.
#
# Example #2
# Input: nums = [9], k = 1
# Output: 9.00
# Explanation: The subarray here is just [9], so its average is exactly 9.00.

def max_avg_subarray(nums, k):
    if not nums:
        return None
    if len(nums) == 1:
        return nums[0]
    array_len = len(nums)
    if k > array_len:
        return None
    if k == array_len:
        return round(sum(nums)/len(nums), 2)
    
    allsubarray = []
    for ind in range(0, array_len - k + 1):  # Only go up to array_len - k
        start = ind
        end = start + k
        subarray = nums[start:end]
        allsubarray.append(subarray)
    
    avg_array = [round(sum(x)/len(x), 2) for x in allsubarray]
    return max(avg_array)
