
# Bridge Entities (Intersection Entities)

## What is a Bridge Entity?
A bridge entity is a separate table created to resolve Many-to-Many (M:M) relationships between two entities by converting them into two One-to-Many (1:M) relationships.

## Why We Need Bridge Entities?
- **Direct M:M relationships cannot be implemented** in relational databases
- **Bridge entities store relationship attributes** (like enrollment date, grade)
- **Enable proper foreign key relationships**
- **Allow additional information** about the relationship itself

## Student-Class M:M Example

### Problem: Direct M:M (Not Possible)
Students (M) ─────── (M) Classes

*Cannot implement directly in databases*

### Solution: Bridge Entity
Students (1) ─────── (M) Enrollments (M) ─────── (1) Classes

### Database Structure:
```sql
-- ENTITY TABLES
Students (StudentID, Name, Email)
Classes (ClassID, ClassName, Instructor)

-- BRIDGE ENTITY
Enrollments (EnrollmentID, StudentID, ClassID, EnrollmentDate, Grade)
Example Data:
Students:

StudentID	Name	Email
S001	Alice	alice@email.com
S002	Bob	bob@email.com
Classes:

ClassID	ClassName	Instructor
C101	Math	Dr. Smith
C102	Science	Dr. Johnson
Enrollments (Bridge Entity):

EnrollmentID	StudentID	ClassID	EnrollmentDate	Grade
E001	S001	C101	2024-01-15	A
E002	S001	C102	2024-01-15	B+
E003	S002	C101	2024-01-16	A-
Key Points:
Primary Key: Usually composite (StudentID + ClassID) or surrogate (EnrollmentID)

Foreign Keys: References both parent tables

Relationship Data: Stores details about the relationship itself

Mandatory: Required for all M:M relationships in relational databases
