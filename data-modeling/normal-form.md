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

## Summary
- **1NF:** No repeating groups, atomic values
- **2NF:** In 1NF + no partial dependencies (all non-key columns depend on entire primary key)
- **3NF:** In 2NF + no transitive dependencies (no non-key column depends on another non-key column)
