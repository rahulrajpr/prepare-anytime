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

### 1:M Optional to Mandatory
[DEPARTMENT] ||——|< [EMPLOYEE]

### M:M with Junction Table
[STUDENT] ||——|< [ENROLLMENT] >|——|| [COURSE]

### Optional Participation
[CUSTOMER] |o——|| [ORDER]

### Mandatory Participation  
[EMPLOYEE] ||——|| [SALARY]

---

## Key Points
- **Minimum = 0** → Optional participation
- **Minimum = 1** → Mandatory participation
- **Maximum = 1** → Single occurrence
- **Maximum = N** → Multiple occurrences
- Cardinality defines business rules between entities
