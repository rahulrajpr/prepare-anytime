# Python Data Structures & Fundamentals - Study Guide

## 1. Python Data Types Overview

### Primitive Types
- **int**: Arbitrary precision integers (no overflow in Python 3)
- **float**: 64-bit floating point (IEEE 754)
- **bool**: True/False (subclass of int)
- **str**: Immutable Unicode strings
- **bytes**: Immutable sequence of bytes
- **bytearray**: Mutable sequence of bytes
- **None**: Null value singleton

### Collection Types
- **list**: Mutable, ordered, allows duplicates
- **tuple**: Immutable, ordered, allows duplicates
- **set**: Mutable, unordered, unique elements
- **frozenset**: Immutable set
- **dict**: Mutable, key-value pairs (ordered from Python 3.7+)

---

## 2. Bytes & Bytearray - Deep Dive

### Creating Bytes Objects
```python
# Different ways to create bytes
b1 = b'hello'  # String literal
b2 = bytes([72, 101, 108, 108, 111])  # From iterable of integers
b3 = bytes(5)  # Create 5 zero bytes
b4 = 'hello'.encode('utf-8')  # From string
```

### Key Characteristics
- Each element is an integer 0-255
- Immutable (use bytearray for mutable version)
- Memory efficient for binary data

### Common Operations
```python
# Indexing returns integers
b = b'hello'
print(b[0])  # 104 (ASCII value of 'h')

# Slicing returns bytes
print(b[0:2])  # b'he'

# Cannot modify bytes (immutable)
# b[0] = 72  # TypeError!
```

### Edge Cases with Bytes

**Edge Case 1: Bytes are not strings**
```python
b = b'test'
# This fails:
# b.upper()  # No - bytes don't have string methods in Python 3
# Correct way:
result = b.decode('utf-8').upper().encode('utf-8')
```

**Edge Case 2: Integer range validation**
```python
# Valid: 0-255
valid = bytes([0, 127, 255])

# Invalid: outside range
try:
    invalid = bytes([256])  # ValueError
except ValueError as e:
    print(f"Error: {e}")

try:
    invalid = bytes([-1])  # ValueError
except ValueError as e:
    print(f"Error: {e}")
```

**Edge Case 3: Unicode encoding issues**
```python
# Different encodings produce different bytes
text = "café"
utf8_bytes = text.encode('utf-8')    # b'caf\xc3\xa9'
latin1_bytes = text.encode('latin-1') # b'caf\xe9'

# Decoding with wrong encoding causes issues
try:
    wrong = utf8_bytes.decode('ascii')  # UnicodeDecodeError
except UnicodeDecodeError:
    print("Cannot decode UTF-8 bytes as ASCII")
```

**Edge Case 4: Bytearray mutability**
```python
ba = bytearray(b'hello')
ba[0] = 72  # OK - bytearray is mutable
ba.append(33)  # b'hello!'

# But still integer constraint
try:
    ba[0] = 'H'  # TypeError: an integer is required
except TypeError as e:
    print(f"Error: {e}")
```

---

## 3. List Edge Cases

**Edge Case 1: List multiplication creates shallow copies**
```python
# Dangerous with mutable objects
matrix = [[0] * 3] * 3  # Creates 3 references to SAME list!
matrix[0][0] = 1
print(matrix)  # [[1, 0, 0], [1, 0, 0], [1, 0, 0]] - ALL rows changed!

# Correct way:
matrix = [[0] * 3 for _ in range(3)]
matrix[0][0] = 1
print(matrix)  # [[1, 0, 0], [0, 0, 0], [0, 0, 0]] - Only first row changed
```

**Edge Case 2: Modifying list during iteration**
```python
nums = [1, 2, 3, 4, 5]
# Wrong - skips elements
for num in nums:
    if num % 2 == 0:
        nums.remove(num)  # Modifies list during iteration

# Correct approaches:
# 1. Iterate over copy
for num in nums[:]:
    if num % 2 == 0:
        nums.remove(num)

# 2. List comprehension
nums = [num for num in nums if num % 2 != 0]
```

