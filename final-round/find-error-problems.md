# Find the Error - Python Code Snippets

## Problem 1: List Multiplication Bug
```python
def create_matrix(rows, cols):
    matrix = [[0] * cols] * rows
    matrix[0][0] = 1
    return matrix

result = create_matrix(3, 3)
print(result)
# Expected: [[1, 0, 0], [0, 0, 0], [0, 0, 0]]
# Actual: [[1, 0, 0], [1, 0, 0], [1, 0, 0]]
```

**Error**: List multiplication creates shallow copies - all rows reference the same list object.

**Fix**:
```python
def create_matrix(rows, cols):
    matrix = [[0] * cols for _ in range(rows)]  # Create separate lists
    matrix[0][0] = 1
    return matrix
```

---

## Problem 2: Mutable Default Argument
```python
def add_employee(name, department, employees=[]):
    employees.append({'name': name, 'dept': department})
    return employees

team1 = add_employee('Alice', 'Engineering')
team2 = add_employee('Bob', 'Marketing')
print(team1)
print(team2)
# Both show: [{'name': 'Alice', 'dept': 'Engineering'}, {'name': 'Bob', 'dept': 'Marketing'}]
```

**Error**: Default mutable argument is created once and shared across all calls.

**Fix**:
```python
def add_employee(name, department, employees=None):
    if employees is None:
        employees = []
    employees.append({'name': name, 'dept': department})
    return employees
```

---

## Problem 3: Modifying Dictionary During Iteration
```python
def remove_empty_values(data):
    for key in data.keys():
        if not data[key]:
            del data[key]
    return data

result = remove_empty_values({'a': 1, 'b': '', 'c': 3, 'd': None})
# RuntimeError: dictionary changed size during iteration
```

**Error**: Cannot modify dictionary size while iterating over it.

**Fix**:
```python
def remove_empty_values(data):
    # Option 1: Iterate over copy of keys
    for key in list(data.keys()):
        if not data[key]:
            del data[key]
    return data

# Option 2: Dictionary comprehension (preferred)
def remove_empty_values(data):
    return {k: v for k, v in data.items() if v}
```

---

## Problem 4: Integer Division Issue
```python
def calculate_average(total, count):
    return total / count

result = calculate_average(10, 4)
print(result)
print(type(result))
# Returns: 2.5, <class 'float'>

# But for floor division:
def items_per_page(total_items, page_size):
    return total_items / page_size  # Should return integer pages

pages = items_per_page(10, 3)
print(pages)  # 3.333... - Wrong! Need 4 pages
```

**Error**: Using regular division `/` instead of floor division `//` or ceiling.

**Fix**:
```python
import math

def items_per_page(total_items, page_size):
    return math.ceil(total_items / page_size)  # Returns 4

# Or use floor division if you want truncation
def full_pages(total_items, page_size):
    return total_items // page_size  # Returns 3
```

---

## Problem 5: String Modification Attempt
```python
def capitalize_first(text):
    text[0] = text[0].upper()
    return text

result = capitalize_first("hello")
# TypeError: 'str' object does not support item assignment
```

**Error**: Strings are immutable in Python.

**Fix**:
```python
def capitalize_first(text):
    if not text:
        return text
    return text[0].upper() + text[1:]

# Or simply use built-in:
def capitalize_first(text):
    return text.capitalize()
```

---

## Problem 6: Bytes and String Confusion
```python
def process_data(data):
    data = data.upper()
    return data

result = process_data(b'hello')
# AttributeError: 'bytes' object has no attribute 'upper'
```

**Error**: Bytes don't have string methods in Python 3.

**Fix**:
```python
def process_data(data):
    if isinstance(data, bytes):
        data = data.decode('utf-8')
    data = data.upper()
    return data

# Or keep as bytes:
def process_data(data):
    if isinstance(data, bytes):
        return data.decode('utf-8').upper().encode('utf-8')
    return data.upper()
```

---

## Problem 7: Set Element Type Error
```python
def create_unique_groups(items):
    groups = set()
    for item in items:
        groups.add([item, item.upper()])
    return groups

result = create_unique_groups(['a', 'b', 'c'])
# TypeError: unhashable type: 'list'
```

**Error**: Lists cannot be added to sets (not hashable).

**Fix**:
```python
def create_unique_groups(items):
    groups = set()
    for item in items:
        groups.add((item, item.upper()))  # Use tuple instead
    return groups
```

---

## Problem 8: IndexError with Empty List
```python
def get_first_element(items):
    return items[0]

result = get_first_element([])
# IndexError: list index out of range
```

**Error**: No check for empty list before accessing index.

**Fix**:
```python
def get_first_element(items):
    if not items:
        return None
    return items[0]

# Or use default:
def get_first_element(items, default=None):
    return items[0] if items else default
```

---

## Problem 9: Comparing Float Equality
```python
def check_price(price):
    discount = 0.1
    final_price = price - (price * discount)
    if final_price == price * 0.9:
        return "Correct discount"
    return "Incorrect discount"

result = check_price(0.3)
# Returns "Incorrect discount" due to float precision
```

