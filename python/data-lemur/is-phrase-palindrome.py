
# Given a string phrase, return True if it is a palindrome, otherwise return False.
# A palindrome is a string that reads the same forward and backward. It is also case-insensitive 
# and ignores all non-alphanumeric characters.

# Challenge: Try solving this without using extra memory. Specifically, solve it without making a copy of phrase.
# Clarifications:
# phrase is made up of only: letters, numbers, spaces, and standard punctuation/symbols

# Example #1
# Input: phrase = "Taco cat."
# Output: True
# Explanation: Considering only alphanumeric characters and converting to lowercase, "tacocat" is a palindrome.

# Example #2
# Input: phrase = "I love SQL <3"
# Output: False
# Explanation: Considering only alphanumeric characters and converting to lowercase, "ilovesql3" is not even close.

def isPalindrome(phrase):
  phrase = [x.lower() for x in phrase if x.isalnum() == True]
  return phrase == phrase[::-1]
