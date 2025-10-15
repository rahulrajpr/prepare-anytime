# You're given an array nums of n integers and an integer k.

# The k-radius average for a subarray of nums centered at some index i is the average of all elements 
# from indices i - k to i + k (inclusive). If there aren't enough elements before or after index i 
# to cover this radius, the k-radius average is -1.

# Build and return an array averages of length n, where averages[i] contains the k-radius average 
# for the subarray centered at index i.

# Return your result rounded to 2 decimal places.

def k_radius_avg(nums, k):
    result_array = []
    iterate_range = range(len(nums))
    
    for i in iterate_range:
        start = i - k
        end = i + k + 1  # +1 because Python slicing excludes the end index
        
        avg_value = -1
        
        if start >= 0 and end <= len(nums):
            sub_array = nums[start:end]
            avg_value = round(sum(sub_array) / len(sub_array), 2)
        
        result_array.append(avg_value)
    
    return result_array