**Error**: Direct float comparison fails due to precision issues.

**Fix**:
```python
import math

def check_price(price):
    discount = 0.1
    final_price = price - (price * discount)
    expected = price * 0.9
    if math.isclose(final_price, expected, rel_tol=1e-9):
        return "Correct discount"
    return "Incorrect discount"
```

---

## Problem 10: Exception Variable Scope
```python
def process_items(items):
    for item in items:
        try:
            result = int(item)
        except ValueError as e:
            print(f"Error: {e}")
    return result  # What value does result have?

process_items(['1', 'abc', '3'])
# Could raise UnboundLocalError if first item fails
```

**Error**: `result` may not be defined if exception occurs on first iteration.

**Fix**:
```python
def process_items(items):
    results = []
    for item in items:
        try:
            result = int(item)
            results.append(result)
        except ValueError as e:
            print(f"Error: {e}")
            results.append(None)
    return results
```

---

## Problem 11: Dictionary Key Type Mismatch
```python
data = {1: 'one', 2: 'two', 3: 'three'}
print(data['1'])  # KeyError: '1'
```

**Error**: String key '1' is different from integer key 1.

**Fix**:
```python
# Option 1: Use correct key type
data = {1: 'one', 2: 'two', 3: 'three'}
print(data[1])  # 'one'

# Option 2: Convert key
print(data[int('1')])  # 'one'

# Option 3: Use get with default
print(data.get('1', 'Key not found'))
```

---

## Problem 12: List Slicing Reference
```python
def modify_sublist(numbers):
    sublist = numbers[1:3]
    sublist[0] = 999
    return numbers

original = [1, 2, 3, 4, 5]
result = modify_sublist(original)
print(result)
# Returns [1, 2, 3, 4, 5] - original unchanged
```

**Error**: Not actually an error, but a misunderstanding. Slicing creates a new list, so modifying the slice doesn't affect the original.

**Explanation**: If you want to modify the original, you need to assign to the slice:
```python
def modify_sublist(numbers):
    numbers[1:3] = [999, 999]
    return numbers

# Or modify in place:
def modify_sublist(numbers):
    numbers[1] = 999
    return numbers
```

---

## Problem 13: Generator Exhaustion
```python
def get_numbers():
    return (x for x in range(5))

numbers = get_numbers()
print(list(numbers))  # [0, 1, 2, 3, 4]
print(list(numbers))  # [] - Generator is exhausted!
```

**Error**: Generators can only be iterated once.

**Fix**:
```python
# Option 1: Create new generator each time
def get_numbers():
    return (x for x in range(5))

numbers1 = get_numbers()
numbers2 = get_numbers()

# Option 2: Use list if you need to reuse
def get_numbers():
    return list(range(5))

numbers = get_numbers()
print(numbers)  # Can use multiple times
print(numbers)
```

---

## Problem 14: Boolean Comparison
```python
def check_status(is_active):
    if is_active == True:  # Problematic
        return "Active"
    return "Inactive"

print(check_status(1))  # Returns "Inactive" - unexpected!
```

**Error**: Using `== True` instead of truthiness check. 1 is truthy but not equal to True in comparison.

**Fix**:
```python
def check_status(is_active):
    if is_active:  # Pythonic way
        return "Active"
    return "Inactive"

# Or explicit type check if needed:
def check_status(is_active):
    if is_active is True:  # Identity check
        return "Active"
    return "Inactive"
```

---

## Problem 15: Closure Variable Binding
```python
def create_multipliers():
    multipliers = []
    for i in range(5):
        multipliers.append(lambda x: x * i)
    return multipliers

funcs = create_multipliers()
print(funcs[0](2))  # Expected: 0, Actual: 8
print(funcs[2](2))  # Expected: 4, Actual: 8
# All functions multiply by 4 (last value of i)
```

**Error**: Late binding - lambda captures reference to `i`, not its value.

**Fix**:
```python
def create_multipliers():
    multipliers = []
    for i in range(5):
        multipliers.append(lambda x, i=i: x * i)  # Bind i as default argument
    return multipliers

# Or use list comprehension:
def create_multipliers():
    return [lambda x, i=i: x * i for i in range(5)]
```

---

## Answer Key Summary

1. List multiplication - Use list comprehension
2. Mutable default - Use None and create new list in function
3. Dict modification - Iterate over copy or use comprehension
4. Division type - Use // for floor division or math.ceil
5. String immutability - Create new string
6. Bytes vs strings - Decode/encode properly
7. Unhashable set elements - Use tuples not lists
8. Empty list access - Check before indexing
9. Float comparison - Use math.isclose()
10. Variable scope - Initialize before try block or use list
11. Key type mismatch - Ensure key types match
12. Slice reference - Understand slicing creates new list
13. Generator exhaustion - Create new generator or use list
14. Boolean comparison - Use truthiness, not == True
15. Closure binding - Use default arguments in lambda
