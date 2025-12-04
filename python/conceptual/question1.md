# 🐍 Python Interview Questions for Data Engineers

<div align="center">

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Interview](https://img.shields.io/badge/Interview-FF6B6B?style=for-the-badge)
![Data Engineering](https://img.shields.io/badge/Data_Engineering-4CAF50?style=for-the-badge)

</div>

Direct, concise answers to Python interview questions for data engineers.

---

## 📑 Table of Contents

1. [🎯 Core Concepts](#-core-concepts)
2. [💾 Memory & Performance](#-memory--performance)
3. [🔄 Iterators & Generators](#-iterators--generators)
4. [🎨 Advanced Features](#-advanced-features)
5. [⚡ Concurrency](#-concurrency)
6. [💻 Coding Challenges](#-coding-challenges)

---

## 🎯 Core Concepts

### Q1: Difference between `is` and `==`?

**Answer:**
- `==` compares values
- `is` compares object identity (memory location)

```python
a = [1, 2]
b = [1, 2]
a == b  # True
a is b  # False

# Use 'is' only for None, True, False
if x is None:  # ✓
if x == None:  # ✗
```


---

### Q2: Mutable vs Immutable objects?

**Answer:**

**Immutable:** int, float, str, tuple, frozenset - Cannot be changed after creation

**Mutable:** list, dict, set - Can be modified in-place

```python
# Common mistake with default arguments
def add_item(item, items=[]):  # ✗ Wrong - list persists
    items.append(item)
    return items

add_item(1)  # [1]
add_item(2)  # [1, 2] - Unexpected!

# Correct approach
def add_item(item, items=None):  # ✓ Right
    if items is None:
        items = []
    items.append(item)
    return items
```

---

### Q3: What are *args and **kwargs?

**Answer:**

- `*args` - Variable positional arguments (tuple)
- `**kwargs` - Variable keyword arguments (dict)

```python
def func(required, *args, default=10, **kwargs):
    pass

func(1, 2, 3, default=20, extra="value")
# required = 1
# args = (2, 3)
# default = 20
# kwargs = {'extra': 'value'}

# Use case: wrapper functions
def wrapper(*args, **kwargs):
    return original_func(*args, **kwargs)
```

---

### Q4: Explain Python's GIL

**Answer:**

Global Interpreter Lock - Only one thread executes Python bytecode at a time.

**Impact:**
- CPU-bound tasks: Use `multiprocessing` (bypasses GIL)
- I/O-bound tasks: Use `threading` or `asyncio` (GIL released during I/O)

```python
# CPU-bound → multiprocessing
from multiprocessing import Pool
with Pool(4) as p:
    results = p.map(cpu_task, data)

# I/O-bound → threading or asyncio
import asyncio
await asyncio.gather(*[io_task(x) for x in data])
```

---

### Q5: Deep copy vs Shallow copy?

**Answer:**

- **Shallow copy:** Copies top-level only, nested objects are references
- **Deep copy:** Recursively copies all nested objects

```python
import copy

original = [[1, 2], [3, 4]]

shallow = original.copy()
shallow[0][0] = 99
print(original)  # [[99, 2], [3, 4]] - Changed!

deep = copy.deepcopy(original)
deep[0][0] = 88
print(original)  # [[99, 2], [3, 4]] - Unchanged
```

---

### Q6: What is `None` and how to check for it?

**Answer:**

`None` is Python's null value (singleton object).

```python
# Correct
if x is None:  # ✓

# Wrong
if x == None:  # ✗
if not x:      # ✗ (catches 0, [], "", False too)
```

---

### Q7: List vs Tuple vs Set vs Dict?

**Answer:**

| Type | Ordered | Mutable | Duplicates | Use Case |
|------|---------|---------|------------|----------|
| **list** | Yes | Yes | Yes | Ordered collection |
| **tuple** | Yes | No | Yes | Immutable sequence |
| **set** | No | Yes | No | Unique items, fast lookup |
| **dict** | Yes* | Yes | Keys: No | Key-value mapping |

*Ordered since Python 3.7

```python
# Lookup speed
item in my_list    # O(n)
item in my_set     # O(1)
key in my_dict     # O(1)
```

---

## 💾 Memory & Performance

### Q8: How does Python manage memory?

**Answer:**

1. **Reference counting** - Tracks references to objects
2. **Garbage collection** - Cleans up circular references
3. **Memory pools** - Pre-allocated blocks for efficiency

```python
import sys
x = []
sys.getrefcount(x)  # Number of references

# Reduce memory with __slots__
class Normal:
    def __init__(self, x, y):
        self.x = x
        self.y = y

class Optimized:
    __slots__ = ['x', 'y']  # No __dict__, saves ~70% memory
    def __init__(self, x, y):
        self.x = x
        self.y = y
```

---

### Q9: How to optimize memory for large datasets?

**Answer:**

1. Use generators instead of lists
2. Process data in chunks
3. Use appropriate data structures
4. Delete unused references

```python
# Bad - loads all in memory
data = [process(x) for x in range(1000000)]

# Good - lazy evaluation
data = (process(x) for x in range(1000000))

# Process in chunks
def process_chunks(data, chunk_size=1000):
    chunk = []
    for item in data:
        chunk.append(item)
        if len(chunk) >= chunk_size:
            yield chunk
            chunk = []
    if chunk:
        yield chunk
```

---

## 🔄 Iterators & Generators

### Q10: Iterator vs Generator?

**Answer:**

**Iterator:** Object with `__iter__()` and `__next__()` methods

**Generator:** Function with `yield` (automatically creates iterator)

```python
# Iterator (verbose)
class Counter:
    def __init__(self, n):
        self.n = n
        self.i = 0
    
    def __iter__(self):
        return self
    
    def __next__(self):
        if self.i >= self.n:
            raise StopIteration
        self.i += 1
        return self.i

# Generator (simple)
def counter(n):
    for i in range(1, n+1):
        yield i
```

**Use generators:** Memory efficient, simpler code

---

### Q11: When to use generator expressions?

**Answer:**

Use when you iterate **once** over large data.

```python
# List comprehension - all in memory
squares = [x**2 for x in range(1000000)]  # ~8MB

# Generator expression - lazy
squares = (x**2 for x in range(1000000))  # ~128 bytes

# Perfect for single pass
sum(x**2 for x in range(1000000))

# Don't use if you need indexing or multiple passes
gen = (x for x in range(10))
gen[5]  # ✗ Error
list(gen)  # [0,1,2,...9]
list(gen)  # [] - exhausted
```

---

### Q12: Explain `yield` and `yield from`

**Answer:**

**`yield`** - Pauses function, returns value, resumes later

**`yield from`** - Delegates to another generator

```python
# yield
def fibonacci(n):
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b

# yield from
def chain_generators(gens):
    for gen in gens:
        yield from gen  # Same as: for item in gen: yield item

# Data pipeline
def extract(source):
    for item in source:
        yield item

def transform(items):
    for item in items:
        yield item * 2

def load(items):
    return list(items)

# Chain
result = load(transform(extract([1, 2, 3])))
```

---

## 🎨 Advanced Features

### Q13: What are decorators?

**Answer:**

Functions that modify other functions.

```python
# Basic decorator
def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        print(f"{func.__name__}: {time.time()-start:.2f}s")
        return result
    return wrapper

@timer
def slow_function():
    time.sleep(1)

# Decorator with arguments
def retry(times=3):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for i in range(times):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if i == times - 1:
                        raise
        return wrapper
    return decorator

@retry(times=3)
def api_call():
    pass
```

---

### Q14: What are context managers?

**Answer:**

Objects that define `__enter__` and `__exit__` for resource management.

```python
# Using with statement
with open('file.txt') as f:
    data = f.read()
# File closed automatically

# Custom context manager
class DBConnection:
    def __enter__(self):
        self.conn = connect()
        return self.conn
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.conn.close()
        return False  # Don't suppress exceptions

# Using contextlib
from contextlib import contextmanager

@contextmanager
def timer(name):
    start = time.time()
    yield
    print(f"{name}: {time.time()-start:.2f}s")

with timer("Processing"):
    process_data()
```

---

### Q15: Lambda vs Regular function?

**Answer:**

**Lambda:** Single expression, anonymous

**Regular function:** Multiple statements, named

```python
# Lambda
square = lambda x: x**2

# Regular function
def square(x):
    return x**2

# When to use lambda
numbers = [1, 2, 3, 4]
squared = map(lambda x: x**2, numbers)
sorted_by_value = sorted(items, key=lambda x: x['value'])

# Don't use lambda for complex logic
# Bad
process = lambda x: x**2 if x > 0 else -x**2 if x < 0 else 0

# Good
def process(x):
    if x > 0:
        return x**2
    elif x < 0:
        return -x**2
    return 0
```

---

## ⚡ Concurrency

### Q16: Threading vs Multiprocessing vs Asyncio?

**Answer:**

| Method | Best For | GIL Impact | Overhead |
|--------|----------|------------|----------|
| **threading** | I/O-bound | Released during I/O | Low |
| **multiprocessing** | CPU-bound | Bypasses GIL | High |
| **asyncio** | Many concurrent I/O | Single thread | Lowest |

```python
# CPU-bound → multiprocessing
from multiprocessing import Pool
with Pool(4) as p:
    results = p.map(cpu_intensive, data)

# I/O-bound → asyncio
import asyncio
async def fetch(url):
    await aiohttp.get(url)

await asyncio.gather(*[fetch(url) for url in urls])

# Legacy I/O → threading
from concurrent.futures import ThreadPoolExecutor
with ThreadPoolExecutor(10) as executor:
    results = executor.map(blocking_io, items)
```

---

### Q17: How to make thread-safe code?

**Answer:**

Use locks, thread-local storage, or queues.

```python
import threading

# Thread-safe with lock
class Counter:
    def __init__(self):
        self.count = 0
        self.lock = threading.Lock()
    
    def increment(self):
        with self.lock:
            self.count += 1

# Thread-local data
thread_local = threading.local()

def process():
    if not hasattr(thread_local, 'id'):
        thread_local.id = threading.get_ident()
    return thread_local.id

# Queue for communication
from queue import Queue
queue = Queue()

def worker():
    while True:
        item = queue.get()
        process(item)
        queue.task_done()
```

---

### Q18: What is asyncio and when to use it?

**Answer:**

Single-threaded concurrency using event loop. Best for I/O-bound tasks with many concurrent operations.

```python
import asyncio

# Basic async function
async def fetch_data(url):
    await asyncio.sleep(1)  # Non-blocking
    return f"Data from {url}"

# Run multiple concurrently
async def main():
    tasks = [fetch_data(url) for url in urls]
    results = await asyncio.gather(*tasks)
    return results

# Execute
asyncio.run(main())

# When NOT to use
# - CPU-bound tasks (use multiprocessing)
# - Blocking libraries (use threading)
# - Simple scripts (adds complexity)
```

---

## 💻 Coding Challenges

### Challenge 1: Implement LRU Cache

```python
from collections import OrderedDict

class LRUCache:
    def __init__(self, capacity):
        self.cache = OrderedDict()
        self.capacity = capacity
    
    def get(self, key):
        if key not in self.cache:
            return -1
        self.cache.move_to_end(key)
        return self.cache[key]
    
    def put(self, key, value):
        if key in self.cache:
            self.cache.move_to_end(key)
        self.cache[key] = value
        if len(self.cache) > self.capacity:
            self.cache.popitem(last=False)

# Test
cache = LRUCache(2)
cache.put(1, 1)
cache.put(2, 2)
cache.get(1)        # 1
cache.put(3, 3)     # Evicts 2
cache.get(2)        # -1
```

---

### Challenge 2: Find Duplicates in List

```python
# Method 1: Using set - O(n)
def find_duplicates(nums):
    seen = set()
    duplicates = set()
    for num in nums:
        if num in seen:
            duplicates.add(num)
        seen.add(num)
    return list(duplicates)

# Method 2: Using Counter - O(n)
from collections import Counter
def find_duplicates(nums):
    counts = Counter(nums)
    return [num for num, count in counts.items() if count > 1]

# Test
nums = [1, 2, 3, 2, 4, 5, 3]
print(find_duplicates(nums))  # [2, 3]
```

---

### Challenge 3: Flatten Nested List

```python
def flatten(nested_list):
    result = []
    for item in nested_list:
        if isinstance(item, list):
            result.extend(flatten(item))
        else:
            result.append(item)
    return result

# Test
nested = [1, [2, 3, [4, 5]], 6, [7, [8]]]
print(flatten(nested))  # [1, 2, 3, 4, 5, 6, 7, 8]

# Generator version (memory efficient)
def flatten_gen(nested_list):
    for item in nested_list:
        if isinstance(item, list):
            yield from flatten_gen(item)
        else:
            yield item
```

---

### Challenge 4: Group Anagrams

```python
from collections import defaultdict

def group_anagrams(words):
    groups = defaultdict(list)
    for word in words:
        key = ''.join(sorted(word))
        groups[key].append(word)
    return list(groups.values())

# Test
words = ["eat", "tea", "tan", "ate", "nat", "bat"]
print(group_anagrams(words))
# [['eat', 'tea', 'ate'], ['tan', 'nat'], ['bat']]
```

---

### Challenge 5: Rate Limiter

```python
import time
from collections import deque

class RateLimiter:
    def __init__(self, max_requests, window_seconds):
        self.max_requests = max_requests
        self.window = window_seconds
        self.requests = deque()
    
    def allow_request(self):
        now = time.time()
        
        # Remove old requests
        while self.requests and self.requests[0] < now - self.window:
            self.requests.popleft()
        
        # Check limit
        if len(self.requests) < self.max_requests:
            self.requests.append(now)
            return True
        return False

# Test
limiter = RateLimiter(5, 10)  # 5 requests per 10 seconds
for i in range(10):
    print(f"Request {i}: {'✓' if limiter.allow_request() else '✗'}")
```

---

### Challenge 6: Process Large File in Batches

```python
def process_file_batches(filepath, batch_size=1000):
    batch = []
    with open(filepath) as f:
        for line in f:
            batch.append(line.strip())
            if len(batch) >= batch_size:
                yield batch
                batch = []
        if batch:
            yield batch

# Usage
for batch in process_file_batches('large_file.txt', 1000):
    # Process each batch
    results = [transform(line) for line in batch]
    save_to_db(results)
```

---

### Challenge 7: Merge Sorted Lists

```python
def merge_sorted_lists(list1, list2):
    result = []
    i = j = 0
    
    while i < len(list1) and j < len(list2):
        if list1[i] <= list2[j]:
            result.append(list1[i])
            i += 1
        else:
            result.append(list2[j])
            j += 1
    
    result.extend(list1[i:])
    result.extend(list2[j:])
    return result

# Test
list1 = [1, 3, 5, 7]
list2 = [2, 4, 6, 8]
print(merge_sorted_lists(list1, list2))  # [1,2,3,4,5,6,7,8]

# Merge K sorted lists
import heapq
def merge_k_lists(lists):
    return list(heapq.merge(*lists))
```

---

### Challenge 8: Find Missing Number

```python
# Array of 1 to n with one missing
def find_missing(nums):
    n = len(nums) + 1
    expected_sum = n * (n + 1) // 2
    actual_sum = sum(nums)
    return expected_sum - actual_sum

# Test
nums = [1, 2, 4, 5, 6]
print(find_missing(nums))  # 3

# Using XOR (works for duplicates too)
def find_missing_xor(nums):
    xor_all = 0
    for i in range(1, len(nums) + 2):
        xor_all ^= i
    for num in nums:
        xor_all ^= num
    return xor_all
```

---

### Challenge 9: Remove Duplicates from Sorted List

```python
def remove_duplicates(nums):
    if not nums:
        return 0
    
    write = 1
    for read in range(1, len(nums)):
        if nums[read] != nums[read-1]:
            nums[write] = nums[read]
            write += 1
    
    return write  # New length

# Test
nums = [1, 1, 2, 2, 3, 4, 4]
length = remove_duplicates(nums)
print(nums[:length])  # [1, 2, 3, 4]
```

---

### Challenge 10: Implement Stack with Min Operation

```python
class MinStack:
    def __init__(self):
        self.stack = []
        self.min_stack = []
    
    def push(self, val):
        self.stack.append(val)
        if not self.min_stack or val <= self.min_stack[-1]:
            self.min_stack.append(val)
    
    def pop(self):
        if self.stack:
            val = self.stack.pop()
            if val == self.min_stack[-1]:
                self.min_stack.pop()
            return val
    
    def top(self):
        return self.stack[-1] if self.stack else None
    
    def get_min(self):
        return self.min_stack[-1] if self.min_stack else None

# Test - all operations O(1)
stack = MinStack()
stack.push(3)
stack.push(1)
stack.push(2)
print(stack.get_min())  # 1
stack.pop()
print(stack.get_min())  # 1
stack.pop()
print(stack.get_min())  # 3
```

---

## 📚 Quick Tips

### Common Mistakes

```python
# 1. Modifying list while iterating
for item in my_list:
    if condition:
        my_list.remove(item)  # ✗ Skip elements

# Fix
my_list = [item for item in my_list if not condition]

# 2. Using mutable default arguments
def func(items=[]):  # ✗ Shared between calls
    items.append(1)

# Fix
def func(items=None):
    items = items if items is not None else []

# 3. Catching all exceptions
try:
    code()
except:  # ✗ Catches KeyboardInterrupt, SystemExit
    pass

# Fix
except Exception as e:  # ✓ Catches only Exception subclasses
    handle(e)

# 4. Not closing resources
f = open('file.txt')  # ✗ Might not close
data = f.read()

# Fix
with open('file.txt') as f:  # ✓ Always closes
    data = f.read()
```

---

### Time Complexity Cheat Sheet

```python
# List
list.append(x)      # O(1)
list.insert(0, x)   # O(n)
list.pop()          # O(1)
list.pop(0)         # O(n)
x in list           # O(n)

# Dict
dict[key]           # O(1) average
key in dict         # O(1) average
dict.items()        # O(n)

# Set
set.add(x)          # O(1) average
x in set            # O(1) average
set.intersection()  # O(min(len(s), len(t)))

# Sorted operations
sorted(list)        # O(n log n)
list.sort()         # O(n log n)
```

---

<div align="center">

### 🎯 Key Takeaways

**Memory:** Use generators for large data  
**Concurrency:** Choose based on task type (CPU vs I/O)  
**Performance:** Know your data structures' complexity  
**Style:** Clean, readable code beats clever code

</div>

---

*Remember: Explain your thought process during interviews!*