**Edge Case 3: Default mutable arguments**
```python
# Dangerous!
def add_item(item, lst=[]):  # Default list is created ONCE
    lst.append(item)
    return lst

print(add_item(1))  # [1]
print(add_item(2))  # [1, 2] - same list!

# Correct way:
def add_item(item, lst=None):
    if lst is None:
        lst = []
    lst.append(item)
    return lst
```

**Edge Case 4: Negative indexing**
```python
nums = [1, 2, 3, 4, 5]
print(nums[-1])   # 5 (last element)
print(nums[-6])   # IndexError (out of range)

# But slicing doesn't raise errors
print(nums[-10:])  # [1, 2, 3, 4, 5] - returns full list
print(nums[:10])   # [1, 2, 3, 4, 5] - returns full list
```

---

## 4. Dictionary Edge Cases

**Edge Case 1: Key requirements**
```python
# Keys must be hashable (immutable)
valid = {1: 'a', 'key': 'b', (1, 2): 'c'}  # OK

try:
    invalid = {[1, 2]: 'value'}  # TypeError - lists are unhashable
except TypeError as e:
    print(f"Error: {e}")

# Mutable default values issue
d = {'key': []}
d['key'].append(1)  # Modifies the list in place
```

**Edge Case 2: Dictionary ordering (Python 3.7+)**
```python
# Dicts maintain insertion order
d = {'b': 2, 'a': 1, 'c': 3}
print(list(d.keys()))  # ['b', 'a', 'c'] - preserves insertion order

# But equality ignores order
d1 = {'a': 1, 'b': 2}
d2 = {'b': 2, 'a': 1}
print(d1 == d2)  # True
```

**Edge Case 3: KeyError vs get() vs setdefault()**
```python
d = {'a': 1}

# KeyError
try:
    value = d['b']  # KeyError
except KeyError:
    print("Key not found")

# get() returns None or default
value = d.get('b')  # None
value = d.get('b', 0)  # 0

# setdefault() adds key if missing
value = d.setdefault('b', 0)  # Adds 'b': 0 to dict
print(d)  # {'a': 1, 'b': 0}
```

**Edge Case 4: Dictionary view objects**
```python
d = {'a': 1, 'b': 2}
keys = d.keys()  # Returns a view, not a list

# View reflects changes
d['c'] = 3
print(list(keys))  # ['a', 'b', 'c'] - includes new key!

# Cannot modify dict during iteration over view
for key in d.keys():
    if key == 'a':
        # d['d'] = 4  # RuntimeError: dictionary changed size during iteration
        pass
```

---

## 5. Set Edge Cases

**Edge Case 1: Set element requirements**
```python
# Elements must be hashable
valid = {1, 'a', (1, 2), frozenset([3, 4])}

try:
    invalid = {[1, 2], 3}  # TypeError - lists are unhashable
except TypeError as e:
    print(f"Error: {e}")
```

**Edge Case 2: Set vs frozenset**
```python
# Set is mutable
s = {1, 2, 3}
s.add(4)  # OK

# frozenset is immutable
fs = frozenset([1, 2, 3])
# fs.add(4)  # AttributeError - no add method

# frozenset can be dict key or set element
nested = {fs: 'value'}  # OK
set_of_sets = {fs}  # OK
```

**Edge Case 3: Empty set syntax**
```python
# Wrong - this creates an empty dict!
empty = {}
print(type(empty))  # <class 'dict'>

# Correct - creates empty set
empty_set = set()
print(type(empty_set))  # <class 'set'>
```

---

## 6. String Edge Cases

**Edge Case 1: String immutability**
```python
s = "hello"
# s[0] = 'H'  # TypeError - strings are immutable

# Must create new string
s = 'H' + s[1:]  # "Hello"
```

**Edge Case 2: String interning**
```python
# Small strings are interned
a = "hello"
b = "hello"
print(a is b)  # True (same object in memory)

# Concatenation may not be interned
a = "hello" + " world"
b = "hello" + " world"
print(a is b)  # False (different objects)
print(a == b)  # True (same value)
```

