# Bytestring Edge Cases & Advanced Manipulations

## Table of Contents
1. Bytestrings in Lists
2. Bytestring Manipulation Operations
3. Comparison and Sorting
4. Encoding/Decoding Edge Cases
5. Bytestrings in Data Structures
6. File I/O with Bytes
7. Memory and Performance

---

## 1. Bytestrings in Lists

### Edge Case 1: Mixing Bytes and Strings in Lists
```python
# List containing both bytes and strings
mixed_list = [b'hello', 'world', b'test', 'data']

# DANGER: Can't directly concatenate bytes and strings
try:
    result = mixed_list[0] + mixed_list[1]  # TypeError
except TypeError as e:
    print(f"Error: {e}")  # can't concat bytes to str

# Solution 1: Convert bytes to strings
result1 = mixed_list[0].decode('utf-8') + mixed_list[1]
print(result1)  # 'helloworld'

# Solution 2: Convert strings to bytes
result2 = mixed_list[0] + mixed_list[1].encode('utf-8')
print(result2)  # b'helloworld'

# Filtering by type
bytes_only = [item for item in mixed_list if isinstance(item, bytes)]
strings_only = [item for item in mixed_list if isinstance(item, str)]
print(bytes_only)    # [b'hello', b'test']
print(strings_only)  # ['world', 'data']

# Convert entire list to one type
all_bytes = [item.encode('utf-8') if isinstance(item, str) else item 
             for item in mixed_list]
print(all_bytes)  # [b'hello', b'world', b'test', b'data']

all_strings = [item.decode('utf-8') if isinstance(item, bytes) else item 
               for item in mixed_list]
print(all_strings)  # ['hello', 'world', 'test', 'data']
```

### Edge Case 2: List of Bytestrings - Common Operations
```python
# List of bytestrings
byte_list = [b'apple', b'banana', b'cherry', b'date', b'elderberry']

# 1. SORTING
sorted_bytes = sorted(byte_list)
print(sorted_bytes)  # Sorted lexicographically

# Reverse sorting
reverse_sorted = sorted(byte_list, reverse=True)

# 2. SEARCHING
if b'banana' in byte_list:
    print("Found banana")

# Find index
index = byte_list.index(b'cherry')
print(f"Cherry at index: {index}")  # 2

# Count occurrences
byte_list_with_dups = [b'apple', b'banana', b'apple', b'date']
count = byte_list_with_dups.count(b'apple')
print(f"Apple appears {count} times")  # 2

# 3. JOINING - CRITICAL DIFFERENCE FROM STRINGS!
# WRONG - This doesn't work with bytes:
try:
    result = ''.join(byte_list)  # TypeError
except TypeError as e:
    print(f"Error: {e}")

# CORRECT - Use bytes delimiter:
delimiter = b', '
result = delimiter.join(byte_list)
print(result)  # b'apple, banana, cherry, date, elderberry'

# Join without delimiter
result = b''.join(byte_list)
print(result)  # b'applebananacherrydate elderberry'

# 4. SPLITTING
data = b'apple,banana,cherry,date'
items = data.split(b',')
print(items)  # [b'apple', b'banana', b'cherry', b'date']
print(type(items[0]))  # <class 'bytes'>

# Split with maxsplit
data = b'apple,banana,cherry,date'
items = data.split(b',', 2)
print(items)  # [b'apple', b'banana', b'cherry,date']
```

### Edge Case 3: Nested Lists with Bytes
```python
# 2D list of bytes
matrix = [
    [b'a', b'b', b'c'],
    [b'd', b'e', b'f'],
    [b'g', b'h', b'i']
]

# Accessing elements
print(matrix[0][0])  # b'a'
print(matrix[1][2])  # b'f'

# Flattening nested byte lists
nested = [[b'hello', b'world'], [b'foo', b'bar'], [b'test']]
flattened = [item for sublist in nested for item in sublist]
print(flattened)  # [b'hello', b'world', b'foo', b'bar', b'test']

# Join all into one bytestring
result = b' '.join(flattened)
print(result)  # b'hello world foo bar test'
```

---

## 2. Bytestring Manipulation Operations

### Edge Case 4: Slicing and Indexing
```python
data = b'hello world'

# Basic slicing - returns bytes
print(data[0:5])     # b'hello'
print(data[-5:])     # b'world'
print(data[::2])     # b'hlowrd' (every 2nd byte)
print(data[::-1])    # b'dlrow olleh' (reversed)

# Indexing - returns integer!
print(data[0])       # 104 (ASCII value of 'h')
print(type(data[0])) # <class 'int'>

# To get single byte as bytes object, use slice
print(data[0:1])     # b'h'
print(type(data[0:1]))  # <class 'bytes'>

# Edge case: Out of bounds slicing (no error)
print(data[100:200])  # b'' (empty bytes)
print(data[-100:])    # b'hello world' (entire string)
```

