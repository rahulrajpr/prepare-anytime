# PySpark Coding Problems - Study Guide

## Setup and Basics

### Creating SparkSession
```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("MyApp") \
    .master("local[*]") \
    .config("spark.driver.memory", "4g") \
    .getOrCreate()

# Stop spark session
# spark.stop()
```

---

## Problem 1: Read CSV and Basic Operations

### Problem
Read a CSV file and perform basic operations: show schema, count rows, display first 5 rows.

### Solution
```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("CSVReader").getOrCreate()

# Read CSV
df = spark.read.csv("employees.csv", header=True, inferSchema=True)

# Show schema
df.printSchema()

# Count rows
row_count = df.count()
print(f"Total rows: {row_count}")

# Show first 5 rows
df.show(5)

# Alternative: collect first 5
first_five = df.take(5)
for row in first_five:
    print(row)
```

**Key Points**:
- `inferSchema=True` automatically detects data types
- `show()` displays data in tabular format
- `take(n)` returns list of n rows

---

## Problem 2: Filter and Select

### Problem
From employees dataset, select only name and salary columns where salary > 50000.

### Solution
```python
# Sample data
data = [
    ("John", 55000, "IT"),
    ("Jane", 45000, "HR"),
    ("Bob", 60000, "IT"),
    ("Alice", 48000, "Finance")
]
columns = ["name", "salary", "department"]
df = spark.createDataFrame(data, columns)

# Method 1: Using filter and select
result = df.filter(df.salary > 50000).select("name", "salary")
result.show()

# Method 2: Using SQL-like syntax
result = df.filter("salary > 50000").select("name", "salary")
result.show()

# Method 3: Using where (alias for filter)
result = df.where(df.salary > 50000).select("name", "salary")
result.show()

# Output:
# +----+------+
# |name|salary|
# +----+------+
# |John| 55000|
# | Bob| 60000|
# +----+------+
```

---

## Problem 3: GroupBy and Aggregation

### Problem
Find the average salary by department and count of employees in each department.

### Solution
```python
from pyspark.sql.functions import avg, count, sum, max, min

data = [
    ("John", 55000, "IT"),
    ("Jane", 45000, "HR"),
    ("Bob", 60000, "IT"),
    ("Alice", 48000, "Finance"),
    ("Charlie", 52000, "IT"),
    ("Diana", 47000, "HR")
]
columns = ["name", "salary", "department"]
df = spark.createDataFrame(data, columns)

# GroupBy with multiple aggregations
result = df.groupBy("department").agg(
    avg("salary").alias("avg_salary"),
    count("name").alias("employee_count"),
    max("salary").alias("max_salary"),
    min("salary").alias("min_salary")
)

result.show()

# Output:
# +----------+----------+--------------+----------+----------+
# |department|avg_salary|employee_count|max_salary|min_salary|
# +----------+----------+--------------+----------+----------+
# |        HR|   46000.0|             2|     47000|     45000|
# |   Finance|   48000.0|             1|     48000|     48000|
# |        IT|   55666.7|             3|     60000|     52000|
# +----------+----------+--------------+----------+----------+
```

**Common Aggregation Functions**:
- `count()`, `sum()`, `avg()`, `max()`, `min()`
- `first()`, `last()`, `collect_list()`, `collect_set()`

---

## Problem 4: Join Operations

### Problem
Join employees with departments data to get full department information.

### Solution
```python
# Employees data
emp_data = [
    (1, "John", 101),
    (2, "Jane", 102),
    (3, "Bob", 101),
    (4, "Alice", 103)
]
emp_df = spark.createDataFrame(emp_data, ["emp_id", "name", "dept_id"])

# Departments data
dept_data = [
    (101, "IT", "New York"),
    (102, "HR", "Boston"),
    (103, "Finance", "Chicago")
]
dept_df = spark.createDataFrame(dept_data, ["dept_id", "dept_name", "location"])

# Inner Join
result = emp_df.join(dept_df, emp_df.dept_id == dept_df.dept_id, "inner")
result.select("emp_id", "name", "dept_name", "location").show()

# Left Join
left_result = emp_df.join(dept_df, emp_df.dept_id == dept_df.dept_id, "left")
left_result.show()

# Output (Inner Join):
# +------+-----+---------+--------+
# |emp_id| name|dept_name|location|
# +------+-----+---------+--------+
# |     1| John|       IT|New York|
# |     3|  Bob|       IT|New York|
# |     2| Jane|       HR|  Boston|
# |     4|Alice|  Finance| Chicago|
# +------+-----+---------+--------+
```

