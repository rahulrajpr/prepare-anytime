# Database Cardinality

## Relationship Cardinality

### 1:1 (One-to-One)
- One instance of Entity A relates to exactly one instance of Entity B
- **Example:** Person ←→ Social Security Number

### 1:M (One-to-Many)
- One instance of Entity A relates to many instances of Entity B
- **Example:** Department ←→ Employees

### M:M (Many-to-Many)
- Many instances of Entity A relate to many instances of Entity B
- Requires junction/intersection table
- **Example:** Students ←→ Courses

---

## Minimum and Maximum Cardinality

### Minimum Cardinality (Participation)
- **0 = Optional** (Zero or one)
- **1 = Mandatory** (Exactly one)

### Maximum Cardinality
- **1 = Single** (At most one)
- **N = Many** (Zero or more)

### Notation: (min, max)
- **(1,1)** = Mandatory, single
- **(0,1)** = Optional, single  
- **(1,N)** = Mandatory, many
- **(0,N)** = Optional, many

---

## Cardinality Types

### Identification Cardinality
- Determines if child entity's identity depends on parent
- **Identifying:** Child's PK includes parent's PK
- **Non-identifying:** Child has independent PK

### Existence Cardinality
- **Mandatory:** Must participate in relationship
- **Optional:** May or may not participate

---

## Examples in Crow's Foot Notation

### 1:1 Mandatory
[EMPLOYEE] ||——|| [PARKING_SPOT]

text

### 1:M Optional to Mandatory
[DEPARTMENT] ||——|< [EMPLOYEE]

text

### M:M with Junction Table
[STUDENT] ||——|< [ENROLLMENT] >|——|| [COURSE]

text

### Optional Participation
[CUSTOMER] |o——|| [ORDER]

text

### Mandatory Participation  
[EMPLOYEE] ||——|| [SALARY]

text

---

## Key Points
- **Minimum = 0** → Optional participation
- **Minimum = 1** → Mandatory participation
- **Maximum = 1** → Single occurrence
- **Maximum = N** → Multiple occurrences
- Cardinality defines business rules between entities
markdown
# Database Normalization (1NF, 2NF, 3NF)

## 1st Normal Form (1NF)
**Rule:** Eliminate repeating groups. Each cell must have a single, atomic value.

### Before 1NF:
| CustomerID | Name  | Orders                 |
|------------|-------|------------------------|
| 101        | John  | Pen, Pencil, Notebook  |

### After 1NF:
| CustomerID | Name  | OrderItem |
|------------|-------|-----------|
| 101        | John  | Pen       |
| 101        | John  | Pencil    |
| 101        | John  | Notebook  |

---

## 2nd Normal Form (2NF)
**Rule:** Must be in 1NF AND every non-key column depends on the **entire** primary key.

### Before 2NF:
**Primary Key:** `(CustomerID, OrderItem)`
| CustomerID | OrderItem | Name  | Price |
|------------|-----------|-------|-------|
| 101        | Pen       | John  | 2.00  |
| 101        | Pencil    | John  | 1.50  |

**Problem:** `Name` only depends on `CustomerID`, not the entire key.

### After 2NF:
**Orders Table** (depends on the full key)
| CustomerID | OrderItem | Price |
|------------|-----------|-------|
| 101        | Pen       | 2.00  |
| 101        | Pencil    | 1.50  |

**Customers Table** (depends only on CustomerID)
| CustomerID | Name  |
|------------|-------|
|

Continue

