# Python Search Algorithms on Data Structures

## 1. Linear Search

### Basic Linear Search on List
```python
def linear_search(arr, target):
    """
    Time Complexity: O(n)
    Space Complexity: O(1)
    """
    for i in range(len(arr)):
        if arr[i] == target:
            return i
    return -1

# Test
arr = [64, 34, 25, 12, 22, 11, 90]
print(linear_search(arr, 22))  # Output: 4
```

### Linear Search - All Occurrences
```python
def linear_search_all(arr, target):
    """Find all indices where target appears"""
    indices = []
    for i in range(len(arr)):
        if arr[i] == target:
            indices.append(i)
    return indices if indices else -1

# Test
arr = [1, 3, 5, 3, 7, 3, 9]
print(linear_search_all(arr, 3))  # Output: [1, 3, 5]
```

---

## 2. Binary Search

### Binary Search - Iterative
```python
def binary_search(arr, target):
    """
    Requires: Sorted array
    Time Complexity: O(log n)
    Space Complexity: O(1)
    """
    left, right = 0, len(arr) - 1
    
    while left <= right:
        mid = left + (right - left) // 2  # Prevents overflow
        
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return -1

# Test
arr = [2, 5, 8, 12, 16, 23, 38, 45, 56, 67, 78]
print(binary_search(arr, 23))  # Output: 5
```

### Binary Search - Recursive
```python
def binary_search_recursive(arr, target, left=0, right=None):
    """
    Time Complexity: O(log n)
    Space Complexity: O(log n) - due to recursion stack
    """
    if right is None:
        right = len(arr) - 1
    
    if left > right:
        return -1
    
    mid = left + (right - left) // 2
    
    if arr[mid] == target:
        return mid
    elif arr[mid] < target:
        return binary_search_recursive(arr, target, mid + 1, right)
    else:
        return binary_search_recursive(arr, target, left, mid - 1)

# Test
arr = [2, 5, 8, 12, 16, 23, 38, 45, 56, 67, 78]
print(binary_search_recursive(arr, 23))  # Output: 5
```

### Binary Search - Find First/Last Occurrence
```python
def binary_search_first(arr, target):
    """Find first occurrence of target"""
    left, right = 0, len(arr) - 1
    result = -1
    
    while left <= right:
        mid = left + (right - left) // 2
        
        if arr[mid] == target:
            result = mid
            right = mid - 1  # Continue searching in left half
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return result

def binary_search_last(arr, target):
    """Find last occurrence of target"""
    left, right = 0, len(arr) - 1
    result = -1
    
    while left <= right:
        mid = left + (right - left) // 2
        
        if arr[mid] == target:
            result = mid
            left = mid + 1  # Continue searching in right half
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return result

# Test
arr = [1, 2, 2, 2, 3, 4, 5, 5, 5, 6]
print(binary_search_first(arr, 5))  # Output: 6
print(binary_search_last(arr, 5))   # Output: 8
```

---

## 3. Hash Table (Dictionary) Search

### Basic Dictionary Search
```python
def hash_search(hash_table, key):
    """
    Time Complexity: O(1) average case
    Space Complexity: O(1)
    """
    return hash_table.get(key, -1)

# Test
data = {'apple': 100, 'banana': 75, 'orange': 90}
print(hash_search(data, 'banana'))  # Output: 75
print(hash_search(data, 'grape'))   # Output: -1
```

### Search with Multiple Keys (Nested Dict)
```python
def nested_dict_search(data, keys):
    """Search through nested dictionary using list of keys"""
    current = data
    for key in keys:
        if isinstance(current, dict) and key in current:
            current = current[key]
        else:
            return None
    return current

# Test
data = {
    'users': {
        'john': {
            'age': 30,
            'city': 'NYC'
        }
    }
}
print(nested_dict_search(data, ['users', 'john', 'age']))  # Output: 30
```

---

## 4. Set Search