**Join Types**:
- `inner` (default)
- `left`, `left_outer`
- `right`, `right_outer`
- `full`, `full_outer`
- `cross`

---

## Problem 5: Add New Column (withColumn)

### Problem
Add a new column that shows salary with 10% bonus.

### Solution
```python
from pyspark.sql.functions import col, lit, when

data = [
    ("John", 55000, "IT"),
    ("Jane", 45000, "HR"),
    ("Bob", 60000, "IT")
]
df = spark.createDataFrame(data, ["name", "salary", "department"])

# Add bonus column (10% of salary)
df_with_bonus = df.withColumn("bonus", col("salary") * 0.10)
df_with_bonus.show()

# Add total compensation
df_with_total = df_with_bonus.withColumn(
    "total_compensation", 
    col("salary") + col("bonus")
)
df_with_total.show()

# Conditional column: "high" if salary > 50000, else "low"
df_with_category = df.withColumn(
    "salary_category",
    when(col("salary") > 50000, "high").otherwise("low")
)
df_with_category.show()
```

---

## Problem 6: Handle Null Values

### Problem
Handle missing values in a dataset: drop nulls, fill with defaults, or replace.

### Solution
```python
from pyspark.sql.functions import col, when, isnan, isnull

data = [
    ("John", 55000, "IT"),
    ("Jane", None, "HR"),
    ("Bob", 60000, None),
    (None, 48000, "Finance")
]
df = spark.createDataFrame(data, ["name", "salary", "department"])

print("Original Data:")
df.show()

# Drop rows with any null
df_no_nulls = df.na.drop()
print("After dropping nulls:")
df_no_nulls.show()

# Drop rows where specific columns are null
df_drop_specific = df.na.drop(subset=["name"])
print("After dropping rows with null name:")
df_drop_specific.show()

# Fill null values with defaults
df_filled = df.na.fill({
    "name": "Unknown",
    "salary": 0,
    "department": "Unassigned"
})
print("After filling nulls:")
df_filled.show()

# Replace specific values
df_replaced = df.replace(["IT", "HR"], ["Technology", "Human Resources"], "department")
print("After replacement:")
df_replaced.show()

# Filter out nulls
df_filtered = df.filter(col("salary").isNotNull())
print("Filter non-null salaries:")
df_filtered.show()
```

---

## Problem 7: Window Functions

### Problem
Calculate running total of salary and rank employees by salary within each department.

### Solution
```python
from pyspark.sql.window import Window
from pyspark.sql.functions import row_number, rank, dense_rank, sum as _sum

data = [
    ("John", 55000, "IT"),
    ("Jane", 45000, "HR"),
    ("Bob", 60000, "IT"),
    ("Alice", 48000, "HR"),
    ("Charlie", 52000, "IT"),
    ("Diana", 50000, "HR")
]
df = spark.createDataFrame(data, ["name", "salary", "department"])

# Define window specification
window_spec = Window.partitionBy("department").orderBy(col("salary").desc())

# Add rank columns
df_with_rank = df.withColumn("rank", rank().over(window_spec)) \
                 .withColumn("dense_rank", dense_rank().over(window_spec)) \
                 .withColumn("row_number", row_number().over(window_spec))

df_with_rank.show()

# Running total by department
window_running = Window.partitionBy("department").orderBy("salary").rowsBetween(Window.unboundedPreceding, 0)

df_with_running = df.withColumn(
    "running_total",
    _sum("salary").over(window_running)
)
df_with_running.orderBy("department", "salary").show()
```

---

## Problem 8: Remove Duplicates

### Problem
Remove duplicate records from a dataset.

