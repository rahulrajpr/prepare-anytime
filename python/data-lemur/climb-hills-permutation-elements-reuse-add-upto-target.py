# You're attempting to climb a hill—not in a mathematical optimization sense (check out hill climbing for that), 
# but literally outside, touching grass, and trying to climb a hill.

# Imagine there are n steps carved into the hill. You can go up using either 1 or 2 steps at a time.

# Your task is to return the number of distinct ways to reach the top of the hill.

# Example 1:
# Input: 3
# Output: 3
# Explanation: There are three distinct ways to climb to the top of a hill with 3 steps:
# 1. Take 1 step, then 1 step, then 1 step.
# 2. Take 1 step, then 2 steps.
# 3. Take 2 steps, then 1 step.

# Example 2:
# Input: 4
# Output: 5
# Explanation: There are five distinct ways to climb to the top of a hill with 4 steps:
# 1. Take 1 step, then 1 step, then 1 step, then 1 step.
# 2. Take 1 step, then 1 step, then 2 steps.
# 3. Take 1 step, then 2 steps, then 1 step.
# 4. Take 2 steps, then 1 step, then 1 step.
# 5. Take 2 steps, then 2 steps.

def climb_hill(n):
    nums = [1, 2]
    results = []

    def backtrack(path, current_sum):
        if current_sum == n:
            results.append(path.copy())  # found a valid way
            return
        if current_sum > n:
            return  # overshot, stop this branch

        for step in nums:
            path.append(step)  # take this step
            backtrack(path, current_sum + step)  # try next
            path.pop()  # backtrack

    backtrack([], 0)
    return len(results)