### Edge Case 5: Replace, Find, and Search
```python
data = b'hello world hello python hello'

# Replace (returns new bytes object)
replaced = data.replace(b'hello', b'hi')
print(replaced)  # b'hi world hi python hi'

# Replace with count limit
replaced_once = data.replace(b'hello', b'hi', 1)
print(replaced_once)  # b'hi world hello python hello'

# Find (returns index or -1)
print(data.find(b'world'))      # 6
print(data.find(b'java'))       # -1 (not found)
print(data.rfind(b'hello'))     # 20 (rightmost occurrence)

# Index (raises ValueError if not found)
try:
    print(data.index(b'hello'))  # 0
    print(data.index(b'java'))   # ValueError
except ValueError as e:
    print(f"Error: {e}")

# Count occurrences
print(data.count(b'hello'))     # 3
print(data.count(b'l'))         # 6

# Startswith and endswith
print(data.startswith(b'hello'))  # True
print(data.endswith(b'python'))   # False
print(data.endswith(b'hello'))    # True
```

### Edge Case 6: Case Conversion
```python
data = b'Hello World'

# Case conversion
print(data.lower())      # b'hello world'
print(data.upper())      # b'HELLO WORLD'
print(data.capitalize()) # b'Hello world'
print(data.title())      # b'Hello World'
print(data.swapcase())   # b'hELLO wORLD'

# Check case
print(b'HELLO'.isupper())  # True
print(b'hello'.islower())  # True
print(b'Hello'.istitle())  # True

# Only works with ASCII bytes!
# Non-ASCII may behave unexpectedly
french = 'café'.encode('utf-8')  # b'caf\xc3\xa9'
print(french.upper())  # b'CAF\xc3\xa9' (é not converted!)

# For proper Unicode handling, decode first
proper = french.decode('utf-8').upper().encode('utf-8')
print(proper)  # b'CAF\xc3\x89' (proper uppercase É)
```

### Edge Case 7: Strip, Trim, and Padding
```python
# Stripping whitespace
data = b'   hello world   '
print(data.strip())   # b'hello world'
print(data.lstrip())  # b'hello world   '
print(data.rstrip())  # b'   hello world'

# Strip specific bytes
data = b'xxxhelloxxx'
print(data.strip(b'x'))  # b'hello'

data = b'000042000'
print(data.strip(b'0'))  # b'42'

# Padding
data = b'test'
print(data.ljust(10))         # b'test      '
print(data.ljust(10, b'_'))   # b'test______'
print(data.rjust(10, b'_'))   # b'______test'
print(data.center(10, b'*'))  # b'***test***'

# Zero padding
data = b'42'
print(data.zfill(5))  # b'00042'

# Negative numbers
data = b'-42'
print(data.zfill(5))  # b'-0042' (zero after sign)
```

### Edge Case 8: Partition and Split
```python
data = b'hello:world:python'

# Partition (splits at first occurrence)
parts = data.partition(b':')
print(parts)  # (b'hello', b':', b'world:python')

# Rpartition (splits at last occurrence)
parts = data.rpartition(b':')
print(parts)  # (b'hello:world', b':', b'python')

# Splitlines
multiline = b'line1\nline2\r\nline3'
lines = multiline.splitlines()
print(lines)  # [b'line1', b'line2', b'line3']

# Keep line endings
lines_with_endings = multiline.splitlines(keepends=True)
print(lines_with_endings)  # [b'line1\n', b'line2\r\n', b'line3']
```

---

## 3. Comparison and Sorting

### Edge Case 9: Bytes vs String Comparison
```python
b = b'hello'
s = 'hello'

# Direct comparison is ALWAYS False (different types)
print(b == s)         # False
print(b != s)         # True

# Must convert to compare values
print(b.decode('utf-8') == s)  # True
print(b == s.encode('utf-8'))  # True

# Comparison operators don't work across types
try:
    print(b < s)  # TypeError in Python 3
except TypeError as e:
    print(f"Error: {e}")
```

### Edge Case 10: Lexicographic Ordering
```python
# Bytes comparison is lexicographic (byte-by-byte)
print(b'apple' < b'banana')   # True
print(b'100' < b'20')         # True (string comparison, not numeric!)
print(b'abc' < b'abd')        # True

# Numeric comparison requires conversion
num1 = b'100'
num2 = b'20'
print(int(num1) < int(num2))  # False (proper numeric comparison)

# Sorting list of bytes
byte_list = [b'zebra', b'apple', b'mango', b'banana']
sorted_list = sorted(byte_list)
print(sorted_list)  # [b'apple', b'banana', b'mango', b'zebra']

# Case-sensitive sorting
mixed_case = [b'Apple', b'banana', b'Cherry']
print(sorted(mixed_case))  # [b'Apple', b'Cherry', b'banana'] (uppercase first)

# Case-insensitive sorting
print(sorted(mixed_case, key=lambda x: x.lower()))  # [b'Apple', b'banana', b'Cherry']
```