### Basic Set Membership
```python
def set_search(data_set, target):
    """
    Time Complexity: O(1) average case
    Space Complexity: O(1)
    """
    return target in data_set

# Test
numbers = {1, 5, 10, 15, 20, 25, 30}
print(set_search(numbers, 15))  # Output: True
print(set_search(numbers, 17))  # Output: False
```

---

## 5. Search in Linked List (Custom Implementation)

### Singly Linked List Search
```python
class Node:
    def __init__(self, data):
        self.data = data
        self.next = None

class LinkedList:
    def __init__(self):
        self.head = None
    
    def append(self, data):
        new_node = Node(data)
        if not self.head:
            self.head = new_node
            return
        current = self.head
        while current.next:
            current = current.next
        current.next = new_node
    
    def search(self, target):
        """
        Time Complexity: O(n)
        Space Complexity: O(1)
        """
        current = self.head
        position = 0
        
        while current:
            if current.data == target:
                return position
            current = current.next
            position += 1
        
        return -1

# Test
ll = LinkedList()
for val in [10, 20, 30, 40, 50]:
    ll.append(val)

print(ll.search(30))  # Output: 2
print(ll.search(60))  # Output: -1
```

---

## 6. Search in Binary Search Tree

### BST Search
```python
class TreeNode:
    def __init__(self, val):
        self.val = val
        self.left = None
        self.right = None

def bst_search(root, target):
    """
    Time Complexity: O(h) where h is height
    - O(log n) for balanced tree
    - O(n) for skewed tree
    Space Complexity: O(1) iterative, O(h) recursive
    """
    current = root
    
    while current:
        if current.val == target:
            return True
        elif target < current.val:
            current = current.left
        else:
            current = current.right
    
    return False

def bst_search_recursive(root, target):
    """Recursive version"""
    if not root:
        return False
    
    if root.val == target:
        return True
    elif target < root.val:
        return bst_search_recursive(root.left, target)
    else:
        return bst_search_recursive(root.right, target)

# Test
#       10
#      /  \
#     5    15
#    / \   / \
#   3   7 12  20

root = TreeNode(10)
root.left = TreeNode(5)
root.right = TreeNode(15)
root.left.left = TreeNode(3)
root.left.right = TreeNode(7)
root.right.left = TreeNode(12)
root.right.right = TreeNode(20)

print(bst_search(root, 7))   # Output: True
print(bst_search(root, 13))  # Output: False
```

---

## 7. Jump Search

### Jump Search on Sorted Array
```python
import math

def jump_search(arr, target):
    """
    Requires: Sorted array
    Time Complexity: O(√n)
    Space Complexity: O(1)
    """
    n = len(arr)
    step = int(math.sqrt(n))
    prev = 0
    
    # Find block where element may be present
    while arr[min(step, n) - 1] < target:
        prev = step
        step += int(math.sqrt(n))
        if prev >= n:
            return -1
    
    # Linear search in the identified block
    while arr[prev] < target:
        prev += 1
        if prev == min(step, n):
            return -1
    
    # If element is found
    if arr[prev] == target:
        return prev
    
    return -1

# Test
arr = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610]
print(jump_search(arr, 55))  # Output: 10
```

---

## 8. Interpolation Search

### Interpolation Search
```python
def interpolation_search(arr, target):
    """
    Requires: Sorted array with uniformly distributed values
    Time Complexity: O(log log n) average, O(n) worst case
    Space Complexity: O(1)
    """
    low = 0
    high = len(arr) - 1
    
    while low <= high and target >= arr[low] and target <= arr[high]:
        if low == high:
            if arr[low] == target:
                return low
            return -1
        
        # Probe position
        pos = low + ((target - arr[low]) * (high - low) // 
                     (arr[high] - arr[low]))
        
        if arr[pos] == target:
            return pos
        
        if arr[pos] < target:
            low = pos + 1
        else:
            high = pos - 1
    
    return -1

# Test
arr = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
print(interpolation_search(arr, 70))  # Output: 6
```

---

## 9. Search in 2D Matrix