### Solution
```python
data = [
    ("John", "IT", 55000),
    ("Jane", "HR", 45000),
    ("John", "IT", 55000),  # Duplicate
    ("Bob", "IT", 60000),
    ("Jane", "HR", 45000)   # Duplicate
]
df = spark.createDataFrame(data, ["name", "department", "salary"])

print("Original data with duplicates:")
df.show()

# Remove all duplicates
df_distinct = df.distinct()
print("After removing duplicates:")
df_distinct.show()

# Remove duplicates based on specific columns
df_drop_duplicates = df.dropDuplicates(["name", "department"])
print("After removing duplicates by name and department:")
df_drop_duplicates.show()
```

---

## Problem 9: Union and UnionAll

### Problem
Combine two DataFrames with same schema.

### Solution
```python
# DataFrame 1
data1 = [
    ("John", "IT"),
    ("Jane", "HR")
]
df1 = spark.createDataFrame(data1, ["name", "department"])

# DataFrame 2
data2 = [
    ("Bob", "Finance"),
    ("Alice", "IT")
]
df2 = spark.createDataFrame(data2, ["name", "department"])

# Union (removes duplicates)
union_df = df1.union(df2)
print("Union result:")
union_df.show()

# UnionAll (keeps duplicates) - deprecated, use union
unionall_df = df1.union(df2)
print("UnionAll result:")
unionall_df.show()

# Union with duplicate removal
distinct_union = df1.union(df2).distinct()
print("Union with distinct:")
distinct_union.show()
```

---

## Problem 10: Working with Dates

### Problem
Parse dates, extract date components, and calculate date differences.

### Solution
```python
from pyspark.sql.functions import (
    to_date, year, month, dayofmonth, dayofweek,
    datediff, months_between, date_add, current_date
)

data = [
    (1, "2024-01-15"),
    (2, "2024-06-20"),
    (3, "2024-12-25")
]
df = spark.createDataFrame(data, ["id", "date_string"])

# Convert string to date
df_with_date = df.withColumn("date", to_date(col("date_string"), "yyyy-MM-dd"))

# Extract date components
df_with_components = df_with_date \
    .withColumn("year", year("date")) \
    .withColumn("month", month("date")) \
    .withColumn("day", dayofmonth("date")) \
    .withColumn("day_of_week", dayofweek("date"))

df_with_components.show()

# Calculate date differences
df_with_diff = df_with_date \
    .withColumn("current_date", current_date()) \
    .withColumn("days_diff", datediff(col("current_date"), col("date"))) \
    .withColumn("months_diff", months_between(col("current_date"), col("date")))

df_with_diff.show()

# Add days to date
df_future = df_with_date.withColumn("future_date", date_add("date", 30))
df_future.show()
```

---

## Problem 11: SQL Queries

### Problem
Register DataFrame as temporary view and run SQL queries.

### Solution
```python
data = [
    ("John", 55000, "IT"),
    ("Jane", 45000, "HR"),
    ("Bob", 60000, "IT"),
    ("Alice", 48000, "Finance")
]
df = spark.createDataFrame(data, ["name", "salary", "department"])

# Register as temporary view
df.createOrReplaceTempView("employees")

# Run SQL query
result = spark.sql("""
    SELECT department, 
           AVG(salary) as avg_salary,
           COUNT(*) as employee_count
    FROM employees
    GROUP BY department
    HAVING AVG(salary) > 50000
    ORDER BY avg_salary DESC
""")

result.show()

# Complex SQL with subquery
result2 = spark.sql("""
    SELECT e.name, e.salary, e.department
    FROM employees e
    WHERE e.salary > (
        SELECT AVG(salary)
        FROM employees
        WHERE department = e.department
    )
""")

result2.show()
```

---

## Problem 12: User Defined Functions (UDF)

### Problem
Create custom function to categorize salary levels.

