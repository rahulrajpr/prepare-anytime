# Strong Entities vs Weak Entities

## Strong Entity

### What is a Strong Entity?

A strong entity is an entity that can exist independently in a database without depending on any other entity. It has its own unique identifier (primary key) that distinguishes each instance.

### Characteristics of Strong Entity

- **Independent existence** - Can exist without any other entity
- **Own primary key** - Has a unique identifier from its own attributes
- **Represented by single rectangle** in ER diagrams
- **Self-sufficient** - Does not rely on another entity for identification

### Example: Employee Entity
```sql
-- STRONG ENTITY
Employee (EmployeeID, Name, Email, Department, Salary)
```

**Employee Table:**
| EmployeeID | Name    | Email              | Department | Salary |
|------------|---------|-------------------|------------|--------|
| E001       | John    | john@company.com  | IT         | 75000  |
| E002       | Sarah   | sarah@company.com | HR         | 65000  |
| E003       | Michael | mike@company.com  | Sales      | 70000  |

**Key Points:**
- EmployeeID is the primary key
- Each employee can exist independently
- No dependency on other entities for identification

---

## Weak Entity

### What is a Weak Entity?

A weak entity is an entity that cannot exist independently and depends on a strong entity (owner entity) for its existence and identification. It does not have a sufficient set of attributes to form a primary key on its own.

### Characteristics of Weak Entity

- **Dependent existence** - Cannot exist without its owner/parent entity
- **Partial key (Discriminator)** - Has attributes that partially identify it
- **Foreign key required** - Must reference the owner entity
- **Represented by double rectangle** in ER diagrams
- **Relationship shown with double diamond** in ER diagrams

### Example: Employee-Dependent Relationship
```sql
-- STRONG ENTITY
Employee (EmployeeID, Name, Email, Department)

-- WEAK ENTITY
Dependent (EmployeeID, DependentName, Relationship, DateOfBirth)
-- Composite Primary Key: (EmployeeID + DependentName)
```

**Employee Table (Strong Entity):**
| EmployeeID | Name    | Email              | Department |
|------------|---------|-------------------|------------|
| E001       | John    | john@company.com  | IT         |
| E002       | Sarah   | sarah@company.com | HR         |

**Dependent Table (Weak Entity):**
| EmployeeID | DependentName | Relationship | DateOfBirth |
|------------|---------------|--------------|-------------|
| E001       | Emma Smith    | Daughter     | 2015-03-20  |
| E001       | Liam Smith    | Son          | 2018-07-15  |
| E002       | Oliver Jones  | Son          | 2016-11-10  |

**Key Points:**
- DependentName alone cannot uniquely identify a dependent
- Composite key: (EmployeeID + DependentName) forms the primary key
- If employee E001 is deleted, their dependents must also be deleted (cascading delete)
- Dependent entity has no meaning without the employee

---

## Comparison: Strong vs Weak Entity

| Aspect | Strong Entity | Weak Entity |
|--------|---------------|-------------|
| **Existence** | Independent | Dependent on owner entity |
| **Primary Key** | Own attributes | Partial key + foreign key |
| **ER Diagram** | Single rectangle | Double rectangle |
| **Relationship** | Normal diamond | Double diamond |
| **Examples** | Customer, Product, Employee | Order Items, Dependents, Room (in Hotel) |
| **Deletion** | Can be deleted independently | Deleted when owner is deleted |

---

## Another Example: Order and Order Items

### Strong Entity: Order
```sql
Order (OrderID, CustomerID, OrderDate, TotalAmount)
```

**Order Table:**
| OrderID | CustomerID | OrderDate  | TotalAmount |
|---------|------------|------------|-------------|
| O001    | C100       | 2024-01-15 | 150.00      |
| O002    | C101       | 2024-01-16 | 200.00      |

### Weak Entity: OrderItem
```sql
OrderItem (OrderID, ItemNumber, ProductID, Quantity, Price)
-- Composite Primary Key: (OrderID + ItemNumber)
```

**OrderItem Table:**
| OrderID | ItemNumber | ProductID | Quantity | Price |
|---------|------------|-----------|----------|-------|
| O001    | 1          | P501      | 2        | 50.00 |
| O001    | 2          | P502      | 1        | 50.00 |
| O002    | 1          | P503      | 3        | 66.67 |

**Explanation:**
- ItemNumber (1, 2, 3...) is the partial key (discriminator)
- ItemNumber alone cannot identify an order item
- Combined with OrderID, it forms a unique identifier
- If Order O001 is deleted, all its OrderItems are also deleted

---

## Identifying Weak Entities

Ask these questions:
1. **Can this entity exist without another entity?** → If NO, it's weak
2. **Does it have its own unique identifier?** → If NO, it's weak
3. **Is its existence dependent on a parent?** → If YES, it's weak
4. **Would deleting the parent make this meaningless?** → If YES, it's weak

---

## Real-World Examples

### Strong Entities
- **Bank Account** - Can exist independently
- **Student** - Has unique student ID
- **Product** - Has unique product code
- **Hotel** - Has unique hotel ID

### Weak Entities
- **Bank Transaction** - Depends on Bank Account
- **Course Enrollment** - Depends on Student and Course
- **Product Review** - Depends on Product
- **Hotel Room** - Depends on Hotel (Room 101 exists in multiple hotels)

---

## Summary

- **Strong entities** are self-reliant and have their own primary keys
- **Weak entities** depend on strong entities and need composite keys
- Weak entities cannot exist without their owner entity
- The relationship between strong and weak entities is called an **identifying relationship**
- Proper use of weak entities ensures data integrity and accurate representation of real-world dependencies