### Search in Row-wise and Column-wise Sorted Matrix
```python
def search_2d_matrix(matrix, target):
    """
    Search in matrix where:
    - Each row is sorted left to right
    - Each column is sorted top to bottom
    Time Complexity: O(m + n)
    Space Complexity: O(1)
    """
    if not matrix or not matrix[0]:
        return False
    
    rows, cols = len(matrix), len(matrix[0])
    row, col = 0, cols - 1  # Start from top-right
    
    while row < rows and col >= 0:
        if matrix[row][col] == target:
            return True
        elif matrix[row][col] > target:
            col -= 1  # Move left
        else:
            row += 1  # Move down
    
    return False

# Test
matrix = [
    [1,  4,  7,  11],
    [2,  5,  8,  12],
    [3,  6,  9,  16],
    [10, 13, 14, 17]
]
print(search_2d_matrix(matrix, 5))   # Output: True
print(search_2d_matrix(matrix, 20))  # Output: False
```

---

## 10. Practical Coding Problems

### Problem 1: Find Peak Element
```python
def find_peak_element(nums):
    """
    Find a peak element (greater than neighbors)
    Time Complexity: O(log n)
    Space Complexity: O(1)
    """
    left, right = 0, len(nums) - 1
    
    while left < right:
        mid = left + (right - left) // 2
        
        if nums[mid] > nums[mid + 1]:
            right = mid  # Peak is in left half
        else:
            left = mid + 1  # Peak is in right half
    
    return left

# Test
print(find_peak_element([1, 2, 3, 1]))        # Output: 2
print(find_peak_element([1, 2, 1, 3, 5, 6, 4]))  # Output: 5
```

### Problem 2: Search in Rotated Sorted Array
```python
def search_rotated_array(nums, target):
    """
    Time Complexity: O(log n)
    Space Complexity: O(1)
    """
    left, right = 0, len(nums) - 1
    
    while left <= right:
        mid = left + (right - left) // 2
        
        if nums[mid] == target:
            return mid
        
        # Determine which half is sorted
        if nums[left] <= nums[mid]:  # Left half is sorted
            if nums[left] <= target < nums[mid]:
                right = mid - 1
            else:
                left = mid + 1
        else:  # Right half is sorted
            if nums[mid] < target <= nums[right]:
                left = mid + 1
            else:
                right = mid - 1
    
    return -1

# Test
nums = [4, 5, 6, 7, 0, 1, 2]
print(search_rotated_array(nums, 0))  # Output: 4
print(search_rotated_array(nums, 3))  # Output: -1
```

### Problem 3: Find Minimum in Rotated Sorted Array
```python
def find_min_rotated(nums):
    """
    Time Complexity: O(log n)
    Space Complexity: O(1)
    """
    left, right = 0, len(nums) - 1
    
    while left < right:
        mid = left + (right - left) // 2
        
        if nums[mid] > nums[right]:
            left = mid + 1
        else:
            right = mid
    
    return nums[left]

# Test
print(find_min_rotated([3, 4, 5, 1, 2]))  # Output: 1
print(find_min_rotated([4, 5, 6, 7, 0, 1, 2]))  # Output: 0
```

---

## Time Complexity Comparison

| Algorithm | Best Case | Average Case | Worst Case | Space |
|-----------|-----------|--------------|------------|-------|
| Linear Search | O(1) | O(n) | O(n) | O(1) |
| Binary Search | O(1) | O(log n) | O(log n) | O(1) |
| Jump Search | O(1) | O(√n) | O(√n) | O(1) |
| Interpolation | O(1) | O(log log n) | O(n) | O(1) |
| Hash Table | O(1) | O(1) | O(n) | O(n) |
| BST Search | O(1) | O(log n) | O(n) | O(1) |

---

## When to Use Which Algorithm

1. **Linear Search**: Small arrays, unsorted data, or when you need to find all occurrences
2. **Binary Search**: Sorted arrays, frequently searched data
3. **Hash Table**: O(1) lookup needed, memory available, unique keys
4. **BST**: Dynamic data, need sorted order, range queries
5. **Jump Search**: Large sorted arrays, better than linear but simpler than binary
6. **Interpolation**: Uniformly distributed sorted data