---

## 4. Encoding/Decoding Edge Cases

### Edge Case 11: Multi-byte Character Hazards
```python
# UTF-8 multi-byte characters
emoji = '😀'
emoji_bytes = emoji.encode('utf-8')
print(emoji_bytes)        # b'\xf0\x9f\x98\x80' (4 bytes)
print(len(emoji_bytes))   # 4

# DANGER: Slicing can corrupt multi-byte sequences!
try:
    # Taking only 2 of 4 bytes
    partial = emoji_bytes[:2]
    decoded = partial.decode('utf-8')  # UnicodeDecodeError
except UnicodeDecodeError as e:
    print(f"Error: {e}")

# Safe way: decode first, operate on string, then encode
text = 'café 😀 python'
text_bytes = text.encode('utf-8')

# Wrong: slice bytes
# correct_slice = text_bytes[:5]  # Might corrupt é or emoji!

# Right: decode, slice, encode
decoded = text_bytes.decode('utf-8')
sliced = decoded[:5]  # 'café '
result = sliced.encode('utf-8')
print(result)  # Safe result

# Check for valid UTF-8
def is_valid_utf8(byte_string):
    try:
        byte_string.decode('utf-8')
        return True
    except UnicodeDecodeError:
        return False

print(is_valid_utf8(b'hello'))           # True
print(is_valid_utf8(b'\xff\xfe'))        # False
```

### Edge Case 12: Different Encodings
```python
text = "café"

# Different encodings produce different bytes
utf8 = text.encode('utf-8')        # b'caf\xc3\xa9'
latin1 = text.encode('latin-1')    # b'caf\xe9'
utf16 = text.encode('utf-16')      # b'\xff\xfe c\x00a\x00f\x00\xe9\x00'

print(f"UTF-8: {utf8}, length: {len(utf8)}")
print(f"Latin-1: {latin1}, length: {len(latin1)}")
print(f"UTF-16: {utf16}, length: {len(utf16)}")

# Decoding with wrong encoding
try:
    wrong = utf8.decode('ascii')  # UnicodeDecodeError
except UnicodeDecodeError as e:
    print(f"Error: {e}")

try:
    wrong = utf8.decode('latin-1')  # Succeeds but gives wrong result!
    print(f"Wrong result: {wrong}")  # 'cafÃ©' (mojibake)
except Exception as e:
    print(f"Error: {e}")

# Error handling strategies
# 1. Ignore errors
result = utf8.decode('ascii', errors='ignore')
print(result)  # 'caf' (skips non-ASCII)

# 2. Replace with placeholder
result = utf8.decode('ascii', errors='replace')
print(result)  # 'caf��' (replacement character)

# 3. Use backslashreplace
result = utf8.decode('ascii', errors='backslashreplace')
print(result)  # 'caf\\xc3\\xa9'
```

---

## 5. Bytestrings in Data Structures

### Edge Case 13: Bytes as Dictionary Keys
```python
# Bytes are hashable - can be dict keys
byte_dict = {
    b'key1': 'value1',
    b'key2': 'value2',
    b'key3': 'value3'
}

print(byte_dict[b'key1'])  # 'value1'

# CRITICAL: Bytes and strings are DIFFERENT keys!
mixed_keys = {
    b'key': 'from_bytes',
    'key': 'from_string'
}
print(len(mixed_keys))     # 2 (both exist!)
print(mixed_keys[b'key'])  # 'from_bytes'
print(mixed_keys['key'])   # 'from_string'

# This can cause subtle bugs
def get_value(d, key):
    # If key is string but dict has bytes keys, this fails:
    return d.get(key, 'Not found')

print(get_value(byte_dict, 'key1'))   # 'Not found' (wrong type!)
print(get_value(byte_dict, b'key1'))  # 'value1' (correct)

# Safe retrieval function
def safe_get(d, key):
    # Try original key
    if key in d:
        return d[key]
    # Try converting
    if isinstance(key, str):
        return d.get(key.encode('utf-8'), None)
    elif isinstance(key, bytes):
        return d.get(key.decode('utf-8'), None)
    return None
```

