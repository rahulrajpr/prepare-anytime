# 🐍 Python Conceptual Questions for Data Engineers

<div align="center">

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Concepts](https://img.shields.io/badge/Concepts-FF6B6B?style=for-the-badge)

</div>

Clear, direct conceptual answers without unnecessary code.

---

## 🎯 Core Concepts

### Q1: What is the difference between `is` and `==`?

**Answer:**
- `==` checks if values are equal
- `is` checks if two variables point to the same object in memory
- Use `is` only for `None`, `True`, `False`
- Small integers (-5 to 256) are cached, so `is` may work but shouldn't be used

---

### Q2: What are mutable and immutable objects?

**Answer:**

**Immutable:** Cannot be changed after creation
- Types: int, float, str, tuple, frozenset, bool
- When you "modify" them, Python creates a new object

**Mutable:** Can be changed in-place
- Types: list, dict, set
- Changes happen to the same object in memory

**Key Issue:** Never use mutable objects as default arguments. The same object is reused across function calls.

---

### Q3: What is the GIL?

**Answer:**

The Global Interpreter Lock is a mutex that allows only one thread to execute Python bytecode at a time.

**Impact:**
- Multi-threading doesn't help with CPU-bound tasks
- Use multiprocessing for CPU-bound work (bypasses GIL)
- Use threading or asyncio for I/O-bound work (GIL is released during I/O)

**Real World:** If you're processing data calculations, use multiprocessing. If you're making API calls, use asyncio or threading.

---

### Q4: What are iterators and generators?

**Answer:**

**Iterator:**
- Any object with `__iter__()` and `__next__()` methods
- Can be looped over once
- Raises `StopIteration` when exhausted

**Generator:**
- A function that uses `yield` instead of `return`
- Automatically creates an iterator
- Pauses execution and resumes where it left off
- Memory efficient - produces items one at a time

**Use generators for:** Processing large files, data streams, or any time you don't need all data in memory at once.

---

### Q5: What is the difference between deep copy and shallow copy?

**Answer:**

**Shallow copy:**
- Copies the outer container
- Inner objects are references to the same objects
- Changes to nested objects affect both copies

**Deep copy:**
- Recursively copies all nested objects
- Creates completely independent copies
- Changes don't affect the original

**When to use:** Use shallow copy for simple objects. Use deep copy for nested structures like configs, complex data structures.

---

### Q6: What are decorators?

**Answer:**

A decorator is a function that takes another function and extends its behavior without modifying it.

**Common uses:**
- Timing function execution
- Logging
- Authentication/authorization
- Caching results
- Retry logic

**Syntax:** The `@decorator_name` above a function applies the decorator.

---

### Q7: What are context managers?

**Answer:**

Objects that manage resources (files, connections, locks) using the `with` statement.

**Purpose:**
- Automatically acquire and release resources
- Guarantee cleanup even if errors occur
- Used for files, database connections, locks

**How it works:**
- `__enter__()` runs when entering the `with` block
- `__exit__()` runs when leaving (even on exception)

---

### Q8: What is `*args` and `**kwargs`?

**Answer:**

**`*args`:**
- Collects extra positional arguments into a tuple
- Lets you pass any number of arguments

**`**kwargs`:**
- Collects extra keyword arguments into a dict
- Lets you pass any number of named arguments

**Order matters:** positional args, `*args`, keyword args, `**kwargs`

**Used for:** Wrapper functions, APIs that accept flexible arguments, forwarding calls.

---

### Q9: Explain threading vs multiprocessing vs asyncio

**Answer:**

| Approach | Best For | How It Works | Overhead |
|----------|----------|--------------|----------|
| **Threading** | I/O-bound (files, network) | Multiple threads, one process | Low |
| **Multiprocessing** | CPU-bound (calculations) | Multiple processes, separate memory | High |
| **Asyncio** | Many I/O operations | Single thread, cooperative multitasking | Lowest |

**Choose:**
- CPU-intensive work → multiprocessing
- Database/API calls → asyncio
- File I/O with blocking libraries → threading

---

### Q10: What is Python's memory management?

**Answer:**

Python uses two mechanisms:

**1. Reference Counting:**
- Each object has a counter tracking how many references point to it
- When count reaches 0, memory is freed immediately

**2. Garbage Collection:**
- Handles circular references (A points to B, B points to A)
- Runs periodically to clean up unreachable objects

**Optimization tip:** Use `__slots__` in classes to reduce memory by 70% when creating millions of instances.

---

### Q11: What are list comprehensions and when to use them?

**Answer:**

Compact syntax for creating lists from iterables.

**When to use:**
- Transforming data
- Filtering data
- Simple operations

**When NOT to use:**
- Complex logic (use regular loops)
- Multiple nested levels (hard to read)
- When you need generator (use generator expression instead)

**Memory:** List comprehensions create the entire list in memory. Generator expressions are lazy and memory-efficient.

---

### Q12: What is the difference between `@staticmethod` and `@classmethod`?

**Answer:**

**`@staticmethod`:**
- Regular function inside a class
- No access to class or instance
- Used for utility functions related to the class

**`@classmethod`:**
- Receives the class as first argument (cls)
- Can access and modify class state
- Used for factory methods, alternative constructors

---

### Q13: What are lambda functions?

**Answer:**

Anonymous single-expression functions.

**Use for:**
- Simple operations (sorting keys, mapping)
- Short-lived functions
- Callbacks

**Don't use for:**
- Complex logic
- Multiple statements
- When you need to reuse the function

**Limitation:** Can only contain a single expression, no statements.

---

### Q14: What is the difference between `__str__` and `__repr__`?

**Answer:**

**`__str__`:**
- Human-readable string representation
- Used by `print()` and `str()`
- For end users

**`__repr__`:**
- Unambiguous representation for developers
- Used by `repr()` and interactive console
- Should ideally be valid Python code to recreate the object

**Best practice:** Always implement `__repr__`, implement `__str__` only if needed.

---

### Q15: What are Python's scope rules (LEGB)?

**Answer:**

Python searches for variables in this order:

**L** - Local: Inside current function
**E** - Enclosing: Inside outer functions
**G** - Global: Module level
**B** - Built-in: Python built-ins

**Important:** If you want to modify a global variable inside a function, use the `global` keyword. For enclosing scope, use `nonlocal`.

---

### Q16: What is the difference between `append()` and `extend()`?

**Answer:**

**`append()`:**
- Adds a single element to the end
- Element added as-is (even if it's a list)

**`extend()`:**
- Adds all elements from an iterable
- Unpacks the iterable and adds each item

---

### Q17: What are Python's data types and their use cases?

**Answer:**

| Type | Ordered | Mutable | Duplicates | Lookup Speed |
|------|---------|---------|------------|--------------|
| **list** | Yes | Yes | Yes | O(n) |
| **tuple** | Yes | No | Yes | O(n) |
| **set** | No | Yes | No | O(1) |
| **dict** | Yes* | Yes | Keys: No | O(1) |

*Ordered since Python 3.7

**Use:**
- **list**: Ordered collection, need to modify
- **tuple**: Immutable sequence, dictionary keys, function returns
- **set**: Unique items, membership testing, remove duplicates
- **dict**: Key-value mapping, fast lookups

---

### Q18: What is duck typing?

**Answer:**

"If it walks like a duck and quacks like a duck, it's a duck."

Python doesn't check the type of an object, only whether it has the required methods/attributes.

**Benefit:** Flexible, allows polymorphism without inheritance

**Example:** Any object with `__iter__` and `__next__` can be used as an iterator, regardless of its class.

---

### Q19: What is the difference between `break`, `continue`, and `pass`?

**Answer:**

**`break`:**
- Exits the loop entirely
- Skips remaining iterations

**`continue`:**
- Skips current iteration
- Continues with next iteration

**`pass`:**
- Does nothing
- Placeholder for empty code blocks

---

### Q20: What are Python's private and protected members?

**Answer:**

Python has no true private members, only conventions:

**Public:** `name` - Accessible everywhere

**Protected:** `_name` (single underscore)
- Convention: Don't access from outside
- Still accessible

**Private:** `__name` (double underscore)
- Name mangling: becomes `_ClassName__name`
- Harder to access accidentally
- Still not truly private

**Best practice:** Use single underscore for internal use, double underscore rarely.

---

### Q21: What is the purpose of `if __name__ == "__main__"`?

**Answer:**

Checks if the script is being run directly (not imported).

**Purpose:**
- Code inside only runs when script is executed
- Doesn't run when imported as a module
- Allows module to be both library and script

**Essential for:** Scripts that should also be importable modules.

---

### Q22: What are Python's exception handling best practices?

**Answer:**

**1. Catch specific exceptions:** Not `Exception` or bare `except`
**2. Don't silence errors:** Log or re-raise
**3. Use `finally` for cleanup:** Or better, use context managers
**4. Don't use exceptions for control flow:** Too slow
**5. Raise meaningful exceptions:** Custom exception classes for your domain

---

### Q23: What is monkey patching?

**Answer:**

Dynamically modifying a class or module at runtime.

**Use cases:**
- Testing (mocking)
- Hot-fixing third-party libraries
- Adding features to existing code

**Risks:**
- Hard to debug
- Can break unexpectedly
- Avoid in production code

---

### Q24: What is the difference between `@property` and attributes?

**Answer:**

**Regular attribute:**
- Direct access to value
- No control over getting/setting

**`@property`:**
- Looks like attribute but runs a method
- Can validate, compute, or log on access
- Can make read-only properties
- Can lazily compute expensive values

**Use when:** You need control over attribute access without changing the interface.

---

### Q25: What are metaclasses?

**Answer:**

Classes that create classes. "The class of a class."

**Normal flow:** object → instance of class → class
**Metaclass flow:** class → instance of metaclass

**Use cases:**
- ORM frameworks (Django models)
- Automatically register classes
- API frameworks
- Validation of class definitions

**Warning:** 99% of developers never need metaclasses. If you're not sure you need one, you don't.

---

## 💾 Memory & Performance

### Q26: How do you optimize Python code for performance?

**Answer:**

**1. Use appropriate data structures:**
- Set for membership tests (not list)
- Dict for lookups (not list of tuples)
- Deque for queue operations (not list)

**2. Use generators for large data:**
- Don't load everything in memory
- Process items one at a time

**3. Use built-in functions:**
- They're written in C, much faster
- `sum()`, `min()`, `max()`, etc.

**4. Avoid repeated calculations:**
- Cache results
- Move invariants out of loops

**5. Use `__slots__` for many instances:**
- Reduces memory by 70%
- Only for classes with fixed attributes

**6. Profile before optimizing:**
- Use `cProfile` to find bottlenecks
- Optimize the slow parts, not everything

---

### Q27: What causes memory leaks in Python?

**Answer:**

Python has automatic memory management, but leaks can still happen:

**Common causes:**
1. **Circular references with `__del__`**: Prevents garbage collection
2. **Global caches that grow forever**: No eviction policy
3. **Closure capturing large objects**: Function keeps reference
4. **C extensions not releasing memory**: Native code leaks

**Prevention:**
- Use weak references for caches
- Implement cache size limits
- Avoid `__del__` if possible
- Use context managers for resources

---

### Q28: What is the difference between `yield` and `return`?

**Answer:**

**`return`:**
- Exits function completely
- Returns a value
- Function state is lost

**`yield`:**
- Pauses function
- Returns a value
- Function state is preserved
- Can be resumed
- Creates a generator

**Use yield when:** You want to produce a sequence of values lazily without storing them all in memory.

---

## 🔄 Advanced Concepts

### Q29: What is the difference between composition and inheritance?

**Answer:**

**Inheritance:** "is-a" relationship
- Car is a Vehicle
- Can lead to tight coupling
- Deep hierarchies are hard to maintain

**Composition:** "has-a" relationship
- Car has an Engine
- More flexible
- Easier to test and modify

**Modern preference:** Favor composition over inheritance. Use inheritance only for true "is-a" relationships.

---

### Q30: What are Abstract Base Classes (ABC)?

**Answer:**

Classes that cannot be instantiated and force subclasses to implement specific methods.

**Purpose:**
- Define interfaces
- Ensure subclasses implement required methods
- Document the contract

**Use when:** You want to define an interface that multiple classes must implement.

---

### Q31: What is method resolution order (MRO)?

**Answer:**

The order Python searches for methods in a class hierarchy (especially with multiple inheritance).

**Rule:** C3 linearization algorithm
- Depth-first, left-to-right
- Parent before grandparent
- Order preserving

**See MRO:** `ClassName.__mro__` or `ClassName.mro()`

**Why it matters:** Understanding which method gets called in complex inheritance.

---

### Q32: What are descriptors?

**Answer:**

Objects that define how attribute access is handled through special methods:
- `__get__`
- `__set__`
- `__delete__`

**Examples of descriptors:**
- `@property`
- `@classmethod`
- `@staticmethod`

**Use cases:**
- Lazy loading
- Type checking
- Logging access
- Computed properties

**Advanced topic:** Most developers use properties instead.

---

### Q33: What is the difference between pickling and JSON?

**Answer:**

**Pickle:**
- Python-specific binary format
- Can serialize almost any Python object
- Not human-readable
- Security risk (can execute code)
- Faster

**JSON:**
- Text format, language-agnostic
- Only basic types (dict, list, str, int, float, bool, None)
- Human-readable
- Safe
- Slower
- Works across languages

**Use pickle for:** Python-to-Python, complex objects
**Use JSON for:** APIs, configuration, cross-language

---

### Q34: What are Python's async/await keywords?

**Answer:**

Syntax for writing asynchronous code that looks like synchronous code.

**`async def`:** Defines a coroutine (async function)
**`await`:** Pauses execution until async operation completes

**Benefits:**
- Single-threaded concurrency
- Efficient for I/O-bound operations
- No race conditions
- Lighter than threads

**Use for:** Network requests, database queries, file I/O - anything that waits.

---

### Q35: What is the Global Interpreter Lock (GIL) problem?

**Answer:**

The GIL prevents true parallel execution of Python bytecode in a single process.

**Problem:**
- Multi-core CPUs can't be fully utilized with threads
- Threading doesn't speed up CPU-bound code

**Solutions:**
1. **Multiprocessing:** Separate processes, each with own GIL
2. **Async I/O:** Single thread, concurrent I/O
3. **C extensions:** Release GIL for computations
4. **Use PyPy or other implementations:** Some don't have GIL

**Data engineering impact:** Large datasets need multiprocessing for parallel processing.

---

## 🎯 Data Engineering Specific

### Q36: How do you handle large files in Python?

**Answer:**

**Never:** Load entire file into memory

**Always:**
1. Read line by line (files are iterators)
2. Use generators to process
3. Process in chunks
4. Use streaming libraries for specific formats

**For CSVs:** Use `csv.DictReader` which reads line by line
**For JSON:** Use `ijson` for streaming large files
**For Parquet:** Use `pyarrow` with chunking

---

### Q37: What's the difference between synchronous and asynchronous code?

**Answer:**

**Synchronous:**
- One task completes before next starts
- Blocking
- Simple to understand
- Wastes time waiting

**Asynchronous:**
- Start multiple tasks without waiting
- Non-blocking
- More complex
- Efficient for I/O

**Real world:** Downloading 100 files synchronously takes 100x the time. Asynchronously, they download concurrently.

---

### Q38: What are Python's built-in data structures time complexities?

**Answer:**

**List:**
- Access by index: O(1)
- Search: O(n)
- Insert/Delete at end: O(1)
- Insert/Delete at beginning: O(n)

**Dict/Set:**
- Access/Insert/Delete: O(1) average
- Search: O(1) average

**Important:** Choose the right structure. Using list for membership testing is a common performance mistake.

---

### Q39: What is the difference between processes and threads?

**Answer:**

**Process:**
- Independent memory space
- Higher overhead
- True parallelism
- Safe from each other
- Communication requires IPC

**Thread:**
- Shared memory space
- Lower overhead
- Concurrent but not parallel (due to GIL)
- Can interfere with each other
- Easy communication

**Data engineering:** Use processes for heavy computation, threads for I/O coordination.

---

### Q40: How does Python garbage collection work?

**Answer:**

**Two mechanisms:**

**1. Reference Counting (primary):**
- Every object tracks how many references point to it
- Immediate cleanup when count hits zero
- Fast and deterministic

**2. Generational Garbage Collection (backup):**
- Handles circular references
- Three generations (0, 1, 2)
- Objects that survive move to older generation
- Older generations checked less frequently

**Manual control:** Can disable/enable, force collection, or tune thresholds.

---

## 📚 Quick Interview Tips

### How to Answer Conceptual Questions:

**1. Start with the definition**
- Be precise and concise

**2. Explain why it exists**
- What problem does it solve?

**3. When to use it**
- Give real-world context

**4. Common pitfalls**
- Show you understand the gotchas

**5. Keep it brief**
- 30-60 seconds per answer
- Let them ask follow-ups

---

### Common Follow-up Questions:

**"When would you use X over Y?"**
- Focus on trade-offs
- Mention performance, readability, maintainability

**"What are the gotchas?"**
- Show real-world experience
- Mention common mistakes

**"Can you give an example?"**
- Keep it simple
- Focus on the concept, not syntax

---

<div align="center">

### 🎯 Key Takeaways

**Know the 'why':** Understand why features exist
**Know the trade-offs:** Everything has pros and cons  
**Keep it practical:** Relate to data engineering work  
**Be honest:** Say "I don't know" if you don't

</div>

---

*Focus on concepts, not syntax. Interviewers want to know you understand how Python works, not if you've memorized the documentation.*
