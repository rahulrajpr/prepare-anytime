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
| 101        | John  |

---

## 3rd Normal Form (3NF)
**Rule:** Must be in 2NF AND no transitive dependencies (no non-key column depends on another non-key column).

### Before 3NF:
**Primary Key:** `CustomerID`
| CustomerID | Name  | ZipCode | City      |
|------------|-------|---------|-----------|
| 101        | John  | 10001   | New York  |
| 102        | Jane  | 10001   | New York  |

**Problem:** **Transitive dependency** - `City` depends on `ZipCode`, and `ZipCode` depends on `CustomerID`. So a non-key column (`City`) depends on another non-key column (`ZipCode`).

### After 3NF:
**Customers Table** (depends only on CustomerID)
| CustomerID | Name  | ZipCode |
|------------|-------|---------|
| 101        | John  | 10001   |
| 102        | Jane  | 10001   |

**ZipCode Table** (depends only on ZipCode)
| ZipCode | City      |
|---------|-----------|
| 10001   | New York  |

---

# Database Normalization - Advanced Examples & Violations

## 1st Normal Form (1NF) Violations & Solutions

### Violation Type 1: Repeating Groups in Single Column
**Before 1NF:**
| CustomerID | Name  | Orders                 |
|------------|-------|------------------------|
| 101        | John  | Pen, Pencil, Notebook  |

**Solution 1: Separate Rows**
| CustomerID | Name  | OrderItem |
|------------|-------|-----------|
| 101        | John  | Pen       |
| 101        | John  | Pencil    |
| 101        | John  | Notebook  |

**Solution 2: Separate Table with Foreign Key**
**Customers Table:**
| CustomerID | Name  |
|------------|-------|
| 101        | John  |

**Orders Table:**
| OrderID | CustomerID | OrderItem |
|---------|------------|-----------|
| 1       | 101        | Pen       |
| 2       | 101        | Pencil    |
| 3       | 101        | Notebook  |

### Violation Type 2: Multiple Contact Methods
**Before 1NF:**
| EmployeeID | Name  | Emails                          | PhoneNumbers        |
|------------|-------|---------------------------------|---------------------|
| 201        | Alice | alice@co.com, a.smith@co.com   | 555-1234, 555-5678 |

**After 1NF - Better Design:**
**Employees Table:**
| EmployeeID | Name  |
|------------|-------|
| 201        | Alice |

**Emails Table:**
| EmailID | EmployeeID | Email           |
|---------|------------|-----------------|
| 1       | 201        | alice@co.com    |
| 2       | 201        | a.smith@co.com  |

**PhoneNumbers Table:**
| PhoneID | EmployeeID | PhoneNumber |
|---------|------------|-------------|
| 1       | 201        | 555-1234    |
| 2       | 201        | 555-5678    |

---

## 2nd Normal Form (2NF) Violations & Solutions

### Violation Type 1: Partial Dependency on Composite Key
**Before 2NF:**
**Primary Key:** `(StudentID, CourseID)`
| StudentID | CourseID | StudentName | CourseTitle | Grade |
|-----------|----------|-------------|-------------|-------|
| 1         | C101     | John        | Math        | A     |
| 1         | C102     | John        | Science     | B     |

**Problem:** `StudentName` depends only on `StudentID`, `CourseTitle` depends only on `CourseID`

**After 2NF - Proper Solution:**
**Enrollments Table:**
| StudentID | CourseID | Grade |
|-----------|----------|-------|
| 1         | C101     | A     |
| 1         | C102     | B     |

**Students Table:**
| StudentID | StudentName |
|-----------|-------------|
| 1         | John        |

**Courses Table:**
| CourseID | CourseTitle |
|----------|-------------|
| C101     | Math        |
| C102     | Science     |

---

## 3rd Normal Form (3NF) Violations & Solutions

### Violation Type 1: Calculated Fields
**Before 3NF:**
| OrderID | ProductID | UnitPrice | Quantity | TotalPrice |
|---------|-----------|-----------|----------|------------|
| 1001    | P001      | 10.00     | 5        | 50.00      |

**Problem:** `TotalPrice` depends on `UnitPrice` and `Quantity` (non-key columns)

**After 3NF:**
| OrderID | ProductID | UnitPrice | Quantity |
|---------|-----------|-----------|----------|
| 1001    | P001      | 10.00     | 5        |

### Violation Type 2: Hierarchical Dependencies
**Before 3NF:**
| EmployeeID | DepartmentID | DeptName  | ManagerID | ManagerName |
|------------|--------------|-----------|-----------|-------------|
| 501        | D01          | Sales     | 601       | Bob         |
| 502        | D01          | Sales     | 601       | Bob         |

**Problem:** `DeptName` depends on `DepartmentID`, `ManagerName` depends on `ManagerID`

**After 3NF:**
**Employees Table:**
| EmployeeID | DepartmentID | ManagerID |
|------------|--------------|-----------|
| 501        | D01          | 601       |
| 502        | D01          | 601       |

**Departments Table:**
| DepartmentID | DeptName | ManagerID |
|--------------|----------|-----------|
| D01          | Sales    | 601       |

**Managers Table:**
| ManagerID | ManagerName |
|-----------|-------------|
| 601       | Bob         |

---

## Advanced Violation Patterns

### Mixed Violation: 1NF + 2NF + 3NF
**Before Normalization:**
| ProjectID | TeamMembers       | Manager   | ManagerPhone |
|-----------|-------------------|-----------|--------------|
| P100      | Alice,Bob,Charlie | David     | 555-9999     |

**Problems:**
- 1NF: `TeamMembers` has repeating groups
- 2NF: `Manager` and `ManagerPhone` don't depend on full key
- 3NF: `ManagerPhone` depends on `Manager`

**After Full Normalization:**
**Projects Table:**
| ProjectID | ManagerID |
|-----------|-----------|
| P100      | M001      |

**ProjectTeam Table:**
| ProjectID | EmployeeID |
|-----------|------------|
| P100      | E001       |
| P100      | E002       |
| P100      | E003       |

**Employees Table:**
| EmployeeID | Name  |
|------------|-------|
| E001       | Alice |
| E002       | Bob   |
| E003       | Charlie |

**Managers Table:**
| ManagerID | Name  | Phone    |
|-----------|-------|----------|
| M001      | David | 555-9999 |

---

## Key Design Principles

### For 1NF:
- Never store comma-separated values
- Use separate tables for multi-valued attributes
- Ensure atomicity in every column

### For 2NF:
- Check composite keys for partial dependencies
- Move attributes that depend on part of key to separate tables
- Ensure all non-key attributes depend on entire primary key

### For 3NF:
- Eliminate calculated fields
- Remove transitive dependencies
- Ensure no non-key attribute depends on another non-key attribute

---

## Summary
- **1NF:** No repeating groups, atomic values
- **2NF:** In 1NF + no partial dependencies (all non-key columns depend on entire primary key)
- **3NF:** In 2NF + no transitive dependencies (no non-key column depends on another non-key attribute)
