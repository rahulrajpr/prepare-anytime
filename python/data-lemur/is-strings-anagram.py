
# Given two strings s and t, return True if the two strings are anagrams of each other, otherwise return False.
# An anagram is a word or phrase formed by rearranging the letters of a different word or phrase, 
# using all the original letters exactly once.

def is_anagram(s, t):
	return set(s.lower()) == set(t.lower())
