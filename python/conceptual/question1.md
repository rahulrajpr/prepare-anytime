# 🐍 Python Interview Questions for Data Engineers

<div align="center">

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Interview](https://img.shields.io/badge/Interview-FF6B6B?style=for-the-badge)
![Data Engineering](https://img.shields.io/badge/Data_Engineering-4CAF50?style=for-the-badge)

</div>

Essential Python conceptual questions and coding challenges for data engineering interviews.

---

## 📑 Table of Contents

1. [🎯 Core Python Concepts](#-core-python-concepts)
2. [💾 Memory Management](#-memory-management)
3. [🔄 Iterators & Generators](#-iterators--generators)
4. [🎨 Decorators & Context Managers](#-decorators--context-managers)
5. [⚡ Concurrency & Parallelism](#-concurrency--parallelism)
6. [💻 Coding Challenges](#-coding-challenges)
7. [🔍 Debugging & Best Practices](#-debugging--best-practices)

---

## 🎯 Core Python Concepts

### Q1: What is the difference between `is` and `==`?

**Answer:**

```python
# == checks for value equality
# is checks for identity (same object in memory)

a = [1, 2, 3]
b = [1, 2, 3]
c = a

print(a == b)  # True (same values)
print(a is b)  # False (different objects)
print(a is c)  # True (same object)

# Small integers are cached
x = 256
y = 256
print(x is y)  # True (Python caches small integers)

x = 257
y = 257
print(x is y)  # False (not cached)
```

**Key Point:** Use `==` for value comparison, `is` for identity (commonly used with `None`).

---

### Q2: Explain mutable vs immutable objects with examples

**Answer:**

```python
# Immutable: int, float, str, tuple, frozenset, bool
x = 10
print(id(x))
x = 20  # Creates new object, doesn't modify original
print(id(x))  # Different memory address

# Mutable: list, dict, set
my_list = [1, 2, 3]
print(id(my_list))
my_list.append(4)  # Modifies in-place
print(id(my_list))  # Same memory address

# Common gotcha with default arguments
def append_to_list(item, target_list=[]):  # ❌ WRONG
    target_list.append(item)
    return target_list

print(append_to_list(1))  # [1]
print(append_to_list(2))  # [1, 2] - Unexpected!

# Correct approach
def append_to_list(item, target_list=None):  # ✅ CORRECT
    if target_list is None:
        target_list = []
    target_list.append(item)
    return target_list
```

---

### Q3: What are *args and **kwargs? When would you use them?

**Answer:**

```python
# *args: Variable number of positional arguments
def sum_numbers(*args):
    return sum(args)

print(sum_numbers(1, 2, 3))  # 6
print(sum_numbers(1, 2, 3, 4, 5))  # 15

# **kwargs: Variable number of keyword arguments
def print_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

print_info(name="John", age=30, city="NYC")

# Combined usage (order matters: positional, *args, **kwargs)
def complex_function(required, *args, default=10, **kwargs):
    print(f"Required: {required}")
    print(f"Args: {args}")
    print(f"Default: {default}")
    print(f"Kwargs: {kwargs}")

complex_function(1, 2, 3, default=20, extra="value")

# Real-world use case: Wrapper functions
def logged_function(func):
    def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__}")
        result = func(*args, **kwargs)
        print(f"Result: {result}")
        return result
    return wrapper

@logged_function
def add(a, b):
    return a + b
```

**Use Cases:**
- API wrappers
- Decorators
- Function overloading
- Configuration functions

---

### Q4: Explain Python's GIL (Global Interpreter Lock)

**Answer:**

The GIL is a mutex that protects access to Python objects, preventing multiple threads from executing Python bytecode simultaneously.

```python
import threading
import time

# Example showing GIL impact
counter = 0

def increment():
    global counter
    for _ in range(1000000):
        counter += 1

# Multi-threaded (limited by GIL)
threads = []
start = time.time()
for _ in range(2):
    t = threading.Thread(target=increment)
    threads.append(t)
    t.start()

for t in threads:
    t.join()

print(f"Multi-threaded time: {time.time() - start}")
print(f"Counter: {counter}")  # May not be 2000000 due to race conditions

# For CPU-bound tasks, use multiprocessing instead
from multiprocessing import Process, Value

def increment_mp(counter):
    for _ in range(1000000):
        counter.value += 1

if __name__ == '__main__':
    counter = Value('i', 0)
    processes = []
    start = time.time()
    
    for _ in range(2):
        p = Process(target=increment_mp, args=(counter,))
        processes.append(p)
        p.start()
    
    for p in processes:
        p.join()
    
    print(f"Multi-process time: {time.time() - start}")
    print(f"Counter: {counter.value}")
```

**Key Points:**
- **CPU-bound tasks**: Use `multiprocessing` (bypasses GIL)
- **I/O-bound tasks**: Use `threading` or `asyncio` (GIL released during I/O)
- **Data engineering**: Often use multiprocessing for parallel data processing

---

### Q5: What is the difference between deep copy and shallow copy?

**Answer:**

```python
import copy

# Shallow copy
original = [[1, 2, 3], [4, 5, 6]]
shallow = copy.copy(original)
shallow[0][0] = 999

print(original)  # [[999, 2, 3], [4, 5, 6]] - Modified!
print(shallow)   # [[999, 2, 3], [4, 5, 6]]

# Deep copy
original = [[1, 2, 3], [4, 5, 6]]
deep = copy.deepcopy(original)
deep[0][0] = 999

print(original)  # [[1, 2, 3], [4, 5, 6]] - Unchanged
print(deep)      # [[999, 2, 3], [4, 5, 6]]

# Common methods
list1 = [1, 2, 3]
list2 = list1        # Assignment (same object)
list3 = list1[:]     # Shallow copy
list4 = list1.copy() # Shallow copy
list5 = list(list1)  # Shallow copy

# Data Engineering use case: Config copying
config = {
    'database': {
        'host': 'localhost',
        'port': 5432
    },
    'timeout': 30
}

# Shallow copy won't work for nested config
config_dev = config.copy()
config_dev['database']['host'] = 'dev-server'
print(config['database']['host'])  # 'dev-server' - Unexpected!

# Use deepcopy for nested structures
config_prod = copy.deepcopy(config)
config_prod['database']['host'] = 'prod-server'
print(config['database']['host'])  # Still 'localhost'
```

---

## 💾 Memory Management

### Q6: How does Python's memory management work?

**Answer:**

```python
import sys

# Reference counting
a = []
print(sys.getrefcount(a))  # 2 (one for 'a', one for getrefcount)

b = a
print(sys.getrefcount(a))  # 3 (added 'b')

del b
print(sys.getrefcount(a))  # 2 (removed 'b')

# Garbage collection for circular references
import gc

class Node:
    def __init__(self, value):
        self.value = value
        self.next = None

# Circular reference
node1 = Node(1)
node2 = Node(2)
node1.next = node2
node2.next = node1

# Even after deleting, memory isn't freed immediately
del node1, node2

# Force garbage collection
gc.collect()

# Check what's in garbage
print(gc.get_count())  # (threshold0, threshold1, threshold2)

# Memory-efficient data structures
# Use __slots__ for memory optimization
class RegularClass:
    def __init__(self, x, y):
        self.x = x
        self.y = y

class OptimizedClass:
    __slots__ = ['x', 'y']  # No __dict__, less memory
    def __init__(self, x, y):
        self.x = x
        self.y = y

# Memory comparison
regular = RegularClass(1, 2)
optimized = OptimizedClass(1, 2)

print(sys.getsizeof(regular.__dict__))  # ~240 bytes
print(sys.getsizeof(optimized))         # ~64 bytes
```

**Key Points:**
- Python uses reference counting + garbage collection
- `__slots__` reduces memory for classes with fixed attributes
- Important for data engineering when processing millions of records

---

### Q7: What are weak references and when to use them?

**Answer:**

```python
import weakref

class DataProcessor:
    def __init__(self, data):
        self.data = data
    
    def process(self):
        return f"Processing {len(self.data)} items"

# Regular reference
processor = DataProcessor([1, 2, 3])
print(processor.process())

# Weak reference (doesn't prevent garbage collection)
weak_processor = weakref.ref(processor)
print(weak_processor().process())  # Access via weak_processor()

# After deleting strong reference
del processor
print(weak_processor())  # None - object was garbage collected

# Use case: Caching without preventing cleanup
class CachedDataManager:
    def __init__(self):
        self._cache = weakref.WeakValueDictionary()
    
    def get_processor(self, key, data):
        if key not in self._cache:
            self._cache[key] = DataProcessor(data)
        return self._cache[key]

manager = CachedDataManager()
p1 = manager.get_processor('key1', [1, 2, 3])
print(len(manager._cache))  # 1

# When p1 goes out of scope, cache entry is automatically removed
del p1
import gc
gc.collect()
print(len(manager._cache))  # 0
```

---

## 🔄 Iterators & Generators

### Q8: What's the difference between an iterator and a generator?

**Answer:**

```python
# Iterator: Object with __iter__ and __next__
class CountIterator:
    def __init__(self, max_count):
        self.max_count = max_count
        self.count = 0
    
    def __iter__(self):
        return self
    
    def __next__(self):
        if self.count >= self.max_count:
            raise StopIteration
        self.count += 1
        return self.count

# Usage
counter = CountIterator(3)
for num in counter:
    print(num)  # 1, 2, 3

# Generator: Function with yield (creates iterator automatically)
def count_generator(max_count):
    count = 0
    while count < max_count:
        count += 1
        yield count

# Usage
for num in count_generator(3):
    print(num)  # 1, 2, 3

# Generator expression (memory efficient)
squares = (x**2 for x in range(1000000))  # Lazy evaluation
print(next(squares))  # 0
print(next(squares))  # 1

# List comprehension (loads all in memory)
squares_list = [x**2 for x in range(1000000)]  # All computed immediately
```

**Data Engineering Use Case:**

```python
# Bad: Loads entire file in memory
def read_large_file_bad(filepath):
    with open(filepath) as f:
        return f.readlines()  # All lines in memory

# Good: Generator for memory efficiency
def read_large_file_good(filepath):
    with open(filepath) as f:
        for line in f:
            yield line.strip()

# Process large file line by line
def process_log_file(filepath):
    for line in read_large_file_good(filepath):
        if 'ERROR' in line:
            yield line

# Chain generators
errors = process_log_file('app.log')
for error in errors:
    print(error)
```

---

### Q9: Explain `yield`, `yield from`, and when to use them

**Answer:**

```python
# yield: Pause and resume function
def fibonacci(n):
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b

for num in fibonacci(5):
    print(num)  # 0, 1, 1, 2, 3

# yield from: Delegate to sub-generator
def read_files(filenames):
    for filename in filenames:
        with open(filename) as f:
            yield from f  # Equivalent to: for line in f: yield line

# More complex example
def flatten(nested_list):
    for item in nested_list:
        if isinstance(item, list):
            yield from flatten(item)  # Recursive
        else:
            yield item

data = [1, [2, 3, [4, 5]], 6]
print(list(flatten(data)))  # [1, 2, 3, 4, 5, 6]

# Data pipeline example
def extract_data(source):
    """Extract raw data"""
    for record in source:
        yield record

def transform_data(records):
    """Transform records"""
    for record in records:
        yield {'id': record['id'], 'value': record['value'] * 2}

def load_data(records, destination):
    """Load to destination"""
    for record in records:
        destination.append(record)
        yield record

# Chain the pipeline
source_data = [{'id': 1, 'value': 10}, {'id': 2, 'value': 20}]
destination = []

pipeline = load_data(
    transform_data(
        extract_data(source_data)
    ),
    destination
)

# Execute pipeline
for _ in pipeline:
    pass

print(destination)  # [{'id': 1, 'value': 20}, {'id': 2, 'value': 40}]
```

---

### Q10: What are generator expressions and when to use them over list comprehensions?

**Answer:**

```python
import sys

# List comprehension: All in memory
list_comp = [x**2 for x in range(1000000)]
print(f"List size: {sys.getsizeof(list_comp)} bytes")  # ~8MB

# Generator expression: Lazy evaluation
gen_exp = (x**2 for x in range(1000000))
print(f"Generator size: {sys.getsizeof(gen_exp)} bytes")  # ~128 bytes

# Use cases
# 1. Processing large datasets
def process_large_dataset(data_iterator):
    # Memory efficient
    processed = (transform(item) for item in data_iterator if filter_condition(item))
    return processed

# 2. Chaining operations
numbers = range(1000000)
result = sum(x**2 for x in numbers if x % 2 == 0)  # Never creates full list

# 3. Infinite sequences
def infinite_counter():
    n = 0
    while True:
        yield n
        n += 1

# Take first 10 from infinite sequence
first_10 = [next(infinite_counter()) for _ in range(10)]

# Comparison: sum of squares
import time

# List comprehension
start = time.time()
sum([x**2 for x in range(1000000)])
print(f"List comp: {time.time() - start:.4f}s")

# Generator expression
start = time.time()
sum(x**2 for x in range(1000000))
print(f"Generator: {time.time() - start:.4f}s")  # Slightly faster, way less memory
```

**Rule of Thumb:**
- Use **list comprehension** when you need to iterate multiple times or index
- Use **generator expression** for single-pass iteration or large datasets

---

## 🎨 Decorators & Context Managers

### Q11: Explain decorators and write a timing decorator

**Answer:**

```python
import time
from functools import wraps

# Basic decorator
def timing_decorator(func):
    @wraps(func)  # Preserves original function metadata
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start:.4f} seconds")
        return result
    return wrapper

@timing_decorator
def slow_function():
    time.sleep(1)
    return "Done"

slow_function()

# Decorator with arguments
def retry(max_attempts=3, delay=1):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    print(f"Attempt {attempt + 1} failed: {e}")
                    time.sleep(delay)
        return wrapper
    return decorator

@retry(max_attempts=3, delay=0.5)
def unreliable_api_call():
    import random
    if random.random() < 0.7:
        raise ConnectionError("API unavailable")
    return "Success"

# Class-based decorator
class CountCalls:
    def __init__(self, func):
        self.func = func
        self.count = 0
    
    def __call__(self, *args, **kwargs):
        self.count += 1
        print(f"Call {self.count} to {self.func.__name__}")
        return self.func(*args, **kwargs)

@CountCalls
def process_data(data):
    return len(data)

process_data([1, 2, 3])
process_data([1, 2, 3, 4])
print(f"Total calls: {process_data.count}")

# Real-world data engineering decorator
def validate_schema(expected_keys):
    def decorator(func):
        @wraps(func)
        def wrapper(data, *args, **kwargs):
            if not all(key in data for key in expected_keys):
                raise ValueError(f"Missing required keys: {expected_keys}")
            return func(data, *args, **kwargs)
        return wrapper
    return decorator

@validate_schema(['id', 'name', 'email'])
def process_user(data):
    return f"Processing user: {data['name']}"

# This works
process_user({'id': 1, 'name': 'John', 'email': 'john@example.com'})

# This raises ValueError
# process_user({'id': 1, 'name': 'John'})
```

---

### Q12: What are context managers and how to create custom ones?

**Answer:**

```python
# Using with statement
with open('file.txt', 'w') as f:
    f.write('Hello')
# File automatically closed

# Custom context manager - Class approach
class DatabaseConnection:
    def __init__(self, connection_string):
        self.connection_string = connection_string
        self.connection = None
    
    def __enter__(self):
        print(f"Connecting to {self.connection_string}")
        self.connection = f"Connection to {self.connection_string}"
        return self.connection
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        print(f"Closing connection")
        if exc_type is not None:
            print(f"Exception occurred: {exc_val}")
        # Return True to suppress exception, False to propagate
        return False

with DatabaseConnection("postgresql://localhost") as conn:
    print(f"Using {conn}")
    # Exception handling is automatic

# Custom context manager - Generator approach
from contextlib import contextmanager

@contextmanager
def timer(name):
    start = time.time()
    print(f"Starting {name}")
    try:
        yield  # This is where the with block executes
    finally:
        print(f"{name} took {time.time() - start:.4f} seconds")

with timer("Data processing"):
    time.sleep(1)
    # Do work here

# Real-world example: Transaction manager
@contextmanager
def transaction(connection):
    """Context manager for database transactions"""
    try:
        yield connection
        connection.commit()
        print("Transaction committed")
    except Exception as e:
        connection.rollback()
        print(f"Transaction rolled back: {e}")
        raise

# Usage
class MockConnection:
    def commit(self):
        print("Committing...")
    
    def rollback(self):
        print("Rolling back...")
    
    def execute(self, query):
        print(f"Executing: {query}")

conn = MockConnection()
with transaction(conn):
    conn.execute("INSERT INTO users VALUES (1, 'John')")
    conn.execute("INSERT INTO orders VALUES (1, 100)")

# Multiple context managers
with open('input.txt', 'r') as infile, \
     open('output.txt', 'w') as outfile:
    for line in infile:
        outfile.write(line.upper())
```

---

## ⚡ Concurrency & Parallelism

### Q13: Explain threading vs multiprocessing vs asyncio

**Answer:**

```python
import threading
import multiprocessing
import asyncio
import time

# 1. Threading (I/O-bound tasks)
def io_task(n):
    print(f"Task {n} starting")
    time.sleep(1)  # Simulates I/O
    print(f"Task {n} done")

# Threading example
def run_with_threads():
    threads = []
    start = time.time()
    
    for i in range(5):
        t = threading.Thread(target=io_task, args=(i,))
        threads.append(t)
        t.start()
    
    for t in threads:
        t.join()
    
    print(f"Threading: {time.time() - start:.2f}s")  # ~1s (parallel I/O)

# 2. Multiprocessing (CPU-bound tasks)
def cpu_task(n):
    result = sum(i * i for i in range(1000000))
    return result

def run_with_multiprocessing():
    start = time.time()
    
    with multiprocessing.Pool(processes=4) as pool:
        results = pool.map(cpu_task, range(8))
    
    print(f"Multiprocessing: {time.time() - start:.2f}s")

# 3. Asyncio (I/O-bound tasks, single thread)
async def async_io_task(n):
    print(f"Async task {n} starting")
    await asyncio.sleep(1)  # Non-blocking sleep
    print(f"Async task {n} done")
    return n

async def run_with_asyncio():
    start = time.time()
    
    tasks = [async_io_task(i) for i in range(5)]
    results = await asyncio.gather(*tasks)
    
    print(f"Asyncio: {time.time() - start:.2f}s")  # ~1s (concurrent)
    return results

# Run examples
run_with_threads()
run_with_multiprocessing()
asyncio.run(run_with_asyncio())
```

**When to Use What:**

| Use Case | Solution | Reason |
|----------|----------|--------|
| CPU-bound (calculations) | `multiprocessing` | Bypasses GIL |
| I/O-bound (file, network) | `asyncio` or `threading` | GIL released during I/O |
| Many concurrent I/O | `asyncio` | Most efficient, single thread |
| Legacy blocking I/O | `threading` | When asyncio not available |

---

### Q14: Implement a thread-safe counter

**Answer:**

```python
import threading

# Not thread-safe
class UnsafeCounter:
    def __init__(self):
        self.count = 0
    
    def increment(self):
        self.count += 1  # Not atomic!

# Thread-safe with Lock
class SafeCounter:
    def __init__(self):
        self.count = 0
        self.lock = threading.Lock()
    
    def increment(self):
        with self.lock:
            self.count += 1
    
    def get_count(self):
        with self.lock:
            return self.count

# Test unsafe counter
unsafe = UnsafeCounter()
threads = []
for _ in range(10):
    t = threading.Thread(target=lambda: [unsafe.increment() for _ in range(1000)])
    threads.append(t)
    t.start()

for t in threads:
    t.join()

print(f"Unsafe counter: {unsafe.count}")  # Often less than 10000

# Test safe counter
safe = SafeCounter()
threads = []
for _ in range(10):
    t = threading.Thread(target=lambda: [safe.increment() for _ in range(1000)])
    threads.append(t)
    t.start()

for t in threads:
    t.join()

print(f"Safe counter: {safe.get_count()}")  # Always 10000

# Alternative: Using threading.local for thread-specific data
thread_local = threading.local()

def process_data():
    if not hasattr(thread_local, 'counter'):
        thread_local.counter = 0
    thread_local.counter += 1
    return thread_local.counter

# Each thread has its own counter
threads = []
for _ in range(5):
    t = threading.Thread(target=lambda: print(process_data()))
    threads.append(t)
    t.start()

for t in threads:
    t.join()
```

---

## 💻 Coding Challenges

### Challenge 1: Implement LRU Cache

**Question:** Implement a Least Recently Used (LRU) cache with O(1) get and put operations.

**Answer:**

```python
from collections import OrderedDict

class LRUCache:
    def __init__(self, capacity):
        self.cache = OrderedDict()
        self.capacity = capacity
    
    def get(self, key):
        if key not in self.cache:
            return -1
        # Move to end (most recently used)
        self.cache.move_to_end(key)
        return self.cache[key]
    
    def put(self, key, value):
        if key in self.cache:
            # Update and move to end
            self.cache.move_to_end(key)
        self.cache[key] = value
        
        if len(self.cache) > self.capacity:
            # Remove least recently used (first item)
            self.cache.popitem(last=False)

# Test
cache = LRUCache(2)
cache.put(1, 1)
cache.put(2, 2)
print(cache.get(1))       # 1
cache.put(3, 3)           # Evicts key 2
print(cache.get(2))       # -1 (not found)
cache.put(4, 4)           # Evicts key 1
print(cache.get(1))       # -1 (not found)
print(cache.get(3))       # 3
print(cache.get(4))       # 4

# Alternative: Manual implementation with dict + doubly linked list
class Node:
    def __init__(self, key, value):
        self.key = key
        self.value = value
        self.prev = None
        self.next = None

class LRUCacheManual:
    def __init__(self, capacity):
        self.capacity = capacity
        self.cache = {}
        self.head = Node(0, 0)  # Dummy head
        self.tail = Node(0, 0)  # Dummy tail
        self.head.next = self.tail
        self.tail.prev = self.head
    
    def _remove(self, node):
        """Remove node from linked list"""
        prev_node = node.prev
        next_node = node.next
        prev_node.next = next_node
        next_node.prev = prev_node
    
    def _add_to_end(self, node):
        """Add node to end (most recent)"""
        prev_node = self.tail.prev
        prev_node.next = node
        node.prev = prev_node
        node.next = self.tail
        self.tail.prev = node
    
    def get(self, key):
        if key not in self.cache:
            return -1
        
        node = self.cache[key]
        self._remove(node)
        self._add_to_end(node)
        return node.value
    
    def put(self, key, value):
        if key in self.cache:
            self._remove(self.cache[key])
        
        node = Node(key, value)
        self._add_to_end(node)
        self.cache[key] = node
        
        if len(self.cache) > self.capacity:
            # Remove least recently used (after head)
            lru = self.head.next
            self._remove(lru)
            del self.cache[lru.key]
```

---

### Challenge 2: Find Duplicate Files

**Question:** Given a list of file paths, group files with identical content.

**Answer:**

```python
import hashlib
from collections import defaultdict

def find_duplicate_files(paths):
    """
    Group files by content hash
    
    Args:
        paths: List of file paths
    
    Returns:
        List of lists, each containing paths of duplicate files
    """
    hash_to_paths = defaultdict(list)
    
    for path in paths:
        # Calculate hash
        file_hash = get_file_hash(path)
        hash_to_paths[file_hash].append(path)
    
    # Return only groups with duplicates
    return [paths for paths in hash_to_paths.values() if len(paths) > 1]

def get_file_hash(filepath, chunk_size=8192):
    """Calculate MD5 hash of file"""
    hasher = hashlib.md5()
    
    try:
        with open(filepath, 'rb') as f:
            while chunk := f.read(chunk_size):
                hasher.update(chunk)
    except FileNotFoundError:
        return None
    
    return hasher.hexdigest()

# Optimized version: Check size first
def find_duplicate_files_optimized(paths):
    """
    Optimized: Group by size first, then by hash
    """
    import os
    
    # Step 1: Group by file size
    size_to_paths = defaultdict(list)
    for path in paths:
        try:
            size = os.path.getsize(path)
            size_to_paths[size].append(path)
        except OSError:
            continue
    
    # Step 2: For groups with same size, check hash
    duplicates = []
    for paths_with_same_size in size_to_paths.values():
        if len(paths_with_same_size) < 2:
            continue
        
        hash_to_paths = defaultdict(list)
        for path in paths_with_same_size:
            file_hash = get_file_hash(path)
            if file_hash:
                hash_to_paths[file_hash].append(path)
        
        for paths in hash_to_paths.values():
            if len(paths) > 1:
                duplicates.append(paths)
    
    return duplicates

# Test
files = [
    'file1.txt',
    'file2.txt',
    'file3.txt',  # Duplicate of file1.txt
]
duplicates = find_duplicate_files_optimized(files)
print(duplicates)
```

---

### Challenge 3: Parse Nested JSON

**Question:** Flatten a nested JSON structure.

**Answer:**

```python
def flatten_json(nested_json, parent_key='', sep='_'):
    """
    Flatten nested JSON/dict
    
    Input: {'a': 1, 'b': {'c': 2, 'd': {'e': 3}}}
    Output: {'a': 1, 'b_c': 2, 'b_d_e': 3}
    """
    items = []
    
    for key, value in nested_json.items():
        new_key = f"{parent_key}{sep}{key}" if parent_key else key
        
        if isinstance(value, dict):
            # Recursively flatten
            items.extend(flatten_json(value, new_key, sep=sep).items())
        elif isinstance(value, list):
            # Handle lists
            for i, item in enumerate(value):
                if isinstance(item, dict):
                    items.extend(flatten_json(item, f"{new_key}{sep}{i}", sep=sep).items())
                else:
                    items.append((f"{new_key}{sep}{i}", item))
        else:
            items.append((new_key, value))
    
    return dict(items)

# Test
nested = {
    'user': {
        'id': 1,
        'name': 'John',
        'address': {
            'city': 'NYC',
            'zip': '10001'
        }
    },
    'orders': [
        {'id': 1, 'total': 100},
        {'id': 2, 'total': 200}
    ]
}

flattened = flatten_json(nested)
print(flattened)
# {
#     'user_id': 1,
#     'user_name': 'John',
#     'user_address_city': 'NYC',
#     'user_address_zip': '10001',
#     'orders_0_id': 1,
#     'orders_0_total': 100,
#     'orders_1_id': 2,
#     'orders_1_total': 200
# }

# Reverse: Unflatten
def unflatten_json(flat_json, sep='_'):
    """
    Unflatten a flat JSON/dict
    """
    nested = {}
    
    for key, value in flat_json.items():
        parts = key.split(sep)
        current = nested
        
        for part in parts[:-1]:
            # Check if part is numeric (list index)
            if part.isdigit():
                part = int(part)
                if not isinstance(current, list):
                    current = []
                # Extend list if needed
                while len(current) <= part:
                    current.append({})
                current = current[part]
            else:
                if part not in current:
                    current[part] = {}
                current = current[part]
        
        # Set final value
        final_key = parts[-1]
        if final_key.isdigit():
            final_key = int(final_key)
        current[final_key] = value
    
    return nested
```

---

### Challenge 4: Rate Limiter

**Question:** Implement a rate limiter that allows N requests per time window.

**Answer:**

```python
import time
from collections import deque
from threading import Lock

class RateLimiter:
    def __init__(self, max_requests, time_window):
        """
        Args:
            max_requests: Maximum requests allowed
            time_window: Time window in seconds
        """
        self.max_requests = max_requests
        self.time_window = time_window
        self.requests = deque()
        self.lock = Lock()
    
    def allow_request(self):
        """
        Check if request is allowed
        
        Returns:
            bool: True if allowed, False otherwise
        """
        with self.lock:
            current_time = time.time()
            
            # Remove old requests outside time window
            while self.requests and self.requests[0] < current_time - self.time_window:
                self.requests.popleft()
            
            # Check if under limit
            if len(self.requests) < self.max_requests:
                self.requests.append(current_time)
                return True
            
            return False
    
    def wait_time(self):
        """Get wait time until next request is allowed"""
        with self.lock:
            if len(self.requests) < self.max_requests:
                return 0
            
            oldest_request = self.requests[0]
            wait = self.time_window - (time.time() - oldest_request)
            return max(0, wait)

# Test
limiter = RateLimiter(max_requests=5, time_window=10)  # 5 requests per 10 seconds

for i in range(10):
    if limiter.allow_request():
        print(f"Request {i+1}: Allowed")
    else:
        wait = limiter.wait_time()
        print(f"Request {i+1}: Rate limited. Wait {wait:.2f}s")
    time.sleep(0.5)

# Token bucket algorithm (alternative)
class TokenBucket:
    def __init__(self, capacity, refill_rate):
        """
        Args:
            capacity: Max tokens
            refill_rate: Tokens per second
        """
        self.capacity = capacity
        self.tokens = capacity
        self.refill_rate = refill_rate
        self.last_refill = time.time()
        self.lock = Lock()
    
    def consume(self, tokens=1):
        """Try to consume tokens"""
        with self.lock:
            self._refill()
            
            if self.tokens >= tokens:
                self.tokens -= tokens
                return True
            return False
    
    def _refill(self):
        """Refill tokens based on time passed"""
        now = time.time()
        time_passed = now - self.last_refill
        tokens_to_add = time_passed * self.refill_rate
        
        self.tokens = min(self.capacity, self.tokens + tokens_to_add)
        self.last_refill = now

# Test
bucket = TokenBucket(capacity=10, refill_rate=1)  # 1 token per second

for i in range(15):
    if bucket.consume():
        print(f"Request {i+1}: Allowed ({bucket.tokens:.1f} tokens left)")
    else:
        print(f"Request {i+1}: Rate limited")
    time.sleep(0.5)
```

---

### Challenge 5: Process Data in Batches

**Question:** Process a large dataset in batches efficiently.

**Answer:**

```python
def batch_processor(items, batch_size):
    """
    Process items in batches
    
    Args:
        items: Iterable of items
        batch_size: Size of each batch
    
    Yields:
        List of items in each batch
    """
    batch = []
    for item in items:
        batch.append(item)
        if len(batch) >= batch_size:
            yield batch
            batch = []
    
    # Don't forget last partial batch
    if batch:
        yield batch

# Usage
data = range(1, 101)  # 100 items

for batch in batch_processor(data, batch_size=10):
    print(f"Processing batch of {len(batch)} items: {batch[:3]}...")

# More efficient version using itertools
from itertools import islice

def batch_processor_efficient(iterable, batch_size):
    """Memory efficient batch processor"""
    iterator = iter(iterable)
    while batch := list(islice(iterator, batch_size)):
        yield batch

# Process generator (no loading all in memory)
def generate_data():
    for i in range(1000000):
        yield i

for batch in batch_processor_efficient(generate_data(), 1000):
    # Process each batch
    total = sum(batch)

# Real-world: Process file in chunks
def process_file_in_batches(filepath, batch_size=1000):
    """Read and process file in batches"""
    batch = []
    
    with open(filepath, 'r') as f:
        for line in f:
            batch.append(line.strip())
            
            if len(batch) >= batch_size:
                yield batch
                batch = []
        
        if batch:
            yield batch

# Usage
for batch in process_file_in_batches('large_file.txt', 1000):
    # Process batch
    processed_data = [line.upper() for line in batch]
    # Write to output, database, etc.
```

---

## 🔍 Debugging & Best Practices

### Q15: How would you debug memory leaks in Python?

**Answer:**

```python
import gc
import sys
from pympler import tracker

# 1. Track object growth
tr = tracker.SummaryTracker()

def create_objects():
    data = [list(range(1000)) for _ in range(100)]
    return data

data = create_objects()
tr.print_diff()  # Shows what grew

# 2. Find reference cycles
gc.set_debug(gc.DEBUG_SAVEALL)
gc.collect()
print(f"Garbage: {len(gc.garbage)}")

for obj in gc.garbage:
    print(type(obj), sys.getrefcount(obj))

# 3. Profile memory usage
from memory_profiler import profile

@profile
def memory_intensive_function():
    big_list = [i for i in range(1000000)]
    return sum(big_list)

# 4. Common memory leak patterns

# Leak: Global cache never cleared
_cache = {}  # ❌ Grows forever

def process_with_cache(key, value):
    _cache[key] = value

# Fix: Use weakref or limit cache size
import weakref
_cache = weakref.WeakValueDictionary()

# Or use lru_cache with maxsize
from functools import lru_cache

@lru_cache(maxsize=128)
def expensive_function(n):
    return n ** 2

# Leak: Circular references
class Node:
    def __init__(self, value):
        self.value = value
        self.children = []  # ❌ Can create cycles
        self.parent = None

# Fix: Use weak references
class Node:
    def __init__(self, value):
        self.value = value
        self.children = []
        self._parent = None
    
    @property
    def parent(self):
        return self._parent() if self._parent else None
    
    @parent.setter
    def parent(self, node):
        self._parent = weakref.ref(node) if node else None
```

---

### Q16: What are Python best practices for data engineering?

**Answer:**

```python
# 1. Use type hints
from typing import List, Dict, Optional, Iterator

def process_records(records: List[Dict[str, any]]) -> Iterator[Dict[str, any]]:
    """Process records and yield transformed data"""
    for record in records:
        if record.get('is_valid'):
            yield transform_record(record)

def transform_record(record: Dict[str, any]) -> Dict[str, any]:
    return {
        'id': record['id'],
        'value': float(record['value']) * 2
    }

# 2. Use generators for large datasets
def read_large_csv(filepath: str) -> Iterator[Dict[str, str]]:
    """Read CSV file line by line"""
    import csv
    with open(filepath, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            yield row

# 3. Proper error handling
class DataValidationError(Exception):
    """Custom exception for data validation"""
    pass

def validate_record(record: Dict) -> None:
    required_fields = ['id', 'name', 'email']
    
    for field in required_fields:
        if field not in record:
            raise DataValidationError(f"Missing required field: {field}")
    
    if not isinstance(record['id'], int):
        raise DataValidationError(f"Invalid type for id: {type(record['id'])}")

# 4. Use context managers for resources
from contextlib import contextmanager

@contextmanager
def database_connection(connection_string):
    conn = create_connection(connection_string)
    try:
        yield conn
    finally:
        conn.close()

# 5. Logging over print
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def process_data(data):
    logger.info(f"Processing {len(data)} records")
    try:
        result = transform_data(data)
        logger.info(f"Successfully processed {len(result)} records")
        return result
    except Exception as e:
        logger.error(f"Error processing data: {e}", exc_info=True)
        raise

# 6. Configuration management
from dataclasses import dataclass
from typing import Optional

@dataclass
class DatabaseConfig:
    host: str
    port: int
    database: str
    user: str
    password: str
    pool_size: int = 5
    timeout: int = 30

# 7. Testing
import unittest

class TestDataProcessor(unittest.TestCase):
    def test_transform_record(self):
        record = {'id': 1, 'value': '10'}
        result = transform_record(record)
        self.assertEqual(result['value'], 20.0)
    
    def test_validate_record_missing_field(self):
        record = {'id': 1, 'name': 'John'}
        with self.assertRaises(DataValidationError):
            validate_record(record)

# 8. Use pathlib for file paths
from pathlib import Path

data_dir = Path(__file__).parent / 'data'
input_file = data_dir / 'input.csv'

if input_file.exists():
    process_file(input_file)
```

---

## 📚 Quick Reference

### Common Patterns

```python
# 1. Singleton pattern
class Singleton:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

# 2. Factory pattern
class DataSourceFactory:
    @staticmethod
    def create(source_type, config):
        if source_type == 'csv':
            return CSVDataSource(config)
        elif source_type == 'json':
            return JSONDataSource(config)
        else:
            raise ValueError(f"Unknown source type: {source_type}")

# 3. Builder pattern
class QueryBuilder:
    def __init__(self):
        self.query = []
    
    def select(self, *fields):
        self.query.append(f"SELECT {', '.join(fields)}")
        return self
    
    def from_table(self, table):
        self.query.append(f"FROM {table}")
        return self
    
    def where(self, condition):
        self.query.append(f"WHERE {condition}")
        return self
    
    def build(self):
        return ' '.join(self.query)

# Usage
query = (QueryBuilder()
         .select('id', 'name')
         .from_table('users')
         .where('age > 18')
         .build())
```

---

<div align="center">

### 🎯 Interview Tips

![Tip 1](https://img.shields.io/badge/💡_Explain_Trade--offs-Time_vs_Space-4CAF50?style=for-the-badge)
![Tip 2](https://img.shields.io/badge/💡_Consider_Scale-Think_Big_Data-2196F3?style=for-the-badge)
![Tip 3](https://img.shields.io/badge/💡_Write_Clean_Code-Readable_&_Maintainable-9C27B0?style=for-the-badge)

</div>

---

*Remember: Good code is code that's easy to understand, maintain, and debug!*