### Edge Case 14: Bytes in Sets
```python
# Bytes in sets
byte_set = {b'apple', b'banana', b'apple'}  # Duplicates removed
print(byte_set)  # {b'apple', b'banana'}

# Set operations
set1 = {b'apple', b'banana', b'cherry'}
set2 = {b'banana', b'cherry', b'date'}

print(set1 | set2)  # Union: {b'apple', b'banana', b'cherry', b'date'}
print(set1 & set2)  # Intersection: {b'banana', b'cherry'}
print(set1 - set2)  # Difference: {b'apple'}

# Mixing bytes and strings in sets
mixed_set = {b'test', 'test'}
print(len(mixed_set))  # 2 (treated as different!)

# Membership testing
print(b'apple' in {b'apple', b'banana'})  # True
print('apple' in {b'apple', b'banana'})   # False (different type)
```

---

## 6. File I/O with Bytes

### Edge Case 15: Text vs Binary Mode
```python
import os

# Writing
# Text mode
with open('test.txt', 'w') as f:
    f.write('hello world')  # Requires string

# Binary mode
with open('test.bin', 'wb') as f:
    f.write(b'hello world')  # Requires bytes

# Reading - mode affects return type
with open('test.txt', 'r') as f:
    content = f.read()
    print(type(content))  # <class 'str'>

with open('test.txt', 'rb') as f:
    content = f.read()
    print(type(content))  # <class 'bytes'>

# Common error: mode mismatch
try:
    with open('test.txt', 'wb') as f:
        f.write('hello')  # TypeError: need bytes
except TypeError as e:
    print(f"Error: {e}")

try:
    with open('test.txt', 'w') as f:
        f.write(b'hello')  # TypeError: need string
except TypeError as e:
    print(f"Error: {e}")

# Reading lines
with open('test.txt', 'rb') as f:
    lines = f.readlines()
    print(type(lines[0]))  # <class 'bytes'> (includes \n)

# Clean up
os.remove('test.txt')
os.remove('test.bin')
```

---

## 7. Memory and Performance

### Edge Case 16: Memory Efficiency
```python
import sys

# Strings store Unicode (more memory per character)
text = 'hello world' * 100
print(f"String size: {sys.getsizeof(text)} bytes")

# Bytes are more compact
data = b'hello world' * 100
print(f"Bytes size: {sys.getsizeof(data)} bytes")

# For large binary data, bytes are significantly more efficient
large_text = 'x' * 1000000
large_bytes = b'x' * 1000000

print(f"Large string: {sys.getsizeof(large_text):,} bytes")
print(f"Large bytes: {sys.getsizeof(large_bytes):,} bytes")
```

### Edge Case 17: Bytes Iteration Performance
```python
data = b'hello world'

# Method 1: Direct iteration (yields integers)
for byte_val in data:
    # byte_val is int
    char = chr(byte_val)
    
# Method 2: Iterate with index (get bytes slices)
for i in range(len(data)):
    byte_slice = data[i:i+1]  # Returns bytes object

# Method 3: Using bytearray for mutable operations
ba = bytearray(data)
for i in range(len(ba)):
    ba[i] = ba[i] + 1  # Modify in place (Caesar cipher shift)
print(ba)  # Each byte incremented by 1
```

---

## Common Interview Questions

### Q1: How do you safely concatenate a list of mixed bytes/strings?
```python
def safe_concat(items):
    # Convert all to bytes
    result = b''
    for item in items:
        if isinstance(item, str):
            result += item.encode('utf-8')
        elif isinstance(item, bytes):
            result += item
        else:
            raise TypeError(f"Unsupported type: {type(item)}")
    return result

# Test
mixed = [b'hello', ' world', b' python']
print(safe_concat(mixed))  # b'hello world python'
```

### Q2: How to check if bytes contain only ASCII?
```python
def is_ascii(byte_string):
    try:
        byte_string.decode('ascii')
        return True
    except UnicodeDecodeError:
        return False

# Or using all()
def is_ascii_v2(byte_string):
    return all(b < 128 for b in byte_string)

print(is_ascii(b'hello'))      # True
print(is_ascii(b'caf\xc3\xa9')) # False (contains UTF-8 é)
```

### Q3: Remove duplicates from list of bytestrings
```python
byte_list = [b'apple', b'banana', b'apple', b'cherry', b'banana']

# Method 1: Using set (loses order)
unique = list(set(byte_list))

# Method 2: Preserve order
seen = set()
unique_ordered = []
for item in byte_list:
    if item not in seen:
        seen.add(item)
        unique_ordered.append(item)

print(unique_ordered)  # [b'apple', b'banana', b'cherry']
```

---

## Quick Reference: Key Differences

| Operation | String | Bytes |
|-----------|--------|-------|
| Indexing | Returns str | Returns int |
| Iteration | Yields str | Yields int |
| Join | `''.join(list)` | `b''.join(list)` |
| Immutable | Yes | Yes |
| Mutable version | N/A | bytearray |
| Format strings | f-strings, % | Only via encode |
| Dict key | Yes | Yes |
| Comparable | str == str | bytes == bytes |
| Cross-type compare | Auto-convert in Py2 | False in Py3 |