**Edge Case 3: Unicode and encoding**
```python
# Unicode code points
emoji = "😀"
print(len(emoji))  # 1 character
print(len(emoji.encode('utf-8')))  # 4 bytes

# Escape sequences
s = "line1\nline2"
print(len(s))  # 11 (\n is one character)

raw = r"line1\nline2"
print(len(raw))  # 12 (backslash and n are separate)
```

---

## 7. Tuple Edge Cases

**Edge Case 1: Single element tuple**
```python
# Wrong - this is not a tuple!
not_tuple = (1)
print(type(not_tuple))  # <class 'int'>

# Correct - need trailing comma
single_tuple = (1,)
print(type(single_tuple))  # <class 'tuple'>

# Also valid
another = 1,
print(type(another))  # <class 'tuple'>
```

**Edge Case 2: Tuple unpacking**
```python
# Unpacking
a, b, c = (1, 2, 3)  # OK

try:
    a, b = (1, 2, 3)  # ValueError: too many values to unpack
except ValueError as e:
    print(f"Error: {e}")

# Extended unpacking
a, *rest, c = (1, 2, 3, 4, 5)
print(a, rest, c)  # 1 [2, 3, 4] 5
```

**Edge Case 3: Tuples with mutable elements**
```python
# Tuple is immutable, but elements can be mutable
t = (1, [2, 3], 4)
# t[1] = [5, 6]  # TypeError - cannot reassign

# But can modify the mutable element
t[1].append(99)  # OK - modifying the list inside
print(t)  # (1, [2, 3, 99], 4)

# This affects hashability
try:
    d = {t: 'value'}  # TypeError: unhashable type: 'list'
except TypeError as e:
    print(f"Error: {e}")
```

---

## 8. Type Conversion Edge Cases

**Edge Case 1: Boolean conversion**
```python
# Falsy values in Python
print(bool(0))        # False
print(bool(0.0))      # False
print(bool(''))       # False
print(bool([]))       # False
print(bool({}))       # False
print(bool(None))     # False

# Everything else is truthy
print(bool(-1))       # True
print(bool('0'))      # True (string '0' is truthy!)
print(bool([0]))      # True (list with zero is truthy!)
```

**Edge Case 2: Integer division and floor division**
```python
# Division always returns float
print(10 / 5)   # 2.0 (float)
print(10 / 3)   # 3.3333...

# Floor division
print(10 // 3)  # 3
print(-10 // 3) # -4 (floors toward negative infinity)

# Modulo with negative numbers
print(10 % 3)   # 1
print(-10 % 3)  # 2 (not -1!)
print(10 % -3)  # -2
```

**Edge Case 3: Float precision**
```python
# Float precision issues
print(0.1 + 0.2)  # 0.30000000000000004 (not exactly 0.3!)
print(0.1 + 0.2 == 0.3)  # False

# Use decimal for precise calculations
from decimal import Decimal
print(Decimal('0.1') + Decimal('0.2'))  # 0.3
print(Decimal('0.1') + Decimal('0.2') == Decimal('0.3'))  # True

# Or compare with tolerance
import math
print(math.isclose(0.1 + 0.2, 0.3))  # True
```

---

## Quick Reference: Time Complexities

| Operation | List | Tuple | Dict | Set |
|-----------|------|-------|------|-----|
| Access by index | O(1) | O(1) | N/A | N/A |
| Access by key | N/A | N/A | O(1) avg | N/A |
| Search | O(n) | O(n) | O(1) avg | O(1) avg |
| Insert/Delete at end | O(1) amortized | N/A | O(1) avg | O(1) avg |
| Insert/Delete at beginning | O(n) | N/A | O(1) avg | O(1) avg |
| Insert/Delete in middle | O(n) | N/A | O(1) avg | O(1) avg |

---

## Memory Efficiency Tips

1. **Use tuples instead of lists** when data is immutable (saves memory)
2. **Use generators** for large sequences that don't need to be stored
3. **Use sets for membership testing** instead of lists
4. **Use array.array** for large numeric arrays instead of lists
5. **Be careful with string concatenation** in loops (use join())