### Solution
```python
from pyspark.sql.functions import udf
from pyspark.sql.types import StringType

data = [
    ("John", 55000),
    ("Jane", 45000),
    ("Bob", 80000),
    ("Alice", 35000)
]
df = spark.createDataFrame(data, ["name", "salary"])

# Define Python function
def categorize_salary(salary):
    if salary >= 70000:
        return "High"
    elif salary >= 50000:
        return "Medium"
    else:
        return "Low"

# Register UDF
categorize_udf = udf(categorize_salary, StringType())

# Apply UDF
df_with_category = df.withColumn("salary_category", categorize_udf(col("salary")))
df_with_category.show()

# Alternative: Using decorator
@udf(returnType=StringType())
def categorize_salary_v2(salary):
    if salary >= 70000:
        return "High"
    elif salary >= 50000:
        return "Medium"
    else:
        return "Low"

df_with_category2 = df.withColumn("category", categorize_salary_v2("salary"))
df_with_category2.show()
```

**Note**: UDFs have performance overhead. Use built-in functions when possible.

---

## Problem 13: Pivot Table

### Problem
Create a pivot table showing total sales by product and region.

### Solution
```python
data = [
    ("Product_A", "North", 100),
    ("Product_A", "South", 150),
    ("Product_B", "North", 200),
    ("Product_B", "South", 180),
    ("Product_A", "North", 120),
    ("Product_C", "South", 90)
]
df = spark.createDataFrame(data, ["product", "region", "sales"])

# Create pivot table
pivot_df = df.groupBy("product").pivot("region").sum("sales")
pivot_df.show()

# Output:
# +---------+-----+-----+
# |  product|North|South|
# +---------+-----+-----+
# |Product_A|  220|  150|
# |Product_B|  200|  180|
# |Product_C| null|   90|
# +---------+-----+-----+

# Fill null values in pivot
pivot_filled = df.groupBy("product").pivot("region").sum("sales").na.fill(0)
pivot_filled.show()
```

---

## Problem 14: Read and Write Parquet

### Problem
Write DataFrame to Parquet format and read it back.

### Solution
```python
data = [
    ("John", 55000, "IT"),
    ("Jane", 45000, "HR"),
    ("Bob", 60000, "IT")
]
df = spark.createDataFrame(data, ["name", "salary", "department"])

# Write to Parquet
df.write.mode("overwrite").parquet("/tmp/employees.parquet")

# Write with partitioning
df.write.mode("overwrite").partitionBy("department").parquet("/tmp/employees_partitioned")

# Read Parquet
df_read = spark.read.parquet("/tmp/employees.parquet")
df_read.show()

# Read partitioned Parquet
df_partitioned = spark.read.parquet("/tmp/employees_partitioned")
df_partitioned.show()
```

---

## Problem 15: Cache and Persist

### Problem
Improve performance by caching frequently accessed DataFrame.

### Solution
```python
data = [(i, i*10) for i in range(1000000)]
df = spark.createDataFrame(data, ["id", "value"])

# Without cache - slow if accessed multiple times
df.filter(col("value") > 500000).count()
df.filter(col("value") < 100000).count()

# With cache
df.cache()  # or df.persist()

# Now these operations reuse cached data
df.filter(col("value") > 500000).count()
df.filter(col("value") < 100000).count()

# Different storage levels
from pyspark import StorageLevel
df.persist(StorageLevel.MEMORY_AND_DISK)

# Unpersist when done
df.unpersist()
```

**Storage Levels**:
- `MEMORY_ONLY` (default)
- `MEMORY_AND_DISK`
- `DISK_ONLY`
- `MEMORY_ONLY_SER`

---

## Quick Reference: Common Operations

```python
# Selection
df.select("col1", "col2")
df.select(col("col1").alias("new_name"))

# Filtering
df.filter(col("age") > 25)
df.where("age > 25")

# Sorting
df.orderBy("salary")
df.orderBy(col("salary").desc())

# Grouping
df.groupBy("department").agg(avg("salary"))

# Joins
df1.join(df2, df1.id == df2.id, "inner")

# Column operations
df.withColumn("new_col", col("old_col") * 2)
df.withColumnRenamed("old_name", "new_name")
df.drop("column_to_remove")

# Actions (trigger computation)
df.show()
df.count()
df.collect()
df.first()
df.take(5)
```
