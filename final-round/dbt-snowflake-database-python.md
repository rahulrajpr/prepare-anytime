# Director Interview Study Guide
## Data Engineering: Concepts, Strategy & Technical Mastery

---

## How to Use This Guide

This is your complete preparation resource combining **conceptual understanding** with **technical depth**.

**The Structure:**
Each topic follows this pattern:
1. **The Concept** - What problem does this solve? Why does it matter?
2. **Strategic Thinking** - When to use it, when not to, trade-offs
3. **Technical Implementation** - Code examples in ANSI SQL, Snowflake, Redshift
4. **Real-World Application** - Practical scenarios and edge cases

**Study Approach:**
- First pass: Read concepts and understand the "why"
- Second pass: Study code examples and understand implementation
- Third pass: Practice explaining concepts + walking through code
- Interview day: Think concepts first, reference code as needed

---

## Table of Contents

1. [SQL Advanced Concepts & Patterns](#sql-advanced-concepts)
2. [Database Architecture & Design](#database-architecture)
3. [Python for Data Engineering](#python-data-engineering)
4. [DBT Workflow & Best Practices](#dbt-workflow)
5. [Snowflake Deep Dive](#snowflake-deep-dive)
6. [Redshift Optimization](#redshift-optimization)
7. [Interview Strategy](#interview-strategy)

---

## SQL Advanced Concepts & Patterns

### PIVOT and UNPIVOT - The Shape-Shifting Problem

#### Understanding the Concept

**The Core Problem:**
Data exists in two shapes:
- **Narrow (Normalized)**: Many rows, few columns - databases love this
- **Wide (Denormalized)**: Few rows, many columns - humans love this

You constantly need to convert between them.

**Think of it like:**
- Narrow = Vertical list (scrolling down to see all months)
- Wide = Horizontal spreadsheet (comparing months side-by-side)

**When You Need PIVOT:**
You have time-series or categorical data in rows, but need to compare values side-by-side.

```
Source (narrow - database format):
Product | Month | Sales
A       | Jan   | 100
A       | Feb   | 150
A       | Mar   | 200
B       | Jan   | 120
B       | Feb   | 180

Target (wide - report format):
Product | Jan | Feb | Mar
A       | 100 | 150 | 200
B       | 120 | 180 | 0
```

**Real-World Scenarios:**
- Monthly sales comparison for executive dashboard
- Year-over-year analysis (2022 vs 2023 vs 2024 columns)
- A/B test results (Control vs Variant columns)
- Survey responses (Questions as columns)

**When NOT to PIVOT:**
- Data will be queried/filtered by the pivoted dimension (keep it narrow)
- Pivot columns are dynamic (new values = new columns = broken reports)
- Loading into another database (keep normalized)
- Need to aggregate across the pivoted dimension

**The Strategic Trade-off:**
Wide data is easier for humans to read but harder to query and maintain. **Pivot at the last possible moment** - in your BI tool or final reporting layer, not in your data warehouse.

---

#### PIVOT Implementation - All Three Syntaxes

**ANSI SQL (Universal - Works Everywhere):**

```sql
-- The CASE statement approach - works in all databases
SELECT 
    product_id,
    product_name,
    -- Create a column for each month using CASE
    SUM(CASE WHEN month = 'Jan' THEN sales ELSE 0 END) AS jan_sales,
    SUM(CASE WHEN month = 'Feb' THEN sales ELSE 0 END) AS feb_sales,
    SUM(CASE WHEN month = 'Mar' THEN sales ELSE 0 END) AS mar_sales,
    -- Total across all months
    SUM(sales) AS total_sales
FROM monthly_sales
WHERE year = 2024
GROUP BY product_id, product_name
ORDER BY total_sales DESC;

-- For NULL handling (distinguish between 0 and no data):
SUM(CASE WHEN month = 'Jan' THEN sales END) AS jan_sales  -- NULL instead of 0
```

**Key Points:**
- One CASE statement per output column
- SUM() needed even for single values (aggregation function required)
- NULL vs 0: Use `THEN sales END` for NULL, `ELSE 0 END` for 0
- Must GROUP BY all non-aggregated columns

---

**Snowflake (Native PIVOT Support):**

```sql
-- Clean, declarative syntax
SELECT *
FROM monthly_sales
PIVOT (
    SUM(sales)                    -- Aggregation function
    FOR month                     -- Column to pivot on
    IN ('Jan', 'Feb', 'Mar')     -- Values become column names
) AS pivoted_data
ORDER BY product_name;

-- Dynamic column names
PIVOT (
    SUM(sales) AS total           -- Suffix for column names
    FOR month 
    IN ('Jan', 'Feb', 'Mar')
)
-- Creates: 'Jan_total', 'Feb_total', 'Mar_total'

-- Multiple aggregations
PIVOT (
    SUM(sales) AS total_sales,
    AVG(sales) AS avg_sales,
    COUNT(*) AS transaction_count
    FOR month 
    IN ('Jan', 'Feb', 'Mar')
)
-- Creates: Jan_total_sales, Jan_avg_sales, Jan_transaction_count, etc.

-- With WHERE clause (filter before pivoting)
SELECT *
FROM monthly_sales
WHERE region = 'US' AND year = 2024
PIVOT (SUM(sales) FOR month IN ('Jan', 'Feb', 'Mar'));
```

**Snowflake Advantages:**
- Much cleaner syntax
- Easier to maintain
- Can pivot multiple aggregations at once
- Better query plan optimization

---

**Redshift (No Native PIVOT):**

```sql
-- Redshift uses the same CASE approach as ANSI SQL
SELECT 
    product_id,
    product_name,
    SUM(CASE WHEN month = 'Jan' THEN sales ELSE 0 END) AS jan_sales,
    SUM(CASE WHEN month = 'Feb' THEN sales ELSE 0 END) AS feb_sales,
    SUM(CASE WHEN month = 'Mar' THEN sales ELSE 0 END) AS mar_sales,
    SUM(sales) AS total_sales
FROM monthly_sales
WHERE year = 2024
GROUP BY product_id, product_name;

-- For better performance with large datasets, consider temp table:
CREATE TEMP TABLE pivoted_sales AS
SELECT 
    product_id,
    SUM(CASE WHEN month = 'Jan' THEN sales ELSE 0 END) AS jan_sales,
    SUM(CASE WHEN month = 'Feb' THEN sales ELSE 0 END) AS feb_sales,
    SUM(CASE WHEN month = 'Mar' THEN sales ELSE 0 END) AS mar_sales
FROM monthly_sales
GROUP BY product_id;

-- Then join with dimension tables as needed
```

**Performance Tip for Redshift:**
Pre-filter data before pivoting to minimize rows processed in GROUP BY.

---

#### UNPIVOT Implementation - Converting Wide to Narrow

**The Reverse Problem:**
Someone gives you a spreadsheet with months as columns, but you need it in database format.

```
Source (wide):
Product | Jan_2024 | Feb_2024 | Mar_2024
A       | 1000     | 1200     | 1500
B       | 800      | 950      | 1100

Target (narrow):
Product | Month    | Sales
A       | Jan_2024 | 1000
A       | Feb_2024 | 1200
A       | Mar_2024 | 1500
B       | Jan_2024 | 800
```

**When You Need UNPIVOT:**
- Loading Excel/CSV files with data in columns
- Normalizing denormalized reports
- Preparing data for time-series analysis
- Data quality checks requiring row-by-row validation

---

**ANSI SQL (UNION ALL Pattern):**

```sql
-- Traditional approach: One SELECT per column
SELECT 
    product,
    'Jan' AS month,
    jan_sales AS sales
FROM wide_sales_table
WHERE jan_sales IS NOT NULL

UNION ALL

SELECT 
    product,
    'Feb' AS month,
    feb_sales AS sales
FROM wide_sales_table
WHERE feb_sales IS NOT NULL

UNION ALL

SELECT 
    product,
    'Mar' AS month,
    mar_sales AS sales
FROM wide_sales_table
WHERE mar_sales IS NOT NULL

ORDER BY product, month;
```

**Pros:** Works everywhere, simple to understand
**Cons:** Verbose, scans table multiple times (inefficient for large tables)

---

**Snowflake (Native UNPIVOT):**

```sql
-- Clean syntax mirroring PIVOT
SELECT *
FROM wide_sales_table
UNPIVOT (
    sales                         -- Value column name
    FOR month                     -- Column that holds original column names
    IN (jan_sales, feb_sales, mar_sales)  -- Columns to unpivot
) AS unpivoted_data
ORDER BY product, month;

-- Exclude NULLs (default behavior)
UNPIVOT (sales FOR month IN (jan_sales, feb_sales, mar_sales));

-- Include NULLs
UNPIVOT INCLUDE NULLS (sales FOR month IN (jan_sales, feb_sales, mar_sales));

-- Multiple value columns at once
UNPIVOT (
    (sales, profit)               -- Two value columns
    FOR month 
    IN (
        (jan_sales, jan_profit),
        (feb_sales, feb_profit),
        (mar_sales, mar_profit)
    )
);
```

---

**Redshift (Cross Join Pattern - More Efficient):**

```sql
-- More efficient than UNION ALL for large tables
SELECT 
    product,
    months.month_name AS month,
    CASE months.month_name
        WHEN 'Jan' THEN jan_sales
        WHEN 'Feb' THEN feb_sales
        WHEN 'Mar' THEN mar_sales
    END AS sales
FROM wide_sales_table
CROSS JOIN (
    SELECT 'Jan' AS month_name
    UNION ALL SELECT 'Feb'
    UNION ALL SELECT 'Mar'
) AS months
WHERE CASE months.month_name
    WHEN 'Jan' THEN jan_sales
    WHEN 'Feb' THEN feb_sales
    WHEN 'Mar' THEN mar_sales
END IS NOT NULL
ORDER BY product, month;
```

**Why This is Better in Redshift:**
- Single table scan (vs 3 scans with UNION ALL)
- Better for tables with many columns to unpivot
- More efficient execution plan

---

#### Real-World Edge Cases

**Problem 1: NULL vs 0**
```sql
-- Scenario: Some products had no sales in February
-- Do you want: NULL (no data) or 0 (confirmed zero sales)?

-- For NULL (absence of data):
SUM(CASE WHEN month = 'Feb' THEN sales END) AS feb_sales

-- For 0 (confirmed zero):
SUM(CASE WHEN month = 'Feb' THEN sales ELSE 0 END) AS feb_sales
```

**Problem 2: Dynamic Columns**
```sql
-- Bad: Hard-coding month names breaks when new months arrive
-- Better: Generate PIVOT query dynamically in application code
-- Or: Use BI tool's pivot functionality instead of SQL
```

**Problem 3: Data Type Consistency**
```sql
-- All pivoted columns must be same type
-- This fails: PIVOT sales (string) and quantity (int) together
-- Solution: Cast to common type or pivot separately
```

---

### Window Functions - The "Look Around" Problem

#### Understanding the Concept

**The Core Problem:**
Regular SQL aggregations collapse rows:
```
SELECT department, AVG(salary) FROM employees GROUP BY department
→ Returns one row per department (lost employee details)
```

But sometimes you need to:
- **Compare** each row to the group (Is Alice's salary above department average?)
- **Rank** rows within groups (Who's the #1 salesperson this month?)
- **Reference** nearby rows (What was yesterday's value?)
- **Calculate running totals** (Cumulative revenue year-to-date)

**Without losing the original rows.**

**Window functions solve this:** They let you "look around" at related rows while keeping every row intact.

---

#### The Mental Model

Think of window functions as creating a temporary "view" through a sliding frame:

**1. PARTITION BY** = "Which rows to compare"
- Like GROUP BY but doesn't collapse rows
- Creates separate "windows" for each group
- Example: `PARTITION BY department` = compare within department

**2. ORDER BY** = "Arrange rows in sequence"
- Defines what "previous" and "next" mean
- Critical for LAG, LEAD, running totals
- Example: `ORDER BY date` = chronological sequence

**3. Frame Specification** = "Which nearby rows to include"
- `ROWS BETWEEN ... AND ...` defines window size
- Example: `ROWS BETWEEN 6 PRECEDING AND CURRENT ROW` = 7-day window

---

#### ROW_NUMBER, RANK, DENSE_RANK - Breaking Ties

**The Concept:**
All three assign numbers to rows, but handle ties differently.

**Scenario:** Employee salaries
```
Employee | Salary
Alice    | 100000
Bob      | 100000  (tie with Alice)
Carol    | 90000
David    | 80000
```

**ROW_NUMBER**: "Every row gets a unique number, ties broken arbitrarily"
```
Alice  | 100000 | 1
Bob    | 100000 | 2  ← Arbitrary (could be 1)
Carol  | 90000  | 3
David  | 80000  | 4
```

**RANK**: "Ties share rank, then skip numbers"
```
Alice  | 100000 | 1
Bob    | 100000 | 1  ← Same rank as Alice
Carol  | 90000  | 3  ← Skipped 2
David  | 80000  | 4
```

**DENSE_RANK**: "Ties share rank, no gaps"
```
Alice  | 100000 | 1
Bob    | 100000 | 1  ← Same rank
Carol  | 90000  | 2  ← No gap
David  | 80000  | 3
```

**When to Use Each:**

- **ROW_NUMBER**: Pagination, deduplication, need unique IDs
- **RANK**: Sports rankings, competitive scenarios where ties affect standings
- **DENSE_RANK**: Category rankings (gold/silver/bronze), salary bands

---

#### Implementation - All Three Syntaxes

**ANSI SQL (Works in Snowflake, Redshift, All Databases):**

```sql
-- Basic ranking within departments
SELECT 
    employee_id,
    employee_name,
    department,
    salary,
    -- Different ranking methods
    ROW_NUMBER() OVER (
        PARTITION BY department 
        ORDER BY salary DESC
    ) as row_num,
    RANK() OVER (
        PARTITION BY department 
        ORDER BY salary DESC
    ) as rank,
    DENSE_RANK() OVER (
        PARTITION BY department 
        ORDER BY salary DESC
    ) as dense_rank
FROM employees
ORDER BY department, salary DESC;

-- Find top 3 earners per department
SELECT *
FROM (
    SELECT 
        employee_name,
        department,
        salary,
        RANK() OVER (PARTITION BY department ORDER BY salary DESC) as rank
    FROM employees
) ranked
WHERE rank <= 3
ORDER BY department, rank;

-- Deduplication using ROW_NUMBER
-- Keep only the most recent record per customer
DELETE FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM (
        SELECT 
            customer_id,
            ROW_NUMBER() OVER (
                PARTITION BY customer_id 
                ORDER BY updated_at DESC
            ) as rn
        FROM customers
    ) duplicates
    WHERE rn > 1
);
```

---

**Snowflake (With QUALIFY Clause - Super Clean):**

```sql
-- QUALIFY: Filter window function results directly (no subquery needed)
SELECT 
    employee_name,
    department,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) as rank
FROM employees
QUALIFY rank <= 3  -- Filter directly on window function!
ORDER BY department, rank;

-- Deduplication - cleaner than DELETE
SELECT *
FROM customers
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id 
    ORDER BY updated_at DESC
) = 1;

-- Complex filtering
SELECT 
    product_name,
    category,
    sales,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY sales DESC) as sales_rank,
    AVG(sales) OVER (PARTITION BY category) as category_avg
FROM products
QUALIFY sales_rank <= 5           -- Top 5 products
    AND sales > category_avg       -- Above category average
ORDER BY category, sales_rank;
```

**Snowflake Advantage:** QUALIFY eliminates subqueries, making code cleaner and more readable.

---

**Redshift (Standard SQL - No QUALIFY):**

```sql
-- Must use subqueries for filtering window functions
SELECT 
    employee_name,
    department,
    salary,
    rank
FROM (
    SELECT 
        employee_name,
        department,
        salary,
        RANK() OVER (PARTITION BY department ORDER BY salary DESC) as rank
    FROM employees
) ranked
WHERE rank <= 3;

-- For deduplication, same pattern
SELECT *
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY updated_at DESC
        ) as rn
    FROM customers
) deduped
WHERE rn = 1;
```

---

#### LAG and LEAD - Time Travel in Queries

**The Concept:**
Access previous or next row's value without self-joins.

**Before Window Functions:**
```sql
-- Old way: Self-join (expensive and complex)
SELECT 
    t1.date,
    t1.revenue,
    t2.revenue as prev_day_revenue
FROM daily_sales t1
LEFT JOIN daily_sales t2 
    ON t1.date = t2.date + INTERVAL '1 day'
ORDER BY t1.date;
```

**With Window Functions:**
```sql
-- Much simpler and more efficient
SELECT 
    date,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY date) as prev_day_revenue
FROM daily_sales
ORDER BY date;
```

**Real-World Use Cases:**
1. **Month-over-Month Growth**: Compare current vs previous month
2. **Churn Detection**: Find gaps between customer activities
3. **Gap Filling**: Forward-fill missing sensor readings
4. **Trend Analysis**: Compare current value to previous period

---

**ANSI SQL (Snowflake & Redshift):**

```sql
-- Basic LAG and LEAD
SELECT 
    order_date,
    order_id,
    amount,
    -- Previous order amount
    LAG(amount, 1) OVER (ORDER BY order_date) as prev_amount,
    -- Next order amount
    LEAD(amount, 1) OVER (ORDER BY order_date) as next_amount,
    -- Default value if no previous row (instead of NULL)
    LAG(amount, 1, 0) OVER (ORDER BY order_date) as prev_amount_with_default
FROM orders;

-- Calculate day-over-day change
SELECT 
    date,
    revenue,
    LAG(revenue) OVER (ORDER BY date) as prev_day_revenue,
    revenue - LAG(revenue) OVER (ORDER BY date) as daily_change,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY date)) 
        / NULLIF(LAG(revenue) OVER (ORDER BY date), 0),
        2
    ) as pct_change
FROM daily_revenue
ORDER BY date;

-- Within partitions (separate calculations per group)
SELECT 
    customer_id,
    order_date,
    order_id,
    amount,
    -- Previous order for THIS customer
    LAG(order_date) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date
    ) as prev_order_date,
    -- Days since last order for this customer
    DATEDIFF('day', 
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date),
        order_date
    ) as days_since_last_order
FROM orders
ORDER BY customer_id, order_date;

-- Find churned customers (no order in 90 days)
SELECT 
    customer_id,
    order_date,
    LEAD(order_date) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date
    ) as next_order_date,
    DATEDIFF('day', order_date, 
        LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)
    ) as days_to_next_order
FROM orders
QUALIFY days_to_next_order > 90 OR days_to_next_order IS NULL;
```

---

**Snowflake Specific (IGNORE NULLS):**

```sql
-- Forward-fill missing values (carry last valid value forward)
SELECT 
    date,
    sensor_id,
    temperature,
    -- Get last non-null temperature reading
    LAG(temperature IGNORE NULLS) OVER (
        PARTITION BY sensor_id 
        ORDER BY date
    ) as last_valid_temperature,
    -- Fill nulls with last valid reading
    COALESCE(
        temperature,
        LAG(temperature IGNORE NULLS) OVER (PARTITION BY sensor_id ORDER BY date)
    ) as filled_temperature
FROM sensor_readings
ORDER BY sensor_id, date;

-- This is SUPER useful for time-series data with gaps
```

**Why This Matters:** IoT sensors, stock prices, or any data with intermittent readings.

---

**Redshift (No IGNORE NULLS - Workaround):**

```sql
-- Redshift doesn't support IGNORE NULLS in LAG/LEAD
-- Workaround: Use FIRST_VALUE with appropriate frame

SELECT 
    date,
    sensor_id,
    temperature,
    -- Get last non-null value
    FIRST_VALUE(temperature) OVER (
        PARTITION BY sensor_id
        ORDER BY date
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
    ) as last_valid_temp
FROM sensor_readings
WHERE temperature IS NOT NULL  -- Only include non-null readings
ORDER BY sensor_id, date;

-- Or use LAST_VALUE with reverse ordering
SELECT 
    date,
    sensor_id,
    temperature,
    LAST_VALUE(temperature) OVER (
        PARTITION BY sensor_id, 
                     SUM(CASE WHEN temperature IS NOT NULL THEN 1 END) 
                         OVER (PARTITION BY sensor_id ORDER BY date)
        ORDER BY date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as filled_temperature
FROM sensor_readings;
```

---

#### Running Totals and Moving Averages

**The Concept:**
Aggregate values up to or around the current row.

**Real-World Scenarios:**
- **Running balance**: Bank account ins/outs cumulative
- **Year-to-date revenue**: Cumulative from Jan 1
- **7-day moving average**: Smooth noisy data
- **Inventory levels**: Running stock quantity

---

**ANSI SQL (All Three Platforms):**

```sql
-- Running total (cumulative sum)
SELECT 
    order_date,
    order_id,
    amount,
    SUM(amount) OVER (
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as running_total
FROM orders
ORDER BY order_date, order_id;

-- Shorter syntax (same result)
SUM(amount) OVER (ORDER BY order_date, order_id) as running_total

-- Year-to-date total (reset each year)
SELECT 
    order_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY YEAR(order_date)
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as ytd_total
FROM orders;

-- 7-day moving average
SELECT 
    date,
    revenue,
    AVG(revenue) OVER (
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as moving_avg_7day,
    -- Also show the count (for partial windows at start)
    COUNT(*) OVER (
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as days_in_window
FROM daily_revenue
ORDER BY date;

-- 30-day rolling sum with centered window
SELECT 
    date,
    sales,
    SUM(sales) OVER (
        ORDER BY date
        ROWS BETWEEN 15 PRECEDING AND 15 FOLLOWING
    ) as centered_30day_sum
FROM daily_sales;

-- Min, max, avg in rolling window
SELECT 
    date,
    stock_price,
    MIN(stock_price) OVER (
        ORDER BY date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) as low_30day,
    MAX(stock_price) OVER (
        ORDER BY date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) as high_30day,
    AVG(stock_price) OVER (
        ORDER BY date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) as avg_30day
FROM stock_prices
ORDER BY date;
```

**Frame Specification Options:**
```sql
-- ROWS vs RANGE (important distinction!)

-- ROWS: Physical row count
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW  -- Exactly 7 rows

-- RANGE: Logical value range (same values grouped)
RANGE BETWEEN INTERVAL '6 days' PRECEDING AND CURRENT ROW

-- Common frame patterns:
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  -- From start to here
ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING  -- From here to end
ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING          -- 3-row window (before, current, after)
```

---

#### Performance Considerations

**Snowflake:**
- Window functions are well-optimized
- Can handle billions of rows efficiently
- Result caching helps repeated queries

**Redshift:**
- Window functions can be expensive on large datasets
- Consider materializing results if queried frequently
- Sort key on ORDER BY column helps performance

**General Tips:**
```sql
-- ❌ Inefficient: Multiple window functions with same OVER clause
SELECT 
    employee_name,
    salary,
    AVG(salary) OVER (PARTITION BY department ORDER BY salary) as avg_sal,
    MAX(salary) OVER (PARTITION BY department ORDER BY salary) as max_sal,
    MIN(salary) OVER (PARTITION BY department ORDER BY salary) as min_sal
FROM employees;

-- ✅ Better: Use WINDOW clause (define once, reference multiple times)
SELECT 
    employee_name,
    salary,
    AVG(salary) OVER w as avg_sal,
    MAX(salary) OVER w as max_sal,
    MIN(salary) OVER w as min_sal
FROM employees
WINDOW w AS (PARTITION BY department ORDER BY salary);
```

---

### Recursive CTEs - Traversing Hierarchies

#### Understanding the Concept

**The Core Problem:**
Some data is inherently hierarchical:
- **Org charts**: Employees → Managers → Directors → VPs → CEO
- **Bill of Materials**: Products contain subcomponents contain parts
- **Category trees**: Electronics → Computers → Laptops → Gaming Laptops
- **Social networks**: Friend-of-friend connections
- **File systems**: Folders contain subfolders

**Standard SQL can't loop or traverse these structures.** You'd need separate queries for each level:
```
Level 1: Find CEOs (no manager)
Level 2: Find VPs reporting to CEOs
Level 3: Find Directors reporting to VPs
Level 4: Find Managers... but how deep does it go?
```

**Recursive CTEs solve this:** One query handles arbitrary depth.

---

#### How Recursion Works (Conceptually)

Think of it like following a chain of links:

**1. Anchor Query (Base Case)**
- "Where do I start?"
- Example: "Find all employees with no manager (CEO)"

**2. Recursive Query (Recursive Case)**
- "Given what I found, what's next?"
- Example: "For each person found, find their direct reports"

**3. Repeat**
- Keep finding next level until no more rows
- Each iteration builds on previous iteration's results

**4. Union Results**
- Combine all iterations into final result set

**The Safety Valve:**
Always include a recursion limit! Prevents infinite loops if data has cycles.

---

#### Implementation - All Three Syntaxes

**ANSI SQL (Snowflake & Redshift):**

```sql
-- Basic employee hierarchy
WITH RECURSIVE employee_hierarchy AS (
    -- Anchor: Start with top-level (no manager)
    SELECT 
        employee_id,
        employee_name,
        manager_id,
        1 as level,
        CAST(employee_name AS VARCHAR(1000)) as reporting_chain
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive: Find direct reports of people already found
    SELECT 
        e.employee_id,
        e.employee_name,
        e.manager_id,
        eh.level + 1 as level,
        CAST(eh.reporting_chain || ' → ' || e.employee_name AS VARCHAR(1000)) as reporting_chain
    FROM employees e
    INNER JOIN employee_hierarchy eh 
        ON e.manager_id = eh.employee_id
    WHERE eh.level < 10  -- Safety limit: prevent infinite loops
)
SELECT 
    employee_id,
    employee_name,
    level,
    reporting_chain
FROM employee_hierarchy
ORDER BY level, employee_name;

-- Find all subordinates of a specific manager
WITH RECURSIVE subordinates AS (
    -- Anchor: The manager themselves
    SELECT 
        employee_id,
        employee_name,
        manager_id,
        0 as levels_down
    FROM employees
    WHERE employee_id = 12345  -- Specific manager
    
    UNION ALL
    
    -- Recursive: Find their reports, then reports of reports, etc.
    SELECT 
        e.employee_id,
        e.employee_name,
        e.manager_id,
        s.levels_down + 1
    FROM employees e
    INNER JOIN subordinates s 
        ON e.manager_id = s.employee_id
)
SELECT * FROM subordinates
WHERE levels_down > 0  -- Exclude the manager themselves
ORDER BY levels_down, employee_name;

-- Calculate total team size (including sub-teams)
WITH RECURSIVE team_size AS (
    SELECT 
        employee_id,
        employee_name,
        1 as team_count
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    SELECT 
        e.employee_id,
        e.employee_name,
        ts.team_count + 1
    FROM employees e
    INNER JOIN team_size ts 
        ON e.manager_id = ts.employee_id
)
SELECT 
    employee_name,
    SUM(team_count) as total_team_size
FROM team_size
GROUP BY employee_name
HAVING COUNT(*) > 1  -- Only managers with reports
ORDER BY total_team_size DESC;
```

---

**Snowflake Alternative (CONNECT BY - Oracle Syntax):**

```sql
-- Snowflake also supports Oracle's CONNECT BY syntax
SELECT 
    employee_id,
    employee_name,
    manager_id,
    LEVEL as hierarchy_level,
    SYS_CONNECT_BY_PATH(employee_name, ' → ') as reporting_chain,
    CONNECT_BY_ROOT employee_name as top_level_manager
FROM employees
START WITH manager_id IS NULL  -- Anchor condition
CONNECT BY PRIOR employee_id = manager_id  -- Recursive relationship
ORDER BY hierarchy_level, employee_name;

-- Find all ancestors of an employee
SELECT 
    employee_id,
    employee_name,
    LEVEL as levels_up
FROM employees
START WITH employee_id = 789  -- Specific employee
CONNECT BY employee_id = PRIOR manager_id  -- Walk up the tree
ORDER BY levels_up;

-- Detect cycles (prevent infinite loops)
SELECT 
    employee_id,
    employee_name,
    CONNECT_BY_ISCYCLE as has_cycle
FROM employees
START WITH manager_id IS NULL
CONNECT BY NOCYCLE PRIOR employee_id = manager_id;
```

**Why Two Syntaxes in Snowflake?**
- Recursive CTE: Standard SQL, portable
- CONNECT BY: More concise for simple hierarchies, Oracle-compatible

---

**Redshift (Standard Recursive CTE Only):**

```sql
-- Same as ANSI SQL example above
WITH RECURSIVE employee_hierarchy AS (
    SELECT 
        employee_id,
        employee_name,
        manager_id,
        1 as level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    SELECT 
        e.employee_id,
        e.employee_name,
        e.manager_id,
        eh.level + 1
    FROM employees e
    INNER JOIN employee_hierarchy eh 
        ON e.manager_id = eh.employee_id
    WHERE eh.level < 20  -- Recursion limit
)
SELECT * FROM employee_hierarchy
ORDER BY level, employee_name;
```

**Performance Note for Redshift:**
Recursive CTEs can be expensive on very deep hierarchies (>100 levels). Consider:
- Materializing hierarchy in a table with path/depth pre-computed
- Using nested sets or materialized path pattern for frequent queries

---

#### Real-World Use Cases

**1. Bill of Materials (BOM)**

```sql
-- Find all components needed to build a product
WITH RECURSIVE bom AS (
    -- Anchor: The final product
    SELECT 
        component_id,
        component_name,
        parent_id,
        quantity,
        1 as level,
        quantity as total_quantity
    FROM components
    WHERE component_id = 'PRODUCT-123'
    
    UNION ALL
    
    -- Recursive: Find subcomponents
    SELECT 
        c.component_id,
        c.component_name,
        c.parent_id,
        c.quantity,
        b.level + 1,
        b.total_quantity * c.quantity  -- Multiply quantities down the tree
    FROM components c
    INNER JOIN bom b 
        ON c.parent_id = b.component_id
)
SELECT 
    component_id,
    component_name,
    level,
    SUM(total_quantity) as total_needed
FROM bom
WHERE level > 1  -- Exclude the product itself
GROUP BY component_id, component_name, level
ORDER BY level, component_name;
```

**2. Category Tree (E-commerce)**

```sql
-- Find all subcategories under "Electronics"
WITH RECURSIVE category_tree AS (
    SELECT 
        category_id,
        category_name,
        parent_category_id,
        1 as depth
    FROM categories
    WHERE category_name = 'Electronics'
    
    UNION ALL
    
    SELECT 
        c.category_id,
        c.category_name,
        c.parent_category_id,
        ct.depth + 1
    FROM categories c
    INNER JOIN category_tree ct 
        ON c.parent_category_id = ct.category_id
    WHERE ct.depth < 5  -- Max 5 levels deep
)
SELECT * FROM category_tree
ORDER BY depth, category_name;
```

**3. Social Network (Friend of Friend)**

```sql
-- Find connections within 3 degrees
WITH RECURSIVE connections AS (
    -- Anchor: Direct friends
    SELECT 
        user_id,
        friend_id,
        1 as degree
    FROM friendships
    WHERE user_id = 12345
    
    UNION ALL
    
    -- Recursive: Friends of friends
    SELECT 
        f.user_id,
        f.friend_id,
        c.degree + 1
    FROM friendships f
    INNER JOIN connections c 
        ON f.user_id = c.friend_id
    WHERE c.degree < 3  -- Max 3 degrees of separation
        AND f.friend_id != 12345  -- Don't loop back to original user
)
SELECT DISTINCT
    friend_id,
    MIN(degree) as closest_degree
FROM connections
GROUP BY friend_id
ORDER BY closest_degree, friend_id;
```

---

#### Common Pitfalls and Solutions

**Problem 1: Infinite Loops (Cycles in Data)**

```sql
-- Bad data example:
-- Employee A reports to B
-- Employee B reports to A
-- Result: Infinite recursion!

-- Solution: Add cycle detection
WITH RECURSIVE employee_hierarchy AS (
    SELECT 
        employee_id,
        manager_id,
        1 as level,
        ARRAY[employee_id] as path  -- Track visited nodes
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    SELECT 
        e.employee_id,
        e.manager_id,
        eh.level + 1,
        eh.path || e.employee_id
    FROM employees e
    INNER JOIN employee_hierarchy eh 
        ON e.manager_id = eh.employee_id
    WHERE eh.level < 20
        AND NOT (e.employee_id = ANY(eh.path))  -- Prevent cycles
)
SELECT * FROM employee_hierarchy;
```

**Problem 2: Performance on Deep Hierarchies**

```
Hierarchy depth: 100 levels
Iterations: 100
Each iteration scans previous results
→ Can be very slow
```

**Solutions:**
- Set realistic recursion limit
- Pre-compute and materialize hierarchy
- Use nested sets or materialized path for read-heavy workloads

**Problem 3: Multiple Paths to Same Node**

```sql
-- In some hierarchies, a node can be reached multiple ways
-- Example: Matrix organization where employee has 2 managers

-- Solution: Use DISTINCT or group in final SELECT
SELECT DISTINCT
    employee_id,
    MIN(level) as shortest_path
FROM employee_hierarchy
GROUP BY employee_id;
```

---

### Advanced Aggregations - GROUPING SETS, ROLLUP, CUBE

#### Understanding the Concept

**The Problem:**
You need subtotals at multiple levels, but writing separate GROUP BYs and UNION ALLs is tedious and inefficient.

**Example Need:**
Sales report showing:
- Total by region AND category
- Total by region only
- Total by category only
- Grand total

**Old Way (Inefficient):**
```sql
SELECT region, category, SUM(sales) FROM orders GROUP BY region, category
UNION ALL
SELECT region, NULL, SUM(sales) FROM orders GROUP BY region
UNION ALL
SELECT NULL, category, SUM(sales) FROM orders GROUP BY category
UNION ALL
SELECT NULL, NULL, SUM(sales) FROM orders;
-- Scans table 4 times!
```

**New Way (Efficient):**
```sql
SELECT region, category, SUM(sales)
FROM orders
GROUP BY GROUPING SETS (
    (region, category),  -- Detail level
    (region),            -- Region subtotal
    (category),          -- Category subtotal
    ()                   -- Grand total
);
-- Scans table ONCE!
```

---

#### GROUPING SETS - Custom Aggregation Combinations

**ANSI SQL (Snowflake & Redshift):**

```sql
-- Basic example: Multiple aggregation levels
SELECT 
    region,
    product_category,
    customer_segment,
    SUM(sales_amount) as total_sales,
    COUNT(DISTINCT order_id) as order_count,
    COUNT(DISTINCT customer_id) as customer_count
FROM sales
WHERE order_date >= '2024-01-01'
GROUP BY GROUPING SETS (
    (region, product_category, customer_segment),  -- All three
    (region, product_category),                     -- By region and category
    (region),                                       -- By region only
    (product_category),                            -- By category only
    ()                                             -- Grand total
)
ORDER BY region, product_category, customer_segment;

-- Identify which rows are subtotals using GROUPING()
SELECT 
    region,
    product_category,
    SUM(sales_amount) as total_sales,
    GROUPING(region) as is_region_total,
    GROUPING(product_category) as is_category_total,
    -- Combine flags
    CASE 
        WHEN GROUPING(region) = 1 AND GROUPING(product_category) = 1 
            THEN 'Grand Total'
        WHEN GROUPING(region) = 1 THEN 'Category Total'
        WHEN GROUPING(product_category) = 1 THEN 'Region Total'
        ELSE 'Detail'
    END as aggregation_level
FROM sales
GROUP BY GROUPING SETS (
    (region, product_category),
    (region),
    (product_category),
    ()
);

-- Practical: Replace NULLs with labels
SELECT 
    COALESCE(region, 'All Regions') as region,
    COALESCE(product_category, 'All Categories') as category,
    SUM(sales_amount) as total_sales
FROM sales
GROUP BY GROUPING SETS (
    (region, product_category),
    (region),
    (product_category),
    ()
)
ORDER BY 
    GROUPING(region),           -- Totals first
    region,
    GROUPING(product_category),
    product_category;
```

**Real-World Scenario:**
```sql
-- Executive dashboard: Sales across multiple dimensions
SELECT 
    COALESCE(region, 'ALL') as region,
    COALESCE(TO_CHAR(order_date, 'YYYY-MM'), 'ALL') as month,
    COALESCE(product_line, 'ALL') as product_line,
    SUM(revenue) as revenue,
    SUM(profit) as profit,
    COUNT(DISTINCT customer_id) as customers,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(revenue), 0), 2) as margin_pct
FROM sales
WHERE order_date >= '2024-01-01'
GROUP BY GROUPING SETS (
    (region, order_date, product_line),  -- Full detail
    (region, order_date),                -- By region and month
    (order_date, product_line),          -- By month and product
    (region, product_line),              -- By region and product
    (order_date),                        -- Monthly totals
    (region),                            -- Regional totals
    (product_line),                      -- Product line totals
    ()                                   -- Grand total
);
```

---

#### ROLLUP - Hierarchical Subtotals

**The Concept:**
ROLLUP creates subtotals following a hierarchy from right to left.

```sql
GROUP BY ROLLUP(region, state, city)
-- Creates these groupings automatically:
-- (region, state, city)    -- Most detailed
-- (region, state)           -- State subtotals
-- (region)                  -- Regional subtotals
-- ()                        -- Grand total
```

**Think of it as:** A drill-down report that shows each level of aggregation.

**ANSI SQL (Snowflake & Redshift):**

```sql
-- Geographic hierarchy
SELECT 
    region,
    state,
    city,
    SUM(sales_amount) as total_sales,
    COUNT(*) as transaction_count,
    AVG(sales_amount) as avg_transaction
FROM sales
WHERE order_date >= '2024-01-01'
GROUP BY ROLLUP(region, state, city)
ORDER BY region, state, city;

-- Time hierarchy (Year → Quarter → Month)
SELECT 
    YEAR(order_date) as year,
    QUARTER(order_date) as quarter,
    MONTH(order_date) as month,
    SUM(revenue) as revenue,
    SUM(profit) as profit,
    COUNT(DISTINCT customer_id) as customers
FROM orders
WHERE order_date >= '2023-01-01'
GROUP BY ROLLUP(
    YEAR(order_date),
    QUARTER(order_date),
    MONTH(order_date)
)
ORDER BY year, quarter, month;

-- Partial ROLLUP (only some columns)
SELECT 
    region,
    product_category,
    product_subcategory,
    SUM(sales) as total_sales
FROM sales
GROUP BY region, ROLLUP(product_category, product_subcategory);
-- This creates:
-- (region, category, subcategory)
-- (region, category)
-- (region)  ← Note: Still grouped by region
```

**Practical Example - P&L Report:**
```sql
SELECT 
    COALESCE(account_type, 'TOTAL') as account_type,
    COALESCE(account_category, '  Subtotal') as account_category,
    COALESCE(account_name, '    Detail') as account_name,
    SUM(amount) as amount
FROM general_ledger
WHERE period = '2024-12'
GROUP BY ROLLUP(account_type, account_category, account_name)
ORDER BY account_type, account_category, account_name;

-- Result looks like:
-- Revenue
--   Subtotal                     $1,000,000
--     Product Sales                $800,000
--     Service Revenue              $200,000
-- Expenses
--   Subtotal                      ($600,000)
--     Salaries                     ($400,000)
--     Marketing                    ($200,000)
-- TOTAL                            $400,000
```

---

#### CUBE - All Possible Combinations

**The Concept:**
CUBE generates every possible grouping combination. It's like GROUPING SETS with all combinations automatically generated.

```sql
GROUP BY CUBE(region, product, segment)
-- Creates 2^3 = 8 groupings:
-- (region, product, segment)
-- (region, product)
-- (region, segment)
-- (product, segment)
-- (region)
-- (product)
-- (segment)
-- ()
```

**When to Use:** 
Cross-tabulation analysis where you need every perspective.

**ANSI SQL (Snowflake & Redshift):**

```sql
-- Basic CUBE
SELECT 
    region,
    product_category,
    customer_segment,
    SUM(sales_amount) as total_sales,
    ROUND(AVG(sales_amount), 2) as avg_sale
FROM sales
WHERE order_date >= '2024-01-01'
GROUP BY CUBE(region, product_category, customer_segment)
ORDER BY 
    GROUPING(region),
    GROUPING(product_category),
    GROUPING(customer_segment),
    region,
    product_category,
    customer_segment;

-- Identify grouping level with GROUPING_ID()
SELECT 
    region,
    product_category,
    customer_segment,
    SUM(sales_amount) as total_sales,
    GROUPING_ID(region, product_category, customer_segment) as grouping_level
    -- grouping_level values:
    -- 0 = (region, category, segment) - detail
    -- 1 = (region, category) - segment rolled up
    -- 2 = (region, segment) - category rolled up
    -- 3 = (region) - category and segment rolled up
    -- 4 = (category, segment) - region rolled up
    -- 5 = (category) - region and segment rolled up
    -- 6 = (segment) - region and category rolled up
    -- 7 = () - grand total (all rolled up)
FROM sales
GROUP BY CUBE(region, product_category, customer_segment);

-- Practical: Filter to specific aggregation levels
SELECT *
FROM (
    SELECT 
        region,
        product_category,
        SUM(sales) as total_sales,
        GROUPING_ID(region, product_category) as grp_id
    FROM sales
    GROUP BY CUBE(region, product_category)
) cubed
WHERE grp_id IN (0, 1, 2)  -- Exclude grand total (3)
ORDER BY grp_id, region, product_category;
```

---

#### Performance Considerations

**GROUPING SETS vs Multiple Queries:**

```sql
-- ❌ Inefficient: 4 table scans
SELECT region, SUM(sales) FROM sales GROUP BY region
UNION ALL
SELECT NULL, SUM(sales) FROM sales;

-- ✅ Efficient: 1 table scan
SELECT region, SUM(sales)
FROM sales
GROUP BY GROUPING SETS ((region), ());
```

**CUBE Explosion Warning:**

```sql
-- CUBE with 5 dimensions = 2^5 = 32 grouping combinations
-- CUBE with 10 dimensions = 2^10 = 1,024 combinations!

-- Instead, use GROUPING SETS with only needed combinations
GROUP BY GROUPING SETS (
    (dim1, dim2, dim3),
    (dim1, dim2),
    (dim1),
    ()
)
-- Much more efficient than CUBE if you don't need all combinations
```

**Redshift Specific:**
```sql
-- For very large aggregations in Redshift, consider:
-- 1. Pre-aggregating in a temp table
CREATE TEMP TABLE aggregated AS
SELECT region, product, SUM(sales) as sales
FROM sales
GROUP BY region, product;

-- 2. Then apply GROUPING SETS on aggregated data
SELECT *
FROM aggregated
GROUP BY GROUPING SETS ((region, product), (region), ());
```

---

### Finding Duplicates and Gaps - Data Quality Patterns

#### Understanding the Concept

**The Core Problems:**

**1. Duplicates** = Same record appears multiple times
- Source system sent duplicates
- ETL process ran twice
- Merging datasets without dedup

**2. Gaps** = Missing records in a sequence
- Orders: #1001, #1002, #1004 (missing #1003)
- Dates: Jan 1, Jan 2, Jan 4 (missing Jan 3)
- Time series with missing readings

Both are **data quality issues** that need detection and resolution.

---

#### Finding and Handling Duplicates

**Pattern 1: Identify Duplicate Counts**

**ANSI SQL (All Three Platforms):**

```sql
-- Find which values are duplicated and how many times
SELECT 
    email,
    COUNT(*) as duplicate_count,
    MIN(created_date) as first_occurrence,
    MAX(created_date) as last_occurrence,
    MAX(created_date) - MIN(created_date) as days_between
FROM users
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, email;

-- Find duplicates across multiple columns
SELECT 
    customer_id,
    order_date,
    product_id,
    COUNT(*) as duplicate_count,
    STRING_AGG(order_id::VARCHAR, ', ') as duplicate_order_ids  -- Snowflake/Redshift
FROM orders
GROUP BY customer_id, order_date, product_id
HAVING COUNT(*) > 1;
```

---

**Pattern 2: Show All Duplicate Rows (Including Original)**

**Snowflake (With QUALIFY):**

```sql
-- Show all rows where email appears more than once
SELECT 
    user_id,
    email,
    created_date,
    COUNT(*) OVER (PARTITION BY email) as times_email_appears
FROM users
QUALIFY COUNT(*) OVER (PARTITION BY email) > 1
ORDER BY email, created_date;
```

**ANSI SQL / Redshift (Subquery Approach):**

```sql
-- Same result, different syntax
SELECT 
    user_id,
    email,
    created_date,
    dup_count
FROM (
    SELECT 
        user_id,
        email,
        created_date,
        COUNT(*) OVER (PARTITION BY email) as dup_count
    FROM users
) WITH_COUNTS
WHERE dup_count > 1
ORDER BY email, created_date;

-- Or using JOIN
SELECT 
    u.*,
    dups.duplicate_count
FROM users u
INNER JOIN (
    SELECT email, COUNT(*) as duplicate_count
    FROM users
    GROUP BY email
    HAVING COUNT(*) > 1
) dups ON u.email = dups.email
ORDER BY u.email, u.created_date;
```

---

**Pattern 3: Deduplication - Keep One, Remove Rest**

**Strategy:** Use ROW_NUMBER() to identify which row to keep.

**Snowflake:**

```sql
-- Delete all but the most recent record per email
DELETE FROM users
WHERE user_id NOT IN (
    SELECT user_id
    FROM (
        SELECT 
            user_id,
            ROW_NUMBER() OVER (
                PARTITION BY email 
                ORDER BY created_date DESC  -- Keep most recent
            ) as rn
        FROM users
    ) ranked
    WHERE rn = 1
);

-- Or using QUALIFY for clarity
CREATE OR REPLACE TABLE users_deduped AS
SELECT *
FROM users
QUALIFY ROW_NUMBER() OVER (PARTITION BY email ORDER BY created_date DESC) = 1;
```

**Redshift:**

```sql
-- Redshift approach: CREATE TABLE AS (more efficient than DELETE)
CREATE TABLE users_deduped AS
SELECT *
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY email 
            ORDER BY created_date DESC, user_id DESC  -- Tie-breaker
        ) as rn
    FROM users
) ranked
WHERE rn = 1;

-- Swap tables
DROP TABLE users;
ALTER TABLE users_deduped RENAME TO users;

-- Recreate constraints and grants
ALTER TABLE users ADD PRIMARY KEY (user_id);
GRANT SELECT ON users TO reporting_role;
```

**Choosing Which Record to Keep:**

```sql
-- Keep the FIRST occurrence (oldest)
ORDER BY created_date ASC

-- Keep the LAST occurrence (newest)
ORDER BY created_date DESC

-- Keep the most complete record (fewest NULLs)
ORDER BY 
    CASE WHEN phone IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN address IS NOT NULL THEN 1 ELSE 0 END DESC,
    created_date DESC

-- Keep the one with highest priority flag
ORDER BY is_verified DESC, created_date DESC
```

---

#### Finding Gaps in Sequential Data

**Pattern 1: Using LEAD to Find Missing Numbers**

**ANSI SQL (Snowflake & Redshift):**

```sql
-- Find gaps in order_id sequence
SELECT 
    order_id,
    LEAD(order_id) OVER (ORDER BY order_id) as next_order_id,
    LEAD(order_id) OVER (ORDER BY order_id) - order_id as gap_size,
    CASE 
        WHEN LEAD(order_id) OVER (ORDER BY order_id) - order_id > 1 
        THEN order_id + 1  -- First missing ID
    END as gap_start,
    CASE 
        WHEN LEAD(order_id) OVER (ORDER BY order_id) - order_id > 1 
        THEN LEAD(order_id) OVER (ORDER BY order_id) - 1  -- Last missing ID
    END as gap_end
FROM orders
WHERE LEAD(order_id) OVER (ORDER BY order_id) - order_id > 1
ORDER BY order_id;

-- Cleaner output
SELECT 
    order_id + 1 as gap_start,
    next_order_id - 1 as gap_end,
    (next_order_id - order_id - 1) as missing_count
FROM (
    SELECT 
        order_id,
        LEAD(order_id) OVER (ORDER BY order_id) as next_order_id
    FROM orders
) WITH_NEXT
WHERE next_order_id - order_id > 1
ORDER BY gap_start;
```

---

**Pattern 2: Generate Expected Sequence, Find Missing**

**Snowflake (Using GENERATOR):**

```sql
-- Create a complete sequence and find what's missing
WITH expected_ids AS (
    SELECT SEQ4() as expected_order_id
    FROM TABLE(GENERATOR(ROWCOUNT => 100000))
    WHERE SEQ4() BETWEEN 
        (SELECT MIN(order_id) FROM orders) AND 
        (SELECT MAX(order_id) FROM orders)
),
actual_ids AS (
    SELECT DISTINCT order_id FROM orders
)
SELECT 
    e.expected_order_id as missing_order_id
FROM expected_ids e
LEFT JOIN actual_ids a ON e.expected_order_id = a.order_id
WHERE a.order_id IS NULL
ORDER BY e.expected_order_id;

-- For date gaps
WITH date_series AS (
    SELECT DATEADD(day, SEQ4(), '2024-01-01'::DATE) as expected_date
    FROM TABLE(GENERATOR(ROWCOUNT => 365))
)
SELECT d.expected_date as missing_date
FROM date_series d
LEFT JOIN (SELECT DISTINCT order_date FROM orders WHERE YEAR(order_date) = 2024) o
    ON d.expected_date = o.order_date
WHERE o.order_date IS NULL
ORDER BY d.expected_date;
```

---

**Redshift (Using Series Generation):**

```sql
-- Generate series using row_number
WITH RECURSIVE number_series AS (
    -- Anchor: Start
    SELECT 
        (SELECT MIN(order_id) FROM orders) as num
    
    UNION ALL
    
    -- Recursive: Increment
    SELECT num + 1
    FROM number_series
    WHERE num < (SELECT MAX(order_id) FROM orders)
)
SELECT 
    ns.num as missing_order_id
FROM number_series ns
LEFT JOIN orders o ON ns.num = o.order_id
WHERE o.order_id IS NULL
ORDER BY ns.num;

-- More efficient for large ranges: Use generate_series (if available)
-- Or create a numbers table once and reuse
CREATE TABLE numbers AS
SELECT ROW_NUMBER() OVER (ORDER BY 1) as num
FROM (SELECT 1 FROM orders LIMIT 1000000);

-- Then use it
SELECT n.num as missing_id
FROM numbers n
LEFT JOIN orders o ON n.num = o.order_id
WHERE n.num BETWEEN 1 AND 100000
    AND o.order_id IS NULL;
```

---

**Pattern 3: Time-Series Gap Detection**

**ANSI SQL (All Platforms):**

```sql
-- Find days with no data
SELECT 
    date,
    LAG(date) OVER (ORDER BY date) as prev_date,
    date - LAG(date) OVER (ORDER BY date) as days_since_last,
    CASE 
        WHEN date - LAG(date) OVER (ORDER BY date) > 1 
        THEN 'GAP DETECTED'
    END as status
FROM (
    SELECT DISTINCT order_date as date 
    FROM orders
    WHERE order_date >= '2024-01-01'
) dates
WHERE date - LAG(date) OVER (ORDER BY date) > 1
ORDER BY date;

-- Fill gaps with NULLs for visualization
WITH RECURSIVE date_range AS (
    SELECT DATE '2024-01-01' as date
    UNION ALL
    SELECT date + INTERVAL '1 day'
    FROM date_range
    WHERE date < DATE '2024-12-31'
)
SELECT 
    dr.date,
    o.total_orders,
    o.total_revenue,
    CASE 
        WHEN o.total_orders IS NULL THEN 'No Data'
        ELSE 'Has Data'
    END as data_status
FROM date_range dr
LEFT JOIN (
    SELECT 
        order_date,
        COUNT(*) as total_orders,
        SUM(amount) as total_revenue
    FROM orders
    GROUP BY order_date
) o ON dr.date = o.order_date
ORDER BY dr.date;
```

---

#### Real-World Scenarios

**Scenario 1: ETL Ran Twice**

```sql
-- Detect and remove duplicate loads
-- Assuming records have load_timestamp

-- 1. Find duplicate batches
SELECT 
    load_timestamp,
    COUNT(*) as records_loaded,
    COUNT(DISTINCT order_id) as unique_orders,
    COUNT(*) - COUNT(DISTINCT order_id) as duplicates
FROM staging_orders
GROUP BY load_timestamp
HAVING COUNT(*) > COUNT(DISTINCT order_id);

-- 2. Keep only first load per order
CREATE TABLE orders_clean AS
SELECT *
FROM staging_orders
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY order_id 
    ORDER BY load_timestamp ASC  -- Keep first
) = 1;
```

**Scenario 2: Merging Datasets**

```sql
-- Merge two sources, remove overlapping duplicates
WITH combined AS (
    SELECT *, 'source_a' as source FROM source_a
    UNION ALL
    SELECT *, 'source_b' as source FROM source_b
)
SELECT *
FROM combined
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY 
        CASE source 
            WHEN 'source_a' THEN 1  -- Prefer source_a
            WHEN 'source_b' THEN 2
        END,
        updated_at DESC  -- Then most recent
) = 1;
```

**Scenario 3: Sequence Validation**

```sql
-- Ensure no invoices skipped (fraud detection)
WITH invoice_gaps AS (
    SELECT 
        invoice_id,
        LEAD(invoice_id) OVER (ORDER BY invoice_id) - invoice_id - 1 as gap_size
    FROM invoices
    WHERE invoice_date >= '2024-01-01'
)
SELECT 
    invoice_id,
    gap_size,
    'ALERT: Potential missing invoice' as status
FROM invoice_gaps
WHERE gap_size > 0
ORDER BY invoice_id;
```

---

This is getting quite long! Should I continue with the remaining sections (Stored Procedures, Clustering/Sort Keys, Query Optimization, Python, DBT, Snowflake/Redshift specifics, and Interview Strategy)?

Or would you like me to package what we have so far and then continue with the remaining sections?


---

### Stored Procedures - Orchestrating Complex Logic

#### Understanding the Concept

**The Core Problem:**
SQL is great for set-based operations (SELECT, JOIN, GROUP BY), but sometimes you need **procedural logic**:
- IF this THEN that ELSE something else
- LOOP through results
- TRY an operation, IF error THEN handle it
- Multiple steps that must execute in sequence
- Complex error handling and rollback scenarios

**The Fundamental Question:**
"Should this logic live in the database or in the application?"

---

#### The Strategic Trade-Off

**Database (Stored Procedures):**

✅ **Advantages:**
- **Atomic transactions**: All-or-nothing operations with COMMIT/ROLLBACK
- **Reduced network round-trips**: One call executes multiple operations
- **Centralized logic**: Same code regardless of calling application
- **Security**: Grant EXECUTE permission without direct table access
- **Performance**: Data doesn't leave the database for processing

❌ **Disadvantages:**
- **Hard to test**: No unit testing frameworks like app code
- **Version control challenges**: Database code harder to track than Git
- **Limited debugging**: Poor IDE support compared to Python/Java
- **Database-specific syntax**: Not portable across platforms
- **Team silos**: DBAs vs software engineers

**Application (Python/Java/etc):**

✅ **Advantages:**
- **Testability**: Full unit/integration test suites
- **Version control**: Git, code review, CI/CD pipelines
- **Debugging**: Rich IDE support, breakpoints, stack traces
- **Portability**: Switch databases without rewriting logic
- **Team collaboration**: Engineers own the full stack

❌ **Disadvantages:**
- **Network overhead**: Multiple round-trips to database
- **Transaction complexity**: Harder to coordinate across services
- **Code duplication**: Multiple apps = multiple implementations
- **Data transfer**: Moving large datasets out of database

---

#### When to Use Stored Procedures

**Decision Framework:**

**Use Stored Procedures When:**

1. **Complex ETL orchestration with transactions**
   ```
   Load → Validate → Transform → Merge → Log → Cleanup
   All must succeed or all must rollback
   ```

2. **Data integrity enforcement beyond constraints**
   - Cross-table validation rules
   - Complex business logic that must be enforced database-side
   - Audit logging that can't be bypassed

3. **Performance-critical batch operations**
   - Processing millions of rows in-database
   - Avoiding network transfer of large datasets
   - Complex aggregations better done server-side

4. **Scheduled database-native jobs**
   - Nightly aggregations (paired with Snowflake Tasks/Redshift cron)
   - Data archival and cleanup
   - Maintenance operations (VACUUM, ANALYZE)

**Use Application Code When:**
- Business rules change frequently (need agility)
- Complex testing required
- External API integrations
- Real-time user interactions
- Microservices architecture

**Best Practice: Hybrid Approach**
- Stored procedures for: Data movement, validation, archival
- Application code for: Business logic, API calls, user workflows
- DBT for: Transformations and data modeling

---

#### Snowflake Stored Procedures

Snowflake supports **three languages**: JavaScript (most common), SQL Scripting, and Python (Snowpark).

**JavaScript Procedures (Most Flexible)**

**When to Use JavaScript:**
- Complex procedural logic with loops and conditions
- Error handling with try/catch
- Dynamic SQL construction
- JSON manipulation

```sql
-- Complete ETL orchestration example
CREATE OR REPLACE PROCEDURE daily_sales_etl(load_date DATE)
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    // Result object to track what happened
    var result = {
        rows_loaded: 0,
        rows_validated: 0,
        rows_merged: 0,
        errors: []
    };
    
    try {
        // Step 1: Truncate staging table
        snowflake.execute({ 
            sqlText: "TRUNCATE TABLE staging.daily_sales" 
        });
        
        // Step 2: Load from S3 into staging
        var loadSql = `
            COPY INTO staging.daily_sales
            FROM @s3_stage/sales/${LOAD_DATE}/
            FILE_FORMAT = (TYPE = 'PARQUET')
            ON_ERROR = 'ABORT_STATEMENT'
        `;
        var loadStmt = snowflake.createStatement({ sqlText: loadSql });
        loadStmt.execute();
        result.rows_loaded = loadStmt.getNumRowsAffected();
        
        // Step 3: Data quality validation
        var validateSql = `
            SELECT 
                COUNT(*) as invalid_count,
                STRING_AGG(error_type, ', ') as error_types
            FROM (
                SELECT 
                    CASE 
                        WHEN amount <= 0 THEN 'negative_amount'
                        WHEN customer_id IS NULL THEN 'missing_customer'
                        WHEN product_id IS NULL THEN 'missing_product'
                        WHEN sale_date != '${LOAD_DATE}' THEN 'wrong_date'
                    END as error_type
                FROM staging.daily_sales
                WHERE amount <= 0 
                   OR customer_id IS NULL 
                   OR product_id IS NULL
                   OR sale_date != '${LOAD_DATE}'
            )
        `;
        
        var validateResult = snowflake.execute({ sqlText: validateSql });
        validateResult.next();
        var invalidCount = validateResult.getColumnValue('INVALID_COUNT');
        
        if (invalidCount > 0) {
            var errorTypes = validateResult.getColumnValue('ERROR_TYPES');
            throw new Error(`Data quality check failed: ${invalidCount} invalid rows. Errors: ${errorTypes}`);
        }
        
        result.rows_validated = result.rows_loaded;
        
        // Step 4: Merge into production
        var mergeSql = `
            MERGE INTO prod.sales p
            USING staging.daily_sales s
                ON p.sale_id = s.sale_id
            WHEN MATCHED AND p.amount != s.amount THEN 
                UPDATE SET 
                    p.amount = s.amount,
                    p.updated_at = CURRENT_TIMESTAMP(),
                    p.updated_by = CURRENT_USER()
            WHEN NOT MATCHED THEN
                INSERT (
                    sale_id, customer_id, product_id, 
                    sale_date, amount, quantity,
                    created_at, created_by
                )
                VALUES (
                    s.sale_id, s.customer_id, s.product_id,
                    s.sale_date, s.amount, s.quantity,
                    CURRENT_TIMESTAMP(), CURRENT_USER()
                )
        `;
        
        var mergeStmt = snowflake.createStatement({ sqlText: mergeSql });
        mergeStmt.execute();
        result.rows_merged = mergeStmt.getNumRowsAffected();
        
        // Step 5: Archive staging to history table
        snowflake.execute({
            sqlText: `
                INSERT INTO history.daily_sales_loads
                SELECT *, CURRENT_TIMESTAMP() as archived_at
                FROM staging.daily_sales
            `
        });
        
        // Step 6: Log success
        snowflake.execute({
            sqlText: `
                INSERT INTO etl_log (
                    process_name, load_date, 
                    rows_loaded, rows_merged, 
                    status, duration_seconds, log_time
                )
                VALUES (
                    'daily_sales_etl', 
                    '${LOAD_DATE}', 
                    ${result.rows_loaded}, 
                    ${result.rows_merged},
                    'SUCCESS',
                    DATEDIFF('second', '${new Date().toISOString()}', CURRENT_TIMESTAMP()),
                    CURRENT_TIMESTAMP()
                )
            `
        });
        
        return `SUCCESS: Loaded ${result.rows_loaded} rows, merged ${result.rows_merged} rows for ${LOAD_DATE}`;
        
    } catch (err) {
        // Log error with context
        snowflake.execute({
            sqlText: `
                INSERT INTO etl_error_log (
                    process_name, load_date,
                    error_message, error_stack,
                    rows_loaded_before_error, error_time
                )
                VALUES (
                    'daily_sales_etl',
                    '${LOAD_DATE}',
                    '${err.message.replace(/'/g, "''")}',
                    '${err.stack ? err.stack.replace(/'/g, "''") : ""}',
                    ${result.rows_loaded},
                    CURRENT_TIMESTAMP()
                )
            `
        });
        
        // Rollback changes if needed
        snowflake.execute({ sqlText: "ROLLBACK" });
        
        return `ERROR: ${err.message}`;
    }
$$;

-- Execute the procedure
CALL daily_sales_etl('2024-12-10');

-- Check results
SELECT * FROM etl_log ORDER BY log_time DESC LIMIT 10;
SELECT * FROM etl_error_log ORDER BY error_time DESC LIMIT 10;
```

**Key JavaScript Patterns:**

```sql
-- Pattern 1: Dynamic SQL with loops
CREATE OR REPLACE PROCEDURE process_all_regions()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    var regions = ['US', 'EU', 'APAC', 'LATAM'];
    var totalProcessed = 0;
    
    for (var i = 0; i < regions.length; i++) {
        var region = regions[i];
        
        var sql = `
            UPDATE customer_metrics
            SET metrics_updated_at = CURRENT_TIMESTAMP()
            WHERE region = '${region}'
        `;
        
        var stmt = snowflake.createStatement({ sqlText: sql });
        stmt.execute();
        totalProcessed += stmt.getNumRowsAffected();
    }
    
    return `Processed ${totalProcessed} customers across ${regions.length} regions`;
$$;

-- Pattern 2: Query result iteration
CREATE OR REPLACE PROCEDURE archive_old_partitions()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    var partitionsToArchive = [];
    
    // Find partitions older than 90 days
    var findSql = `
        SELECT DISTINCT partition_date
        FROM sales_partitioned
        WHERE partition_date < DATEADD('day', -90, CURRENT_DATE())
        ORDER BY partition_date
    `;
    
    var rs = snowflake.execute({ sqlText: findSql });
    
    while (rs.next()) {
        var partDate = rs.getColumnValue(1);
        partitionsToArchive.push(partDate);
    }
    
    // Archive each partition
    for (var i = 0; i < partitionsToArchive.length; i++) {
        var date = partitionsToArchive[i];
        
        snowflake.execute({
            sqlText: `
                CREATE TABLE archive.sales_${date.replace(/-/g, '')} AS
                SELECT * FROM sales_partitioned
                WHERE partition_date = '${date}'
            `
        });
        
        snowflake.execute({
            sqlText: `
                DELETE FROM sales_partitioned
                WHERE partition_date = '${date}'
            `
        });
    }
    
    return `Archived ${partitionsToArchive.length} partitions`;
$$;

-- Pattern 3: Conditional logic
CREATE OR REPLACE PROCEDURE smart_aggregation(table_name STRING, force_full_refresh BOOLEAN)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    var lastRunTime = null;
    
    // Check when last run
    var checkSql = `
        SELECT MAX(run_time) as last_run
        FROM aggregation_log
        WHERE table_name = '${TABLE_NAME}'
    `;
    
    var rs = snowflake.execute({ sqlText: checkSql });
    if (rs.next()) {
        lastRunTime = rs.getColumnValue('LAST_RUN');
    }
    
    var sql;
    
    if (FORCE_FULL_REFRESH || lastRunTime === null) {
        // Full refresh
        sql = `
            CREATE OR REPLACE TABLE ${TABLE_NAME}_aggregated AS
            SELECT customer_id, SUM(amount) as total
            FROM ${TABLE_NAME}
            GROUP BY customer_id
        `;
    } else {
        // Incremental update
        sql = `
            MERGE INTO ${TABLE_NAME}_aggregated t
            USING (
                SELECT customer_id, SUM(amount) as total
                FROM ${TABLE_NAME}
                WHERE updated_at > '${lastRunTime}'
                GROUP BY customer_id
            ) s
            ON t.customer_id = s.customer_id
            WHEN MATCHED THEN UPDATE SET t.total = t.total + s.total
            WHEN NOT MATCHED THEN INSERT (customer_id, total) VALUES (s.customer_id, s.total)
        `;
    }
    
    snowflake.execute({ sqlText: sql });
    
    return FORCE_FULL_REFRESH ? 'Full refresh completed' : 'Incremental update completed';
$$;
```

---

**SQL Scripting (Simpler Syntax)**

**When to Use SQL Scripting:**
- Simpler procedural logic
- Mainly SQL operations with some IF/LOOP
- Easier for SQL-focused team members

```sql
-- Sales metrics update with SQL scripting
CREATE OR REPLACE PROCEDURE update_customer_metrics()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    rows_updated INTEGER DEFAULT 0;
    rows_inserted INTEGER DEFAULT 0;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    error_message STRING;
BEGIN
    start_time := CURRENT_TIMESTAMP();
    
    -- Create temp table with latest metrics
    CREATE OR REPLACE TEMPORARY TABLE temp_metrics AS
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) as total_orders,
        SUM(amount) as lifetime_value,
        MAX(order_date) as last_order_date,
        MIN(order_date) as first_order_date,
        AVG(amount) as avg_order_value,
        DATEDIFF('day', MIN(order_date), MAX(order_date)) as customer_tenure_days,
        COUNT(DISTINCT CASE WHEN order_date >= DATEADD('day', -30, CURRENT_DATE()) THEN order_id END) as orders_last_30d
    FROM orders
    WHERE status IN ('completed', 'shipped')
    GROUP BY customer_id;
    
    -- Update existing customers
    UPDATE customers c
    SET 
        c.total_orders = t.total_orders,
        c.lifetime_value = t.lifetime_value,
        c.last_order_date = t.last_order_date,
        c.first_order_date = t.first_order_date,
        c.avg_order_value = t.avg_order_value,
        c.customer_tenure_days = t.customer_tenure_days,
        c.orders_last_30d = t.orders_last_30d,
        c.updated_at = CURRENT_TIMESTAMP()
    FROM temp_metrics t
    WHERE c.customer_id = t.customer_id;
    
    rows_updated := SQLROWCOUNT;
    
    -- Insert new customers
    INSERT INTO customers (
        customer_id, total_orders, lifetime_value,
        last_order_date, first_order_date, avg_order_value,
        customer_tenure_days, orders_last_30d, created_at
    )
    SELECT 
        t.customer_id, t.total_orders, t.lifetime_value,
        t.last_order_date, t.first_order_date, t.avg_order_value,
        t.customer_tenure_days, t.orders_last_30d, CURRENT_TIMESTAMP()
    FROM temp_metrics t
    WHERE NOT EXISTS (
        SELECT 1 FROM customers c WHERE c.customer_id = t.customer_id
    );
    
    rows_inserted := SQLROWCOUNT;
    
    end_time := CURRENT_TIMESTAMP();
    
    -- Log execution
    INSERT INTO process_log (
        process_name, rows_updated, rows_inserted,
        duration_seconds, execution_time
    )
    VALUES (
        'update_customer_metrics',
        :rows_updated,
        :rows_inserted,
        DATEDIFF('second', :start_time, :end_time),
        :end_time
    );
    
    RETURN 'Updated ' || rows_updated || ' customers, inserted ' || 
           rows_inserted || ' new customers in ' || 
           DATEDIFF('second', start_time, end_time) || ' seconds';
           
EXCEPTION
    WHEN OTHER THEN
        error_message := SQLERRM;
        INSERT INTO error_log (
            process_name, error_message, error_time
        )
        VALUES (
            'update_customer_metrics',
            :error_message,
            CURRENT_TIMESTAMP()
        );
        RETURN 'ERROR: ' || error_message;
END;
$$;

-- Conditional logic example
CREATE OR REPLACE PROCEDURE process_orders(order_type STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    processed_count INTEGER;
BEGIN
    IF (order_type = 'express') THEN
        UPDATE orders 
        SET priority = 1, processing_fee = 10.00
        WHERE order_type = 'express' AND status = 'pending';
        
    ELSEIF (order_type = 'standard') THEN
        UPDATE orders
        SET priority = 5, processing_fee = 5.00
        WHERE order_type = 'standard' AND status = 'pending';
        
    ELSE
        RETURN 'ERROR: Invalid order type';
    END IF;
    
    processed_count := SQLROWCOUNT;
    RETURN 'Processed ' || processed_count || ' ' || order_type || ' orders';
END;
$$;

-- Loop example
CREATE OR REPLACE PROCEDURE backfill_dates(start_date DATE, end_date DATE)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    current_date DATE;
    total_days INTEGER DEFAULT 0;
BEGIN
    current_date := start_date;
    
    WHILE (current_date <= end_date) DO
        INSERT INTO date_dimension (date, year, month, day, day_of_week)
        VALUES (
            current_date,
            YEAR(current_date),
            MONTH(current_date),
            DAY(current_date),
            DAYOFWEEK(current_date)
        );
        
        current_date := DATEADD('day', 1, current_date);
        total_days := total_days + 1;
    END WHILE;
    
    RETURN 'Backfilled ' || total_days || ' dates';
END;
$$;
```

---

**Python (Snowpark) - Advanced Analytics**

**When to Use Python:**
- Machine learning workflows
- Complex data science operations
- Integration with Python libraries (pandas, scikit-learn)
- Advanced statistical analysis

```sql
CREATE OR REPLACE PROCEDURE customer_segmentation(min_order_count INTEGER)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('snowflake-snowpark-python', 'pandas', 'scikit-learn', 'numpy')
HANDLER = 'segment_customers'
AS
$$
import snowflake.snowpark as snowpark
from snowflake.snowpark.functions import col, count, sum as sum_, avg, stddev
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
import numpy as np

def segment_customers(session: snowpark.Session, min_order_count: int) -> str:
    try:
        # Read customer order data
        customers_sf = session.table('customers')
        orders_sf = session.table('orders')
        
        # Calculate customer features in Snowflake
        customer_features_sf = orders_sf.group_by('customer_id').agg(
            count('order_id').alias('total_orders'),
            sum_('amount').alias('total_spent'),
            avg('amount').alias('avg_order_value'),
            stddev('amount').alias('stddev_order_value')
        )
        
        # Filter customers with minimum orders
        customer_features_sf = customer_features_sf.filter(
            col('total_orders') >= min_order_count
        )
        
        # Convert to Pandas for ML
        customer_features_pd = customer_features_sf.to_pandas()
        
        if len(customer_features_pd) < 10:
            return f"Not enough customers ({len(customer_features_pd)}) for segmentation"
        
        # Prepare features for clustering
        feature_cols = ['total_orders', 'total_spent', 'avg_order_value']
        X = customer_features_pd[feature_cols].fillna(0)
        
        # Standardize features
        scaler = StandardScaler()
        X_scaled = scaler.fit_transform(X)
        
        # Determine optimal number of clusters (elbow method)
        inertias = []
        K_range = range(2, min(11, len(customer_features_pd) // 10))
        
        for k in K_range:
            kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
            kmeans.fit(X_scaled)
            inertias.append(kmeans.inertia_)
        
        # Use 4 clusters (or fewer if not enough data)
        optimal_k = min(4, len(K_range))
        
        # Perform clustering
        kmeans = KMeans(n_clusters=optimal_k, random_state=42, n_init=10)
        customer_features_pd['segment'] = kmeans.fit_predict(X_scaled)
        
        # Add segment labels based on characteristics
        segment_stats = customer_features_pd.groupby('segment').agg({
            'total_orders': 'mean',
            'total_spent': 'mean',
            'customer_id': 'count'
        }).reset_index()
        
        # Label segments
        segment_stats = segment_stats.sort_values('total_spent', ascending=False)
        segment_stats['segment_name'] = [
            'VIP', 'High Value', 'Medium Value', 'Low Value'
        ][:len(segment_stats)]
        
        # Map labels back
        segment_map = dict(zip(
            segment_stats['segment'], 
            segment_stats['segment_name']
        ))
        customer_features_pd['segment_name'] = customer_features_pd['segment'].map(segment_map)
        
        # Add cluster centers info
        centers = scaler.inverse_transform(kmeans.cluster_centers_)
        customer_features_pd['distance_to_center'] = [
            np.linalg.norm(X_scaled[i] - kmeans.cluster_centers_[customer_features_pd['segment'].iloc[i]])
            for i in range(len(customer_features_pd))
        ]
        
        # Write results back to Snowflake
        result_df = session.create_dataframe(customer_features_pd)
        result_df.write.mode('overwrite').save_as_table('customer_segments')
        
        # Create segment statistics table
        stats_df = session.create_dataframe(segment_stats)
        stats_df.write.mode('overwrite').save_as_table('segment_statistics')
        
        # Log the execution
        session.sql(f"""
            INSERT INTO ml_log (
                model_name, execution_time, customers_processed, 
                num_segments, min_order_count
            )
            VALUES (
                'customer_segmentation',
                CURRENT_TIMESTAMP(),
                {len(customer_features_pd)},
                {optimal_k},
                {min_order_count}
            )
        """).collect()
        
        return f"SUCCESS: Segmented {len(customer_features_pd)} customers into {optimal_k} segments"
        
    except Exception as e:
        # Log error
        error_msg = str(e).replace("'", "''")
        session.sql(f"""
            INSERT INTO ml_error_log (model_name, error_message, error_time)
            VALUES ('customer_segmentation', '{error_msg}', CURRENT_TIMESTAMP())
        """).collect()
        
        return f"ERROR: {str(e)}"
$$;

-- Execute segmentation
CALL customer_segmentation(5);

-- View results
SELECT * FROM customer_segments LIMIT 100;
SELECT * FROM segment_statistics;

-- Simpler Python example: Data quality scoring
CREATE OR REPLACE PROCEDURE score_data_quality(table_name STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('snowflake-snowpark-python', 'pandas')
HANDLER = 'score_quality'
AS
$$
import pandas as pd

def score_quality(session, table_name):
    # Read table
    df = session.table(table_name).to_pandas()
    
    # Calculate quality metrics
    total_rows = len(df)
    total_cells = total_rows * len(df.columns)
    
    metrics = {
        'total_rows': total_rows,
        'total_columns': len(df.columns),
        'null_count': df.isnull().sum().sum(),
        'null_percentage': (df.isnull().sum().sum() / total_cells * 100),
        'duplicate_rows': df.duplicated().sum(),
        'duplicate_percentage': (df.duplicated().sum() / total_rows * 100)
    }
    
    # Calculate quality score (0-100)
    score = 100 - (metrics['null_percentage'] * 0.5) - (metrics['duplicate_percentage'] * 0.5)
    metrics['quality_score'] = max(0, min(100, score))
    
    # Write results
    results_df = pd.DataFrame([metrics])
    results_df['table_name'] = table_name
    results_df['scored_at'] = pd.Timestamp.now()
    
    session.create_dataframe(results_df).write.mode('append').save_as_table('data_quality_scores')
    
    return f"Quality score for {table_name}: {metrics['quality_score']:.2f}/100"
$$;
```

---

#### Redshift Stored Procedures (PL/pgSQL)

Redshift uses PostgreSQL's PL/pgSQL procedural language.

**Basic Structure:**

```sql
CREATE OR REPLACE PROCEDURE load_daily_orders(target_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    rows_loaded INTEGER;
    rows_merged INTEGER;
    start_time TIMESTAMP;
    v_error_message TEXT;
BEGIN
    start_time := CLOCK_TIMESTAMP();
    
    -- Step 1: Clear staging
    TRUNCATE staging.daily_orders;
    
    -- Step 2: Load data from S3
    EXECUTE format('
        COPY staging.daily_orders
        FROM ''s3://mybucket/orders/%s/''
        IAM_ROLE ''arn:aws:iam::123456789:role/RedshiftRole''
        FORMAT AS PARQUET
        ', target_date);
    
    GET DIAGNOSTICS rows_loaded = ROW_COUNT;
    
    -- Step 3: Data validation
    IF EXISTS (
        SELECT 1 FROM staging.daily_orders
        WHERE amount <= 0 OR customer_id IS NULL
    ) THEN
        RAISE EXCEPTION 'Data quality check failed: Invalid rows found';
    END IF;
    
    -- Step 4: Delete existing records (Redshift doesn't have MERGE)
    DELETE FROM prod.orders
    WHERE order_date = target_date;
    
    -- Step 5: Insert all staging records
    INSERT INTO prod.orders
    SELECT * FROM staging.daily_orders;
    
    GET DIAGNOSTICS rows_merged = ROW_COUNT;
    
    -- Step 6: Log success
    INSERT INTO etl_log (
        process_name, 
        target_date, 
        rows_loaded, 
        rows_merged,
        duration_seconds,
        log_time
    )
    VALUES (
        'load_daily_orders',
        target_date,
        rows_loaded,
        rows_merged,
        EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - start_time)),
        CLOCK_TIMESTAMP()
    );
    
    RAISE NOTICE 'Successfully loaded % orders for %', rows_loaded, target_date;
    
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_message = MESSAGE_TEXT;
        
        -- Log error
        INSERT INTO error_log (
            process_name, 
            error_message, 
            error_time
        )
        VALUES (
            'load_daily_orders',
            v_error_message,
            CLOCK_TIMESTAMP()
        );
        
        RAISE EXCEPTION 'Error in load_daily_orders: %', v_error_message;
END;
$$;

-- Execute
CALL load_daily_orders('2024-12-10');
```

**Conditional Logic:**

```sql
CREATE OR REPLACE PROCEDURE update_customer_status()
LANGUAGE plpgsql
AS $$
DECLARE
    v_customer RECORD;
    v_updated_count INTEGER := 0;
BEGIN
    -- Loop through customers
    FOR v_customer IN 
        SELECT customer_id, last_order_date
        FROM customers
        WHERE status = 'active'
    LOOP
        -- Determine new status based on last order
        IF v_customer.last_order_date < CURRENT_DATE - INTERVAL '365 days' THEN
            UPDATE customers
            SET status = 'churned', status_updated_at = CLOCK_TIMESTAMP()
            WHERE customer_id = v_customer.customer_id;
            
        ELSIF v_customer.last_order_date < CURRENT_DATE - INTERVAL '90 days' THEN
            UPDATE customers
            SET status = 'at_risk', status_updated_at = CLOCK_TIMESTAMP()
            WHERE customer_id = v_customer.customer_id;
            
        END IF;
        
        v_updated_count := v_updated_count + 1;
    END LOOP;
    
    RAISE NOTICE 'Updated % customers', v_updated_count;
END;
$$;
```

**Error Handling Patterns:**

```sql
CREATE OR REPLACE PROCEDURE safe_aggregate_update()
LANGUAGE plpgsql
AS $$
DECLARE
    v_error_context TEXT;
    v_error_detail TEXT;
BEGIN
    -- Attempt risky operation
    UPDATE customer_summary c
    SET 
        total_orders = (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id),
        total_spent = (SELECT SUM(amount) FROM orders o WHERE o.customer_id = c.customer_id),
        avg_order = (SELECT AVG(amount) FROM orders o WHERE o.customer_id = c.customer_id),
        updated_at = CLOCK_TIMESTAMP();
    
    RAISE NOTICE 'Successfully updated % customers', FOUND;
    
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'Division by zero error - check for customers with zero orders';
        INSERT INTO error_log VALUES ('safe_aggregate_update', 'Division by zero', CLOCK_TIMESTAMP());
        
    WHEN unique_violation THEN
        GET STACKED DIAGNOSTICS v_error_detail = MESSAGE_TEXT;
        RAISE NOTICE 'Unique constraint violation: %', v_error_detail;
        
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS 
            v_error_context = PG_EXCEPTION_CONTEXT,
            v_error_detail = MESSAGE_TEXT;
            
        RAISE NOTICE 'Unexpected error: %', v_error_detail;
        RAISE NOTICE 'Error context: %', v_error_context;
        
        INSERT INTO error_log (process_name, error_message, error_context, error_time)
        VALUES ('safe_aggregate_update', v_error_detail, v_error_context, CLOCK_TIMESTAMP());
        
        -- Re-raise to rollback transaction
        RAISE;
END;
$$;
```

**Dynamic SQL:**

```sql
CREATE OR REPLACE PROCEDURE archive_table(schema_name VARCHAR, table_name VARCHAR, days_old INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    archive_table_name VARCHAR;
    sql_stmt TEXT;
BEGIN
    archive_table_name := table_name || '_archive_' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD');
    
    -- Create archive table
    sql_stmt := format('
        CREATE TABLE %I.%I AS
        SELECT * FROM %I.%I
        WHERE created_date < CURRENT_DATE - INTERVAL ''%s days''
    ', schema_name, archive_table_name, schema_name, table_name, days_old);
    
    EXECUTE sql_stmt;
    
    -- Delete archived records
    sql_stmt := format('
        DELETE FROM %I.%I
        WHERE created_date < CURRENT_DATE - INTERVAL ''%s days''
    ', schema_name, table_name, days_old);
    
    EXECUTE sql_stmt;
    
    RAISE NOTICE 'Archived % to %', table_name, archive_table_name;
END;
$$;

-- Usage
CALL archive_table('public', 'orders', 365);
```

---

#### Real-World Stored Procedure Patterns

**Pattern 1: Idempotent Upsert**

```sql
-- Snowflake
CREATE OR REPLACE PROCEDURE upsert_customer_daily_stats(run_date DATE)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Delete if already exists (make idempotent)
    DELETE FROM customer_daily_stats WHERE stat_date = :run_date;
    
    -- Insert fresh calculations
    INSERT INTO customer_daily_stats
    SELECT 
        :run_date as stat_date,
        customer_id,
        COUNT(*) as orders_today,
        SUM(amount) as revenue_today
    FROM orders
    WHERE order_date = :run_date
    GROUP BY customer_id;
    
    RETURN 'Upserted stats for ' || :run_date;
END;
$$;
```

**Pattern 2: Batch Processing with Checkpoints**

```sql
-- Redshift
CREATE OR REPLACE PROCEDURE process_orders_in_batches()
LANGUAGE plpgsql
AS $$
DECLARE
    v_batch_size INTEGER := 10000;
    v_offset INTEGER := 0;
    v_processed INTEGER;
BEGIN
    LOOP
        -- Process batch
        UPDATE orders
        SET status = 'processed', processed_at = CLOCK_TIMESTAMP()
        WHERE order_id IN (
            SELECT order_id 
            FROM orders 
            WHERE status = 'pending'
            ORDER BY order_id
            LIMIT v_batch_size
        );
        
        GET DIAGNOSTICS v_processed = ROW_COUNT;
        
        -- Checkpoint: Commit batch
        COMMIT;
        
        -- Log progress
        INSERT INTO batch_log VALUES (v_offset, v_processed, CLOCK_TIMESTAMP());
        
        -- Exit if no more to process
        EXIT WHEN v_processed < v_batch_size;
        
        v_offset := v_offset + v_batch_size;
    END LOOP;
    
    RAISE NOTICE 'Processed % total orders', v_offset + v_processed;
END;
$$;
```

**Pattern 3: Configuration-Driven Processing**

```sql
-- Snowflake
CREATE OR REPLACE PROCEDURE run_configured_aggregations()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    // Read configuration
    var configSql = "SELECT table_name, agg_type, target_table FROM agg_config WHERE enabled = TRUE";
    var configs = snowflake.execute({ sqlText: configSql });
    
    var processed = 0;
    
    while (configs.next()) {
        var tableName = configs.getColumnValue('TABLE_NAME');
        var aggType = configs.getColumnValue('AGG_TYPE');
        var targetTable = configs.getColumnValue('TARGET_TABLE');
        
        var aggSql;
        
        if (aggType === 'daily') {
            aggSql = `
                INSERT INTO ${targetTable}
                SELECT DATE_TRUNC('day', timestamp), SUM(amount)
                FROM ${tableName}
                WHERE timestamp >= DATEADD('day', -1, CURRENT_DATE())
                GROUP BY 1
            `;
        } else if (aggType === 'hourly') {
            aggSql = `
                INSERT INTO ${targetTable}
                SELECT DATE_TRUNC('hour', timestamp), SUM(amount)
                FROM ${tableName}
                WHERE timestamp >= DATEADD('hour', -1, CURRENT_TIMESTAMP())
                GROUP BY 1
            `;
        }
        
        snowflake.execute({ sqlText: aggSql });
        processed++;
    }
    
    return `Processed ${processed} configured aggregations`;
$$;
```

---

This is a great stopping point. Should I continue with:
- Clustering and Sort Keys (Snowflake vs Redshift deep dive)
- Query Optimization patterns
- Python coding questions
- DBT complete workflow
- Interview strategy

Let me know and I'll keep going! 🚀


---

### Clustering, Sort Keys & Physical Data Organization

#### Understanding the Core Problem

**The Fundamental Challenge:**
When you have a table with billions of rows, scanning all of them to answer a query is prohibitively slow. You need the database to **skip irrelevant data** without reading it.

**Think of it like a library:**
- **No organization**: Check every book to find "Python Programming"
- **Alphabetical shelves**: Go directly to the "P" section
- **Dewey Decimal System**: Go to "Computer Science → Programming → Python"

**That's what clustering/sorting does for your data.**

Different databases solve this differently:
- **Traditional databases**: B-tree indexes (separate structure pointing to data)
- **Snowflake**: Clustering keys with micro-partition pruning (metadata-based)
- **Redshift**: Distribution keys + Sort keys (physical data placement)

---

#### Snowflake Clustering Keys - The Automatic Approach

**The Philosophy:**
Snowflake believes indexes are maintenance headaches. Instead, they organize data into small chunks (micro-partitions) and track metadata about each chunk.

**How Micro-Partitions Work:**

```
Unclustered Table (5000 micro-partitions, 1TB total):
Partition 1: customer_ids [5, 10042, 23891, 50321, 89234]
Partition 2: customer_ids [12, 10398, 29472, 51023, 90122]
Partition 3: customer_ids [45, 11234, 30194, 52341, 91034]
...
Partition 5000: customer_ids [98, 19234, 49281, 59124, 99234]

Query: WHERE customer_id BETWEEN 50000 AND 60000
Problem: Every partition might have relevant data
Result: Must scan all 5000 partitions (1TB)

Clustered Table (same data):
Partition 1: customer_ids [1, 2, 3, 4, 5] 
Partition 2: customer_ids [6, 7, 8, 9, 10]
...
Partition 1000: customer_ids [50000-50100]
Partition 1001: customer_ids [50101-50200]
...
Partition 1200: customer_ids [59900-60000]
Partition 1201: customer_ids [60001-60100]

Query: WHERE customer_id BETWEEN 50000 AND 60000
Snowflake checks metadata: "Only partitions 1000-1200 have this range"
Result: Scan 200 partitions, skip 4800 partitions (96% pruned!)
```

---

**Defining Clustering in Snowflake:**

```sql
-- Single column clustering (most common)
CREATE TABLE events (
    event_id BIGINT AUTOINCREMENT,
    event_timestamp TIMESTAMP,
    user_id INTEGER,
    event_type VARCHAR(50),
    event_data VARIANT
)
CLUSTER BY (event_timestamp);

-- Add to existing table
ALTER TABLE events CLUSTER BY (event_timestamp);

-- Multi-column clustering (order matters - left-most prefix)
CREATE TABLE orders (
    order_id BIGINT,
    order_date DATE,
    customer_id INTEGER,
    region VARCHAR(50),
    amount DECIMAL(10,2)
)
CLUSTER BY (order_date, customer_id);
-- Good for: WHERE order_date = X AND customer_id = Y
-- Less good for: WHERE customer_id = Y (skips first column)

-- Expression-based clustering
CREATE TABLE transactions (
    transaction_id BIGINT,
    transaction_timestamp TIMESTAMP,
    amount DECIMAL(10,2)
)
CLUSTER BY (DATE_TRUNC('month', transaction_timestamp));
-- Groups all transactions from same month together

-- Remove clustering
ALTER TABLE events SUSPEND RECLUSTER;
ALTER TABLE events DROP CLUSTERING KEY;
```

---

**When to Define Clustering:**

**✅ Good Candidates:**

1. **Large tables** (multi-TB)
   - Small tables (<1TB) don't benefit enough to justify cost

2. **High-cardinality columns** (many unique values)
   - Dates, timestamps, IDs
   - NOT: Status with 3 values (pending/processed/complete)

3. **Frequently filtered columns**
   - 80%+ of queries filter on this column
   - Example: "Most queries have WHERE order_date BETWEEN..."

4. **Join keys for large tables**
   - If you frequently join orders.customer_id = customers.customer_id
   - Cluster orders on customer_id

**❌ Poor Candidates:**

1. **Low-cardinality columns**
   - Status, category with few values
   - Doesn't prune much

2. **Randomly distributed values**
   - UUIDs, random IDs
   - No natural clustering pattern

3. **Frequently updated columns**
   - Every update potentially breaks clustering
   - Expensive automatic reclustering

4. **Small tables**
   - Overhead not worth it

---

**Monitoring Clustering Health:**

```sql
-- Check clustering information
SELECT SYSTEM$CLUSTERING_INFORMATION('orders', '(order_date, customer_id)');

/* Example output (JSON):
{
  "cluster_by_keys": "(ORDER_DATE, CUSTOMER_ID)",
  "total_partition_count": 5240,
  "total_constant_partition_count": 1200,
  "average_overlaps": 2.3,
  "average_depth": 2.1,  ← Target: < 4 is good, > 10 is poor
  "partition_depth_histogram": {
    "00000": 0,
    "00001": 1250,
    "00002": 2100,
    "00003": 1500,
    "00004": 390
  }
}
*/

-- Simpler depth check
SELECT SYSTEM$CLUSTERING_DEPTH('orders', '(order_date)');
-- Returns: 2.1 (good), 8.5 (needs reclustering), 15.2 (poor)

-- View automatic clustering history (cost tracking)
SELECT 
    start_time,
    end_time,
    table_name,
    credits_used,
    num_bytes_reclustered,
    num_rows_reclustered
FROM TABLE(INFORMATION_SCHEMA.AUTOMATIC_CLUSTERING_HISTORY(
    DATE_RANGE_START => DATEADD('day', -7, CURRENT_DATE()),
    TABLE_NAME => 'ORDERS'
))
ORDER BY start_time DESC;

-- Check if a query benefited from clustering
-- Run query, then check Query Profile in UI
-- Look for "Partitions scanned" vs "Partitions total"
-- Want: High pruning percentage (90%+)
```

---

**Clustering Maintenance:**

```sql
-- Snowflake automatically reclusters in the background
-- You rarely need manual intervention

-- Suspend automatic clustering (during bulk loads)
ALTER TABLE orders SUSPEND RECLUSTER;

-- Load large amount of data
COPY INTO orders FROM @stage/...;

-- Resume automatic clustering
ALTER TABLE orders RESUME RECLUSTER;

-- Force manual recluster (rarely needed)
ALTER TABLE orders RECLUSTER;
-- This runs immediately and uses credits

-- Check if table needs reclustering
SELECT SYSTEM$CLUSTERING_INFORMATION('orders');
-- If average_depth > 4, table could benefit from reclustering
```

---

**Search Optimization Service (Snowflake's Point Lookup Acceleration):**

**The Problem Clustering Doesn't Solve:**
Clustering helps with range queries (`WHERE date BETWEEN...`) but not point lookups (`WHERE email = 'user@example.com'`).

**Search Optimization Service:**
Creates a search access path (like an index) for fast point lookups.

```sql
-- Enable search optimization
ALTER TABLE customers ADD SEARCH OPTIMIZATION;

-- Now these queries are fast (no full partition scan)
SELECT * FROM customers WHERE email = 'user@example.com';
SELECT * FROM customers WHERE phone_number = '+1-555-0100';
SELECT * FROM customers WHERE customer_id = 12345;

-- Check search optimization status
SHOW SEARCH OPTIMIZATION ON customers;

-- Check cost
SELECT *
FROM TABLE(INFORMATION_SCHEMA.SEARCH_OPTIMIZATION_HISTORY(
    DATE_RANGE_START => DATEADD('day', -7, CURRENT_DATE())
))
WHERE table_name = 'CUSTOMERS';

-- Remove if not beneficial
ALTER TABLE customers DROP SEARCH OPTIMIZATION;
```

**When to Use:**
- Queries with equality filters on high-cardinality columns
- Point lookups on strings (emails, IDs, codes)
- NOT for range queries (clustering handles that)

**Cost Consideration:**
Search optimization uses storage and compute. Monitor the SEARCH_OPTIMIZATION_HISTORY table to ensure benefit > cost.

---

#### Redshift Distribution and Sort Keys - Manual Control

**The Philosophy:**
Redshift believes you know your workload best. You tell it how to distribute and sort data, and it will optimize for that pattern.

**Two Separate Decisions:**

1. **Distribution Key (DISTKEY)**: Which node gets which rows?
2. **Sort Key (SORTKEY)**: How are rows ordered within each node?

---

**Distribution Strategies:**

**Understanding the Problem:**
Redshift is a cluster of nodes. When you JOIN two tables, matching rows must be on the same node. If they're on different nodes, Redshift must shuffle data over the network (expensive!).

**Strategy 1: DISTSTYLE KEY**

```sql
-- Distribute based on a column value
CREATE TABLE orders (
    order_id INTEGER,
    customer_id INTEGER,
    order_date DATE,
    amount DECIMAL(10,2)
)
DISTKEY(customer_id)  -- Hash customer_id, send to node based on hash
SORTKEY(order_date);

CREATE TABLE customers (
    customer_id INTEGER,
    customer_name VARCHAR(200),
    email VARCHAR(200)
)
DISTKEY(customer_id)  -- Match orders distribution
SORTKEY(customer_id);

-- Now this JOIN is LOCAL (no network shuffle):
SELECT 
    c.customer_name,
    SUM(o.amount) as total_spent
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
GROUP BY c.customer_name;

-- Customer 12345 data is on Node A in both tables
-- Customer 67890 data is on Node B in both tables
-- JOIN happens locally on each node - FAST!
```

**When to use KEY:**
- Large tables that frequently JOIN
- Choose the most common join column as DISTKEY
- Both tables should use the same DISTKEY for that join

---

**Strategy 2: DISTSTYLE EVEN**

```sql
-- Round-robin distribution (like dealing cards)
CREATE TABLE staging_data (
    data_id INTEGER,
    raw_json VARCHAR(MAX),
    load_timestamp TIMESTAMP
)
DISTSTYLE EVEN;

-- Row 1 → Node A
-- Row 2 → Node B
-- Row 3 → Node C
-- Row 4 → Node A (repeat)
```

**When to use EVEN:**
- Staging tables (no joins, temporary)
- Tables with no clear join pattern
- Want even distribution when no specific key makes sense

---

**Strategy 3: DISTSTYLE ALL**

```sql
-- Full copy on every node (broadcast)
CREATE TABLE dim_products (
    product_id INTEGER,
    product_name VARCHAR(200),
    category VARCHAR(100),
    price DECIMAL(10,2)
)
DISTSTYLE ALL
SORTKEY(product_id);

-- Every node has complete product table
-- JOINs with products are always local (no shuffle)
```

**When to use ALL:**
- Small dimension tables (<1M rows, <100MB)
- Tables joined by many other tables
- Read-heavy, write-rarely tables

**Cost:**
Storage = table_size × num_nodes. Worth it for small tables, prohibitive for large.

---

**Sort Key Strategies:**

**Understanding the Impact:**
Within each node, rows can be physically ordered. Ordered data enables:
- **Zone maps**: Track min/max per block, skip irrelevant blocks
- **Efficient merges**: Pre-sorted data joins faster
- **Compression**: Similar values compress better

**COMPOUND SORTKEY (Ordered - Left-most Prefix Rule):**

```sql
-- Multi-column sort where order matters
CREATE TABLE orders (
    order_id INTEGER,
    customer_id INTEGER,
    order_date DATE,
    status VARCHAR(20),
    amount DECIMAL(10,2)
)
DISTKEY(customer_id)
COMPOUND SORTKEY(customer_id, order_date, status);

-- Physical row order: First by customer_id, then order_date, then status

-- These queries benefit (left-most prefix):
-- ✅ Fast: WHERE customer_id = 12345
-- ✅ Fast: WHERE customer_id = 12345 AND order_date > '2024-01-01'
-- ✅ Fast: WHERE customer_id = 12345 AND order_date > '2024-01-01' AND status = 'shipped'

-- These queries DON'T benefit:
-- ❌ Slow: WHERE order_date > '2024-01-01' (skips first column)
-- ❌ Slow: WHERE status = 'shipped' (skips first two columns)
```

**Use COMPOUND when:**
- Queries have a primary filter dimension (usually customer_id or date)
- Clear hierarchy in query patterns
- Most queries filter on first column(s)

---

**INTERLEAVED SORTKEY (Equal Weight to All Columns):**

```sql
-- Equal priority to all columns
CREATE TABLE orders (
    order_id INTEGER,
    customer_id INTEGER,
    order_date DATE,
    region VARCHAR(50),
    product_id INTEGER
)
DISTKEY(customer_id)
INTERLEAVED SORTKEY(customer_id, order_date, region, product_id);

-- All these queries benefit equally:
-- ✅ WHERE customer_id = 12345
-- ✅ WHERE order_date > '2024-01-01'
-- ✅ WHERE region = 'US'
-- ✅ WHERE product_id = 567
-- ✅ WHERE customer_id = 12345 AND region = 'US'
```

**Use INTERLEAVED when:**
- Query patterns vary widely
- No clear primary filter dimension
- Need flexibility

**Trade-off:**
- More expensive to maintain (VACUUM REINDEX required)
- Slower writes
- Better for varied read patterns

---

**Practical Design Patterns:**

```sql
-- Pattern 1: Large fact table (billions of rows)
CREATE TABLE fact_sales (
    sale_id BIGINT IDENTITY(1,1),
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    store_id INTEGER NOT NULL,
    sale_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL
)
DISTKEY(customer_id)                    -- Most common join key
COMPOUND SORTKEY(sale_date, store_id)   -- Common filter pattern
ENCODE AUTO;

-- Pattern 2: Small dimension (< 1M rows)
CREATE TABLE dim_customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(200),
    email VARCHAR(200),
    region VARCHAR(50)
)
DISTSTYLE ALL                  -- Full copy on every node
SORTKEY(customer_id);          -- For JOINs

-- Pattern 3: Medium dimension (1M - 100M rows)
CREATE TABLE dim_products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(200),
    category VARCHAR(100),
    price DECIMAL(10,2)
)
DISTKEY(product_id)           -- Distributed like fact table
SORTKEY(product_id);          -- For JOINs

-- Pattern 4: Staging table
CREATE TABLE staging_daily_sales (
    sale_id BIGINT,
    sale_date DATE,
    amount DECIMAL(10,2)
)
DISTSTYLE EVEN;               -- Fast load, no optimization needed

-- Pattern 5: Time-series data
CREATE TABLE sensor_readings (
    sensor_id INTEGER,
    reading_timestamp TIMESTAMP,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2)
)
DISTKEY(sensor_id)            -- Sensors co-located
SORTKEY(reading_timestamp);   -- Time-series queries
```

---

**Monitoring Distribution and Sort Quality:**

```sql
-- Check distribution skew
SELECT 
    slice,
    COUNT(*) as row_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () as pct_of_total
FROM orders
GROUP BY slice
ORDER BY slice;

/* Ideal result (4 slices):
slice | row_count | pct_of_total
------+-----------+-------------
    0 |   250000  |    25.0
    1 |   250000  |    25.0
    2 |   250000  |    25.0
    3 |   250000  |    25.0

Problem result (data skew):
slice | row_count | pct_of_total
------+-----------+-------------
    0 |   500000  |    50.0  ← One slice has half the data!
    1 |   200000  |    20.0
    2 |   200000  |    20.0
    3 |   100000  |    10.0
*/

-- Check sort key usage and table health
SELECT 
    "table",
    sortkey1,
    max_varchar,
    unsorted,      -- % of rows not in sort order (>10% = needs VACUUM)
    stats_off,     -- % change since ANALYZE (>10% = run ANALYZE)
    tbl_rows,
    size           -- Size in 1MB blocks
FROM svv_table_info
WHERE "schema" = 'public'
    AND "table" = 'orders';

/* Example output:
table   | sortkey1   | unsorted | stats_off | tbl_rows  | size
--------+------------+----------+-----------+-----------+------
orders  | order_date |    15.2  |    8.3    | 10000000  | 5000
*/

-- If unsorted > 10%, need VACUUM SORT ONLY
-- If stats_off > 10%, need ANALYZE

-- Check table sizes and distribution details
SELECT 
    "table",
    diststyle,
    sortkey1,
    size,
    tbl_rows,
    skew_rows,       -- Distribution skew (>1.5 = problem)
    skew_sortkey1    -- Sort key skew
FROM svv_table_info
WHERE "schema" = 'public'
ORDER BY size DESC;
```

---

**VACUUM and ANALYZE - Essential Maintenance:**

```sql
-- VACUUM: Reclaim space and resort data
-- After large DELETE/UPDATE operations

-- Full vacuum (most thorough, slowest)
VACUUM orders;

-- Sort only (just restore sort order)
VACUUM SORT ONLY orders;
-- Use when: unsorted > 10% but no deletes

-- Delete only (reclaim space from deleted rows)
VACUUM DELETE ONLY orders;
-- Use when: Many deletes but sort order still good

-- Vacuum with threshold (stop when 95% sorted)
VACUUM orders TO 95 PERCENT;

-- For INTERLEAVED sort keys specifically
VACUUM REINDEX orders;
-- Rebuilds interleaved structure (expensive!)

-- ANALYZE: Update table statistics for query planner
ANALYZE orders;
-- Updates: Row counts, column distributions, correlations

-- Analyze specific columns (faster)
ANALYZE orders (customer_id, order_date);

-- Analyze only columns used in WHERE/JOIN
ANALYZE orders PREDICATE COLUMNS;

-- Automated maintenance script (run nightly)
DO $$
DECLARE
    rec RECORD;
BEGIN
    -- VACUUM tables that need it
    FOR rec IN 
        SELECT 
            "schema",
            "table"
        FROM svv_table_info 
        WHERE "schema" = 'public' 
            AND (unsorted > 10 OR stats_off > 10)
    LOOP
        -- VACUUM if needed
        IF (SELECT unsorted FROM svv_table_info 
            WHERE "schema" = rec."schema" 
            AND "table" = rec."table") > 10 THEN
            
            EXECUTE 'VACUUM SORT ONLY ' || rec."schema" || '.' || rec."table";
            RAISE NOTICE 'Vacuumed: %.%', rec."schema", rec."table";
        END IF;
        
        -- ANALYZE if needed
        IF (SELECT stats_off FROM svv_table_info 
            WHERE "schema" = rec."schema" 
            AND "table" = rec."table") > 10 THEN
            
            EXECUTE 'ANALYZE ' || rec."schema" || '.' || rec."table";
            RAISE NOTICE 'Analyzed: %.%', rec."schema", rec."table";
        END IF;
    END LOOP;
END $$;
```

**When to VACUUM:**
- After bulk DELETE/UPDATE (>10% of table)
- When unsorted > 10%
- Before critical reports (ensure best performance)

**When to ANALYZE:**
- After bulk load (table size changed significantly)
- When stats_off > 10%
- After changing distribution/sort keys

---

**Real-World Scenario: Redesigning Distribution**

```sql
-- Problem: Slow JOINs between orders and customers
-- Current design:
CREATE TABLE orders (...) DISTSTYLE EVEN;    -- Bad!
CREATE TABLE customers (...) DISTSTYLE EVEN; -- Bad!

-- Result: Every JOIN shuffles data across network

-- Solution: Redesign with matching DISTKEY
-- Step 1: Create new tables with correct distribution
CREATE TABLE orders_new (
    order_id INTEGER,
    customer_id INTEGER,
    amount DECIMAL(10,2)
)
DISTKEY(customer_id)
SORTKEY(order_date);

CREATE TABLE customers_new (
    customer_id INTEGER,
    customer_name VARCHAR(200)
)
DISTKEY(customer_id)
SORTKEY(customer_id);

-- Step 2: Load data
INSERT INTO orders_new SELECT * FROM orders;
INSERT INTO customers_new SELECT * FROM customers;

-- Step 3: Swap tables
DROP TABLE orders;
DROP TABLE customers;
ALTER TABLE orders_new RENAME TO orders;
ALTER TABLE customers_new RENAME TO customers;

-- Step 4: Recreate constraints and grants
ALTER TABLE orders ADD PRIMARY KEY (order_id);
ALTER TABLE customers ADD PRIMARY KEY (customer_id);
GRANT SELECT ON orders TO reporting_role;
GRANT SELECT ON customers TO reporting_role;

-- Result: JOINs are now local (10x-100x faster)
```

---

#### Snowflake vs Redshift - Key Differences Summary

| Aspect | Snowflake | Redshift |
|--------|-----------|----------|
| **Philosophy** | Automatic optimization | Manual tuning |
| **Data Organization** | Micro-partitions (auto) | Distribution keys (manual) |
| **Sorting** | Optional clustering | Must define sort keys |
| **Maintenance** | Automatic reclustering | Manual VACUUM/ANALYZE |
| **Cost** | Reclustering uses credits | VACUUM during quiet hours |
| **Flexibility** | Change clustering easily | Redesign = rebuild table |
| **Point Lookups** | Search Optimization Service | Not natively supported |
| **Best For** | Variable workloads, minimal DBA | Predictable workloads, cost optimization |

**The Strategic Choice:**
- **Snowflake**: "Let the database figure it out" (easier, potentially more expensive)
- **Redshift**: "I'll tune it myself" (more work, potentially cheaper)

---

This section is complete! Should I continue with:
- Query Optimization (systematic approach with examples)
- DELETE/TRUNCATE/Bulk Loading patterns
- Python coding questions
- DBT workflow and configuration
- Interview strategy

Let me know! 🚀


---

## Python for Data Engineering

### String Reversal - Multiple Approaches

#### Understanding Why This Matters

String manipulation is a fundamental skill that tests:
- **Algorithm thinking**: Can you solve it multiple ways?
- **Complexity analysis**: Do you understand time/space trade-offs?
- **Language knowledge**: Do you know Python's features?

**In interviews, they're testing:**
- Problem-solving approach
- Communication (explaining trade-offs)
- Python proficiency

---

#### Approach 1: Slicing (The Pythonic Way)

```python
def reverse_string(s):
    """Most Pythonic - uses slice notation"""
    return s[::-1]

# Usage
text = "Hello, World!"
reversed_text = reverse_string(text)  # "!dlroW ,olleH"

# How slicing works: s[start:stop:step]
# s[::-1] means:
#   start = beginning (default)
#   stop = end (default)
#   step = -1 (backwards)

# Time Complexity: O(n) - must visit every character
# Space Complexity: O(n) - creates new string
# Pros: Concise, Pythonic, fast (C implementation)
# Cons: Creates new string (immutable)
```

**When to use:** Default choice for Python. Clean, fast, idiomatic.

---

#### Approach 2: reversed() Function

```python
def reverse_string(s):
    """Using built-in reversed() iterator"""
    return ''.join(reversed(s))

# reversed() returns an iterator (memory efficient)
# join() converts iterator back to string

# Time Complexity: O(n)
# Space Complexity: O(n) - final string, but iterator is O(1)
# Pros: Memory efficient (iterator), readable
# Cons: Slightly slower than slicing, extra function calls
```

**When to use:** When you want to iterate over reversed characters without creating intermediate string.

```python
# Useful when you only need to iterate
for char in reversed(string):
    process(char)  # Don't need full reversed string
```

---

#### Approach 3: List Manipulation (In-Place Swap)

```python
def reverse_string(s):
    """Manual reversal with list (most efficient for mutable)"""
    chars = list(s)  # Convert to list (mutable)
    left, right = 0, len(chars) - 1
    
    while left < right:
        # Swap characters
        chars[left], chars[right] = chars[right], chars[left]
        left += 1
        right -= 1
    
    return ''.join(chars)

# Time Complexity: O(n)
# Space Complexity: O(n) - list storage
# Pros: In-place swapping concept, good for interviews
# Cons: More verbose, no faster than slicing in Python

# Why this matters: Shows understanding of two-pointer technique
```

**When to use:** In interviews to demonstrate algorithm knowledge. Not for production Python code.

---

#### Approach 4: Recursion

```python
def reverse_string(s):
    """Recursive approach"""
    # Base case
    if len(s) <= 1:
        return s
    
    # Recursive case: last character + reverse of rest
    return s[-1] + reverse_string(s[:-1])

# How it works:
# reverse_string("abc")
# = "c" + reverse_string("ab")
# = "c" + "b" + reverse_string("a")
# = "c" + "b" + "a"
# = "cba"

# Time Complexity: O(n)
# Space Complexity: O(n) - call stack
# Pros: Elegant, demonstrates recursion
# Cons: Stack overflow for long strings (Python recursion limit ~1000)

# Python recursion limit
import sys
print(sys.getrecursionlimit())  # Usually 1000

# For very long strings, this fails
huge_string = "a" * 10000
reverse_string(huge_string)  # RecursionError!
```

**When to use:** Academic exercise only. Never in production for this problem.

---

#### Approach 5: Stack (Explicit)

```python
def reverse_string(s):
    """Using stack data structure explicitly"""
    stack = []
    
    # Push all characters onto stack
    for char in s:
        stack.append(char)
    
    # Pop all characters (LIFO = reversed order)
    result = []
    while stack:
        result.append(stack.pop())
    
    return ''.join(result)

# Time Complexity: O(n)
# Space Complexity: O(n)
# Pros: Demonstrates data structure knowledge
# Cons: Overly complex for this problem
```

**When to use:** When interviewer specifically asks about stacks, or in languages without string slicing.

---

### String Reversal Variations

**1. Reverse Words in Sentence**

```python
def reverse_words(s):
    """Reverse word order in sentence"""
    return ' '.join(s.split()[::-1])

# Example
text = "Hello World Python"
print(reverse_words(text))  # "Python World Hello"

# How it works:
# split() → ['Hello', 'World', 'Python']
# [::-1] → ['Python', 'World', 'Hello']
# join(' ') → "Python World Hello"

# Edge cases
print(reverse_words("  Hello   World  "))  # "World Hello" (split() handles extra spaces)
print(reverse_words(""))                    # ""
print(reverse_words("SingleWord"))          # "SingleWord"
```

---

**2. Reverse Each Word Individually**

```python
def reverse_each_word(s):
    """Reverse letters in each word, keep word order"""
    return ' '.join(word[::-1] for word in s.split())

# Example
text = "Hello World"
print(reverse_each_word(text))  # "olleH dlroW"

# Manual approach (more control)
def reverse_each_word_manual(s):
    words = s.split()
    reversed_words = []
    
    for word in words:
        reversed_word = word[::-1]
        reversed_words.append(reversed_word)
    
    return ' '.join(reversed_words)
```

---

**3. Check if Palindrome**

```python
def is_palindrome(s):
    """Check if string reads same forwards and backwards"""
    # Remove non-alphanumeric and convert to lowercase
    cleaned = ''.join(c.lower() for c in s if c.isalnum())
    return cleaned == cleaned[::-1]

# Examples
print(is_palindrome("A man, a plan, a canal: Panama"))  # True
print(is_palindrome("race a car"))                       # False
print(is_palindrome("Was it a car or a cat I saw?"))    # True

# Alternative: Two-pointer approach (more efficient)
def is_palindrome_twopointer(s):
    # Clean string
    cleaned = ''.join(c.lower() for c in s if c.isalnum())
    
    left, right = 0, len(cleaned) - 1
    
    while left < right:
        if cleaned[left] != cleaned[right]:
            return False
        left += 1
        right -= 1
    
    return True

# Time Complexity: O(n)
# Space Complexity: O(n) for cleaned string, O(1) comparison
```

---

**4. Reverse Preserving Spaces**

```python
def reverse_preserve_spaces(s):
    """Reverse string but keep spaces in original positions"""
    # Extract non-space characters
    chars = [c for c in s if c != ' ']
    chars.reverse()
    
    # Rebuild with original space positions
    result = []
    char_index = 0
    
    for c in s:
        if c == ' ':
            result.append(' ')
        else:
            result.append(chars[char_index])
            char_index += 1
    
    return ''.join(result)

# Example
text = "Hello World Python"
print(reverse_preserve_spaces(text))  
# "nohty PdlroW olleH"
#      ^     ^      ^ (spaces in same positions)

# More complex example
text = "I love Python"
print(reverse_preserve_spaces(text))
# "n ohtyP evolI"
#  ^      ^     ^ (spaces preserved)
```

---

### Complexity Analysis Summary

| Approach | Time | Space | Best Use Case |
|----------|------|-------|---------------|
| Slicing [::-1] | O(n) | O(n) | Production Python code |
| reversed() | O(n) | O(n) | When need iterator |
| Two-pointer | O(n) | O(n) | Interview algorithm demo |
| Recursion | O(n) | O(n) | Academic/teaching |
| Stack | O(n) | O(n) | Data structure demo |

**Interview Tips:**
- Start with slicing (shows Python knowledge)
- Explain why it's O(n) time and space
- Mention alternative approaches if asked
- Discuss trade-offs (simplicity vs efficiency)
- Be ready to handle edge cases (empty string, single char)

---

### Pandas Reindexing - Essential Data Alignment

#### Understanding the Concept

**The Core Problem:**
DataFrames have an index (row labels). Sometimes you need to:
- Change index order
- Add new index values (with NaN for missing data)
- Remove index values
- Align multiple DataFrames for calculations
- Fill gaps in time-series data

**Three Key Methods:**
1. **reindex()**: Change index order/values
2. **reset_index()**: Convert index to column
3. **set_index()**: Convert column to index

---

#### reindex() - Changing Index Order or Adding Rows

```python
import pandas as pd
import numpy as np

# Original DataFrame
df = pd.DataFrame({
    'sales': [100, 150, 200],
    'profit': [20, 30, 40]
}, index=['Q1', 'Q2', 'Q3'])

print(df)
#     sales  profit
# Q1    100      20
# Q2    150      30
# Q3    200      40

# Change order and add new index
df_reindexed = df.reindex(['Q2', 'Q4', 'Q1', 'Q3'])
print(df_reindexed)
#     sales  profit
# Q2  150.0    30.0
# Q4    NaN     NaN  ← New index, no data (NaN)
# Q1  100.0    20.0
# Q3  200.0    40.0

# Fill missing values
df.reindex(['Q1', 'Q2', 'Q3', 'Q4'], fill_value=0)
#     sales  profit
# Q1    100      20
# Q2    150      30
# Q3    200      40
# Q4      0       0  ← Filled with 0

# Forward fill (propagate last valid value)
df.reindex(['Q1', 'Q2', 'Q3', 'Q4'], method='ffill')
#     sales  profit
# Q1    100      20
# Q2    150      30
# Q3    200      40
# Q4    200      40  ← Copied from Q3

# Backward fill
df.reindex(['Q0', 'Q1', 'Q2', 'Q3'], method='bfill')
#     sales  profit
# Q0    100      20  ← Copied from Q1
# Q1    100      20
# Q2    150      30
# Q3    200      40
```

**Real-World Use Case: Time-Series Gaps**

```python
# Sales data with missing dates
df = pd.DataFrame({
    'date': pd.to_datetime(['2024-01-01', '2024-01-03', '2024-01-05']),
    'sales': [100, 150, 200]
}).set_index('date')

# Create complete date range
complete_dates = pd.date_range(
    start=df.index.min(),
    end=df.index.max(),
    freq='D'
)

# Reindex to fill gaps
df_complete = df.reindex(complete_dates, fill_value=0)
print(df_complete)
#             sales
# 2024-01-01    100
# 2024-01-02      0  ← Filled
# 2024-01-03    150
# 2024-01-04      0  ← Filled
# 2024-01-05    200

# Or forward-fill (carry last value)
df_ffill = df.reindex(complete_dates, method='ffill')
#             sales
# 2024-01-01    100
# 2024-01-02    100  ← Carried from 01-01
# 2024-01-03    150
# 2024-01-04    150  ← Carried from 01-03
# 2024-01-05    200
```

---

#### reset_index() - Convert Index to Column

```python
# DataFrame with meaningful index
df = pd.DataFrame({
    'revenue': [1000, 1500, 2000]
}, index=['Store A', 'Store B', 'Store C'])
df.index.name = 'store'

print(df)
#          revenue
# store            
# Store A     1000
# Store B     1500
# Store C     2000

# Reset index (index becomes column)
df_reset = df.reset_index()
print(df_reset)
#      store  revenue
# 0  Store A     1000
# 1  Store B     1500
# 2  Store C     2000

# Drop old index instead of keeping it
df.reset_index(drop=True)
#    revenue
# 0     1000
# 1     1500
# 2     2000
```

**Common Use Case: After groupby**

```python
# Groupby creates multi-level index
sales_df = pd.DataFrame({
    'region': ['US', 'US', 'EU', 'EU'],
    'product': ['A', 'B', 'A', 'B'],
    'sales': [100, 150, 120, 180]
})

grouped = sales_df.groupby(['region', 'product']).agg({
    'sales': ['sum', 'mean', 'count']
})

print(grouped)
#                sales          
#                  sum mean count
# region product                
# EU     A         120  120     1
#        B         180  180     1
# US     A         100  100     1
#        B         150  150     1

# Reset to regular DataFrame
grouped_reset = grouped.reset_index()
print(grouped_reset)
#   region product  sales_sum  sales_mean  sales_count
# 0     EU       A        120         120            1
# 1     EU       B        180         180            1
# 2     US       A        100         100            1
# 3     US       B        150         150            1
```

---

#### set_index() - Make Column the Index

```python
df = pd.DataFrame({
    'date': pd.to_datetime(['2024-01-01', '2024-01-02', '2024-01-03']),
    'product': ['Widget', 'Gadget', 'Widget'],
    'sales': [100, 150, 120]
})

# Set date as index
df_dated = df.set_index('date')
print(df_dated)
#             product  sales
# date                      
# 2024-01-01   Widget    100
# 2024-01-02   Gadget    150
# 2024-01-03   Widget    120

# Now can use date-based slicing
df_dated.loc['2024-01-01':'2024-01-02']

# Multi-level index
df_multi = df.set_index(['date', 'product'])
print(df_multi)
#                        sales
# date       product          
# 2024-01-01 Widget       100
# 2024-01-02 Gadget       150
# 2024-01-03 Widget       120

# Access multi-level
df_multi.loc[('2024-01-01', 'Widget')]  # sales: 100
```

---

#### Time-Series Reindexing (Very Common in Data Engineering)

**Upsampling (Increase Frequency):**

```python
# Daily data
daily = pd.DataFrame({
    'date': pd.date_range('2024-01-01', periods=7, freq='D'),
    'value': [10, 20, 15, 30, 25, 35, 40]
}).set_index('date')

# Upsample to hourly
hourly_index = pd.date_range('2024-01-01', periods=169, freq='H')
hourly = daily.reindex(hourly_index, method='ffill')

print(hourly.head(25))
# Every hour has same value as that day (forward filled)
```

**Downsampling (Decrease Frequency):**

```python
# Hourly data
hourly = pd.DataFrame({
    'timestamp': pd.date_range('2024-01-01', periods=168, freq='H'),
    'temperature': np.random.randint(20, 30, 168)
}).set_index('timestamp')

# Downsample to daily (average)
daily = hourly.resample('D').mean()

# Or with multiple aggregations
daily_agg = hourly.resample('D').agg({
    'temperature': ['mean', 'min', 'max', 'std']
})
```

---

#### Aligning Multiple DataFrames

**The Problem:**
Two DataFrames with different indices - can't directly calculate.

```python
# Revenue by customer
revenue = pd.DataFrame({
    'customer': ['A', 'B', 'C'],
    'revenue': [1000, 2000, 3000]
}).set_index('customer')

# Costs by customer (different customers)
costs = pd.DataFrame({
    'customer': ['B', 'C', 'D'],
    'costs': [500, 800, 1200]
}).set_index('customer')

# Problem: Can't directly subtract (misaligned)
# revenue - costs  # Would give wrong results!

# Solution 1: Reindex costs to match revenue
costs_aligned = costs.reindex(revenue.index, fill_value=0)
profit = revenue - costs_aligned

print(profit)
#          revenue
# customer        
# A           1000  ← revenue 1000, costs 0 (filled)
# B           1500  ← revenue 2000, costs 500
# C           2200  ← revenue 3000, costs 800

# Solution 2: Reindex both to union of indices
all_customers = revenue.index.union(costs.index)
revenue_aligned = revenue.reindex(all_customers, fill_value=0)
costs_aligned = costs.reindex(all_customers, fill_value=0)
profit_all = revenue_aligned - costs_aligned

print(profit_all)
#          revenue
# customer        
# A           1000
# B           1500
# C           2200
# D          -1200  ← costs 1200, revenue 0
```

---

#### Practical Data Engineering Patterns

**Pattern 1: Joining Data from Different Sources**

```python
# Orders from database (daily)
orders = pd.read_sql("SELECT * FROM orders WHERE date >= '2024-01-01'", conn)
orders = orders.set_index('order_date')

# Returns from CSV (sparse data)
returns = pd.read_csv('returns.csv', parse_dates=['return_date'])
returns = returns.set_index('return_date')

# Align before calculating net
returns_aligned = returns.reindex(orders.index, fill_value=0)
net_sales = orders['amount'] - returns_aligned['amount']
```

**Pattern 2: Gap Filling for Visualization**

```python
# Sensor data with gaps
sensors = pd.DataFrame({
    'timestamp': pd.to_datetime([
        '2024-01-01 10:00', '2024-01-01 10:15',
        '2024-01-01 10:45', '2024-01-01 11:00'  # Missing 10:30
    ]),
    'temperature': [22.5, 23.0, 24.5, 25.0]
}).set_index('timestamp')

# Fill gaps for charting (15-min intervals)
complete_timeline = pd.date_range(
    start=sensors.index.min(),
    end=sensors.index.max(),
    freq='15min'
)

sensors_complete = sensors.reindex(complete_timeline)

# For visualization: forward-fill
sensors_viz = sensors.reindex(complete_timeline, method='ffill')

# For analysis: interpolate
sensors_interpolated = sensors.reindex(complete_timeline).interpolate()
```

---

### Interview Tips for Python Questions

**When Asked About String Reversal:**
1. Start with slicing (Pythonic)
2. Explain time/space complexity
3. Mention alternatives if asked (two-pointer, recursion)
4. Discuss trade-offs
5. Handle edge cases (empty string, single char)

**When Asked About Pandas:**
1. Explain the problem reindex() solves (alignment)
2. Show understanding of index vs columns
3. Discuss time-series applications
4. Mention fill strategies (forward, backward, interpolate)
5. Know when to use reindex vs reset_index vs set_index

**General Python Data Engineering:**
- Know when to use pandas vs raw Python vs SQL
- Understand memory implications (large datasets)
- Be familiar with data pipeline patterns
- Know common data quality issues (nulls, duplicates, gaps)

---

This completes the Python section! Should I continue with DBT and Interview Strategy to finish the guide? 🚀


---

## DBT - Modern Data Transformation

### Understanding DBT's Purpose

#### The Problem DBT Solves

**Before DBT, data transformations were chaos:**

```
Team A: Python scripts in Airflow
Team B: Stored procedures in database
Team C: SQL in Jupyter notebooks  
Team D: Transformations in BI tool

Problems:
❌ No one knows dependencies (what depends on what?)
❌ No testing (data quality issues propagate)
❌ No documentation (tribal knowledge)
❌ Inconsistent version control
❌ Hard to onboard new people
❌ Can't see data lineage
```

**DBT's Core Insight:**
"Transformations are just SELECT statements. Why not treat them like software code?"

---

#### The DBT Philosophy

**Core Principles:**

1. **SQL as the Interface**
   - Data people already know SQL
   - SQL runs in the warehouse (fast, no data movement)
   - Focus on logic, not infrastructure

2. **Version Control Everything**
   - All transformations in Git
   - Code review before production
   - Track changes over time
   - Rollback capability

3. **Test as You Build**
   - Data quality tests alongside transformations
   - Catch issues before they propagate
   - Document expectations as tests

4. **Auto-Generate Documentation**
   - Code IS documentation
   - Lineage graphs auto-generated
   - Catalog stays current

5. **Modularity Through ref()**
   - Small, focused models
   - Dependencies auto-detected
   - Change propagates automatically

---

### The DBT Project Structure

```
my_analytics_dbt/
├── dbt_project.yml          # Project configuration
├── profiles.yml             # Connection settings (in ~/.dbt/)
│
├── models/
│   ├── staging/            # Layer 1: Clean raw data
│   │   ├── _staging.yml   # Documentation & tests
│   │   ├── stg_customers.sql
│   │   └── stg_orders.sql
│   │
│   ├── intermediate/       # Layer 2: Business logic
│   │   ├── _intermediate.yml
│   │   └── int_customer_orders.sql
│   │
│   └── marts/             # Layer 3: Analytics-ready
│       ├── _marts.yml
│       ├── fct_orders.sql      # Fact tables
│       └── dim_customers.sql   # Dimension tables
│
├── tests/                  # Custom tests
│   └── assert_positive_revenue.sql
│
├── macros/                # Reusable SQL functions
│   ├── cents_to_dollars.sql
│   └── generate_schema_name.sql
│
├── seeds/                 # CSV reference data
│   └── country_codes.csv
│
├── snapshots/            # SCD Type 2
│   └── customers_snapshot.sql
│
└── analyses/             # Ad-hoc queries (not built)
    └── customer_cohort_analysis.sql
```

---

### How DBT Works - The Execution Flow

**When you run `dbt run`:**

```
1. Parse Configuration
   ├─ Read dbt_project.yml
   ├─ Load profiles.yml (connection info)
   └─ Resolve environment variables

2. Discover Models
   ├─ Scan models/ directory
   ├─ Parse all .sql files
   └─ Extract {{ ref() }} and {{ source() }} references

3. Build Dependency Graph (DAG)
   Example DAG:
   
   raw.customers     raw.orders
        ↓                 ↓
   stg_customers     stg_orders
        ↓                 ↓
        └────────┬────────┘
                 ↓
         int_customer_orders
                 ↓
            fct_orders
   
4. Execute in Topological Order
   ├─ Run staging models (can run in parallel)
   ├─ Run intermediate models
   ├─ Run mart models
   └─ Each materialized per its config

5. Run Tests (if dbt test)
   ├─ Schema tests (unique, not_null, etc.)
   └─ Custom data tests

6. Generate Documentation (if dbt docs generate)
   └─ Create lineage diagram and data catalog
```

---

### Essential DBT Macros

#### source() - Reference Raw Tables

```yaml
# models/staging/_sources.yml
version: 2

sources:
  - name: raw_data
    database: prod_db
    schema: raw
    description: "Raw data from production systems"
    
    tables:
      - name: customers
        description: "Customer master data from CRM"
        columns:
          - name: customer_id
            description: "Primary key"
            tests:
              - unique
              - not_null
        
        # Data freshness checks
        freshness:
          warn_after: {count: 12, period: hour}
          error_after: {count: 24, period: hour}
        loaded_at_field: _synced_at
        
      - name: orders
        description: "Orders from e-commerce platform"
```

```sql
-- models/staging/stg_customers.sql
SELECT 
    customer_id,
    customer_name,
    email,
    created_at
FROM {{ source('raw_data', 'customers') }}
WHERE is_deleted = FALSE
    AND email IS NOT NULL;

-- Compiles to:
-- FROM prod_db.raw.customers
```

**Why use source():**
- Documents raw data location
- Checks data freshness
- Tracks lineage from source
- Environment-aware (dev/prod)

---

#### ref() - Reference Other DBT Models

```sql
-- models/staging/stg_orders.sql
SELECT 
    order_id,
    customer_id,
    order_date,
    amount
FROM {{ source('raw_data', 'orders') }}
WHERE amount > 0;

-- models/marts/fct_orders.sql
SELECT 
    o.order_id,
    c.customer_name,
    c.email,
    o.order_date,
    o.amount
FROM {{ ref('stg_orders') }} o
LEFT JOIN {{ ref('stg_customers') }} c
    ON o.customer_id = c.customer_id;

-- Compiles to (in dev):
-- FROM dev_schema.stg_orders o
-- LEFT JOIN dev_schema.stg_customers c

-- Compiles to (in prod):
-- FROM prod_schema.stg_orders o
-- LEFT JOIN prod_schema.stg_customers c
```

**Why use ref():**
- Auto-builds dependency graph
- Environment-aware (dev/prod different schemas)
- Version control friendly
- Enables incremental builds

---

### Materialization Strategies - The Performance Decision

#### The Core Trade-Off

```
         Build Time    Query Time    Storage    Freshness
VIEW     Fast          Slow          None       Always Fresh
TABLE    Slow          Fast          High       Stale
INCREMENTAL Fast      Fast          High       Mostly Fresh
```

---

#### VIEW - Fast to Build, Slow to Query

**How it works:**
```sql
-- models/staging/stg_customers.sql
{{ config(materialized='view') }}

SELECT 
    customer_id,
    UPPER(TRIM(customer_name)) as customer_name,
    LOWER(TRIM(email)) as email,
    created_at
FROM {{ source('raw_data', 'customers') }}
WHERE is_deleted = FALSE;

-- Creates in database:
-- CREATE OR REPLACE VIEW dev_schema.stg_customers AS
-- SELECT ...
```

**When to use VIEW:**
- Simple transformations (rename, filter, cast)
- Queried infrequently
- Always need latest data
- Intermediate step in pipeline

**When NOT to use VIEW:**
- Complex joins/aggregations
- Queried frequently (dashboard)
- Part of critical path

**Real-World Example:**
```sql
-- Good: Simple staging view
{{ config(materialized='view') }}

SELECT 
    id,
    created_at::DATE as created_date,
    UPPER(status) as status
FROM {{ source('app', 'orders') }};

-- Bad: Complex view (use table instead)
{{ config(materialized='view') }}  -- DON'T DO THIS

SELECT 
    customer_id,
    COUNT(DISTINCT order_id) as total_orders,
    SUM(amount) as lifetime_value,
    AVG(amount) as avg_order,
    -- Expensive aggregation queried 100x/day
FROM {{ ref('fct_orders') }}
GROUP BY customer_id;
```

---

#### TABLE - Slow to Build, Fast to Query

**How it works:**
```sql
-- models/marts/dim_customers.sql
{{ config(materialized='table') }}

SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.amount) as lifetime_value,
    MAX(o.order_date) as last_order_date
FROM {{ ref('stg_customers') }} c
LEFT JOIN {{ ref('stg_orders') }} o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.email;

-- Executes:
-- CREATE TABLE dev_schema.dim_customers AS
-- SELECT ...
-- (Drops and recreates each run)
```

**When to use TABLE:**
- Complex transformations (multiple joins, aggregations)
- Queried frequently (dashboards, reports)
- Data changes daily/hourly (full refresh acceptable)
- Medium size (<10M rows, <5GB)

**When NOT to use TABLE:**
- Huge tables (billions of rows) - use incremental
- Data updates multiple times per hour - use incremental
- Simple transformations - use view

**Real-World Example:**
```sql
-- Perfect for TABLE: Daily customer metrics
{{ config(
    materialized='table',
    tags=['daily', 'metrics']
) }}

SELECT 
    customer_id,
    -- Complex calculations
    COUNT(DISTINCT CASE WHEN order_date >= CURRENT_DATE - 30 THEN order_id END) as orders_30d,
    SUM(CASE WHEN order_date >= CURRENT_DATE - 30 THEN amount END) as revenue_30d,
    -- Many joins
    ...
FROM {{ ref('stg_customers') }} c
LEFT JOIN {{ ref('stg_orders') }} o ON ...
LEFT JOIN {{ ref('stg_products') }} p ON ...
GROUP BY customer_id;

-- Runs nightly, rebuilds full table
-- Query time: 1 second (pre-computed)
-- Build time: 5 minutes (acceptable for nightly)
```

---

#### INCREMENTAL - Fast to Build, Fast to Query

**The Concept:**
Don't rebuild everything. Just add/update the new/changed data.

**How it works:**

```sql
-- models/marts/fct_events.sql
{{ config(
    materialized='incremental',
    unique_key='event_id',
    incremental_strategy='merge'
) }}

SELECT 
    event_id,
    user_id,
    event_type,
    event_timestamp,
    event_data
FROM {{ source('raw_data', 'events') }}

{% if is_incremental() %}
    -- Only new events since last run
    WHERE event_timestamp > (SELECT MAX(event_timestamp) FROM {{ this }})
{% endif %}
```

**First run (table doesn't exist):**
```sql
-- Builds full table
CREATE TABLE prod.fct_events AS
SELECT * FROM raw_data.events;
```

**Subsequent runs (table exists):**
```sql
-- Only processes new data
MERGE INTO prod.fct_events target
USING (
    SELECT * FROM raw_data.events
    WHERE event_timestamp > (SELECT MAX(event_timestamp) FROM prod.fct_events)
) source
ON target.event_id = source.event_id
WHEN MATCHED THEN UPDATE SET ...
WHEN NOT MATCHED THEN INSERT ...;
```

---

**Incremental Strategies:**

**1. Append (Immutable Data)**

```sql
{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

SELECT * FROM {{ source('raw', 'events') }}
{% if is_incremental() %}
    WHERE event_timestamp > (SELECT MAX(event_timestamp) FROM {{ this }})
{% endif %}

-- Just INSERT new rows, never UPDATE
-- Perfect for: Event logs, clickstreams, IoT data
```

**2. Merge (Mutable Data)**

```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge'
) }}

SELECT * FROM {{ source('raw', 'orders') }}
{% if is_incremental() %}
    WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}

-- UPDATE existing rows + INSERT new rows
-- Perfect for: Orders (status changes), customer records
```

**3. Delete+Insert (Time Windows)**

```sql
{{ config(
    materialized='incremental',
    unique_key='date',
    incremental_strategy='delete+insert'
) }}

SELECT 
    DATE(event_timestamp) as date,
    COUNT(*) as event_count
FROM {{ source('raw', 'events') }}
WHERE DATE(event_timestamp) = CURRENT_DATE()
GROUP BY 1

{% if is_incremental() %}
    -- Reprocess today (in case of late-arriving data)
{% endif %}

-- DELETE today's data, INSERT fresh calculations
-- Perfect for: Daily aggregations that might have late data
```

---

**Incremental Challenges and Solutions:**

**Problem 1: Late-Arriving Data**

```sql
-- Bad: Miss data that arrives late
WHERE event_date > (SELECT MAX(event_date) FROM {{ this }})

-- Good: Look back 7 days (catch late arrivals)
WHERE event_date >= (
    SELECT MAX(event_date) FROM {{ this }}
) - INTERVAL '7 days'

-- Trade-off: Reprocess more data, but catch late arrivals
```

**Problem 2: Data Drift**

```sql
-- Historical data corrected upstream
-- Incremental model never sees it!

-- Solution: Periodic full-refresh
dbt run --full-refresh --select fct_events

-- Or schedule full-refresh weekly
# models/fct_events.sql
{{ config(
    materialized='incremental',
    full_refresh=true if target.name == 'prod' and (run_started_at.weekday() == 6) else false
) }}
```

**Problem 3: Schema Changes**

```sql
-- Source adds new column
-- Incremental model needs full-refresh

-- Solution: Run with --full-refresh after schema changes
dbt run --full-refresh --select fct_events

-- Or use on_schema_change config
{{ config(
    materialized='incremental',
    on_schema_change='append_new_columns'
) }}
```

---

### DBT Configuration Hierarchy

**Precedence (highest to lowest):**

```
1. Model config block (in .sql file)
2. Property YAML (_models.yml)
3. dbt_project.yml
4. Default behavior
```

**Example:**

```yaml
# dbt_project.yml (lowest priority)
models:
  my_project:
    staging:
      +materialized: view
      +schema: staging
    marts:
      +materialized: table
      +schema: marts
```

```yaml
# models/marts/_marts.yml (medium priority)
models:
  - name: fct_orders
    config:
      materialized: incremental
      unique_key: order_id
```

```sql
-- models/marts/fct_orders.sql (highest priority)
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge',
    cluster_by=['order_date'],  -- Snowflake
    tags=['daily', 'critical']
) }}

SELECT ...
```

---

### Essential DBT Commands

```bash
# Development
dbt run                          # Build all models
dbt run --select stg_customers   # Build one model
dbt run --select staging.*       # Build folder
dbt run --select +fct_orders     # Model + upstream dependencies
dbt run --select fct_orders+     # Model + downstream dependencies
dbt run --select tag:daily       # Models with tag

# Testing
dbt test                         # All tests
dbt test --select fct_orders     # Tests for one model

# Incremental
dbt run --full-refresh           # Force full rebuild
dbt run --select state:modified+ # Changed models + downstream

# Documentation
dbt docs generate                # Generate docs
dbt docs serve                   # View in browser

# Compilation
dbt compile                      # See compiled SQL
dbt compile --select fct_orders

# Debugging
dbt debug                        # Test connection
dbt source freshness             # Check source data freshness

# Cleanup
dbt clean                        # Remove artifacts
```

---

### Real-World DBT Patterns

**Pattern 1: Layered Architecture**

```
Raw Data (sources)
    ↓
Staging (views - 1:1 with sources)
    ↓
Intermediate (ephemeral - business logic)
    ↓
Marts (tables/incremental - analytics)
```

**Pattern 2: Incremental Fact Table**

```sql
-- models/marts/fct_orders.sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge',
    cluster_by=['order_date']
) }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
    {% if is_incremental() %}
        WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
    {% endif %}
),

customers AS (
    SELECT * FROM {{ ref('dim_customers') }}
),

final AS (
    SELECT 
        o.order_id,
        o.customer_id,
        c.customer_name,
        o.order_date,
        o.amount,
        o.status,
        o.updated_at
    FROM orders o
    LEFT JOIN customers c
        ON o.customer_id = c.customer_id
)

SELECT * FROM final
```

**Pattern 3: Slowly Changing Dimension (SCD Type 2)**

```sql
-- snapshots/customers_snapshot.sql
{% snapshot customers_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='customer_id',
      strategy='timestamp',
      updated_at='updated_at'
    )
}}

SELECT * FROM {{ source('raw', 'customers') }}

{% endsnapshot %}

-- Creates history table with dbt_valid_from and dbt_valid_to
-- Track how customer attributes change over time
```

---

## Interview Strategy & Communication

### The Director-Level Difference

**What They're Testing:**

| Level | Interview Focus | Example Question |
|-------|----------------|------------------|
| Junior | Syntax | "Write a query to find duplicates" |
| Mid | Application | "How would you deduplicate this table?" |
| **Director** | **Strategy** | **"Design a system to prevent duplicates"** |

**At director level, they care about:**
- Strategic thinking (not just tactical)
- Communication (explaining to non-technical stakeholders)
- Trade-off analysis (no perfect solution exists)
- Team leadership (how you'd guide others)
- Business impact (ROI, not just technical excellence)

---

### The Answer Framework: Clarify → Structure → Trade-offs

#### Step 1: Clarify Before Solving

**Question:** "How would you optimize this slow query?"

**Don't jump to:** "Add an index on customer_id"

**Instead, clarify context:**
```
"Let me make sure I understand the full context:

- Is this a one-time analytical query or production dashboard?
- What's the current runtime and what's acceptable?
- How often does this run - on-demand, hourly, daily?
- What's the data volume we're working with?
- Are there any SLAs or business requirements?
- Can I see the execution plan?"
```

**Why this works:**
- Shows you think before acting (not random trial-and-error)
- Demonstrates understanding that context matters
- Solutions depend on requirements (one-time vs production)
- Gives you time to think

---

#### Step 2: Structure Your Answer

**Use a systematic framework:**

```
"I'd approach this systematically in three phases:

Phase 1 - Diagnose:
1. Check execution plan (EXPLAIN/Query Profile)
2. Identify bottleneck (scan, join, aggregation?)
3. Understand data characteristics (volume, distribution)

Phase 2 - Generate Solutions:
1. Quick wins (obvious inefficiencies)
2. Structural changes (clustering, distribution keys)
3. Architectural options (materialization, denormalization)

Phase 3 - Validate:
1. Test the change in dev
2. Measure improvement
3. Monitor for regressions
4. Document for team"
```

**Why this works:**
- Demonstrates methodical approach
- Shows you're not guessing randomly
- Proves you think about validation and monitoring
- Director-level thinking (not just "add index and hope")

---

#### Step 3: Discuss Trade-offs

**Question:** "Should we use incremental or table materialization?"

**Don't just say:** "Use incremental"

**Analyze trade-offs:**

```
"It depends on several factors. Let me walk through the trade-offs:

Arguments for TABLE:
- Simpler to maintain (no incremental logic bugs)
- Guarantees consistency (full refresh catches all changes)
- If table is small (<5GB), rebuild time is acceptable

Arguments for INCREMENTAL:
- If table is huge (100GB+), full refresh takes hours
- If data is mostly append-only, incremental is safe
- If we need frequent refreshes, can't wait for full rebuild

My recommendation:
Start with TABLE and monitor build times. If builds exceed 
30 minutes, switch to incremental. This follows the principle:
start simple, optimize when needed.

Risks of incremental:
Data drift if upstream corrections happen. Mitigation: schedule
weekly full-refresh to catch any drift.

Cost consideration:
Incremental saves compute ($X/month) but adds maintenance 
complexity (engineer time). At our scale, compute savings 
likely justify the complexity."
```

**Why this works:**
- Shows you think about multiple dimensions
- Demonstrates business acumen (cost vs complexity)
- Pragmatic (start simple, optimize later)
- Risk-aware (mentions data drift)
- Quantifies impact ($X/month)

---

### The STAR Method: Telling Compelling Stories

**When asked:** "Tell me about a time you optimized performance"

**Structure:** Situation → Task → Action → Result

**Bad Answer:**
```
"I added clustering and it got faster."
```

**Good Answer:**

**Situation:**
"At my last company, our main sales dashboard was taking 45 seconds 
to load, causing analysts to complain and sometimes timeout. This was 
a Snowflake warehouse with a 5TB orders table queried 200+ times daily."

**Task:**
"I needed to reduce query time to under 5 seconds to meet usability 
requirements while keeping costs reasonable."

**Action:**
"First, I analyzed the Query Profile and found we were scanning all 
5,000 micro-partitions when we only needed about 50. The dashboard 
always filtered by order_date in the last 90 days, but the table 
wasn't clustered.

I proposed adding clustering on order_date. Before implementing, I:
1. Created a zero-copy clone to test safely
2. Measured baseline performance (45s average)
3. Applied clustering and measured improvement (6s average)
4. Estimated cost: ~$50/month in automatic reclustering credits

I presented findings to my director with ROI calculation:
- Cost: $50/month in compute
- Benefit: 10 analysts × 30 seconds × 20 queries/day = 100 analyst-hours/month saved
- ROI: $50 cost vs ~$10,000 in productivity (100 hours × $100/hr)"

**Result:**
"We implemented clustering in production. Query time dropped from 
45s to 6s (87% improvement). The $50 monthly cost was approved given 
the clear ROI. Additionally, analysts were happier and used the 
dashboard more frequently, leading to better data-driven decisions 
across the organization."

**Why this works:**
- Specific numbers (45s → 6s, 87%, $50/month, $10K benefit)
- Shows systematic approach (test, measure, estimate, present)
- Demonstrates business thinking (ROI calculation)
- Includes stakeholder management (presented to director)
- Quantifies impact (productivity + behavioral change)

---

### Questions to Ask Them

**About Technical Challenges:**
- "What's the most challenging data engineering problem your team faces?"
- "How do you balance technical debt vs new features?"
- "What does your data stack look like and why did you choose it?"

**About Team & Culture:**
- "How does the data team collaborate with product and engineering?"
- "What does success look like in the first 90 days for this role?"
- "How do you approach professional development and mentoring?"

**About Strategy:**
- "Where do you see the biggest opportunities for data to drive business value?"
- "What's the company's data strategy for the next 12 months?"
- "How does the data team's roadmap align with company goals?"

**Why these are good:**
- Show you're thinking strategically
- Demonstrate interest in team dynamics
- Indicate you care about growth
- Prove you think beyond just technical work

---

### Red Flags to Avoid

**❌ Don't Say:**
- "I always use X" → Shows inflexibility
- "That's the best way" → Ignores context
- Technical jargon without explanation → Poor communication
- "It wasn't my fault" → Blames others
- "I don't know" (and stop) → Lack of problem-solving

**✅ Do Say:**
- "It depends on the use case..." → Shows contextual thinking
- "There are trade-offs to consider..." → Demonstrates maturity
- Explain concepts clearly → Good communication
- "We faced X, here's how I addressed it..." → Takes ownership
- "I haven't used X directly, but based on my experience with Y..." → Shows learning ability

---

### The Three Levels of Answers

**Level 1 (Junior): Syntax**
```
"You use RANK() function with PARTITION BY"
```

**Level 2 (Mid): Application**
```
"RANK() is appropriate here because we want ties to share the same 
rank, which matches the business requirement for this leaderboard"
```

**Level 3 (Director): Strategy**
```
"The choice between RANK(), DENSE_RANK(), and ROW_NUMBER() depends on 
business requirements for tie handling. For this leaderboard, I'd 
recommend DENSE_RANK() because marketing wants a 'gold, silver, bronze' 
display where ties don't create gaps.

However, I'd first verify this assumption with stakeholders - their 
actual requirement might differ from what's spec'd.

Additionally, I'd consider the materialization strategy. If this 
leaderboard is queried frequently, pre-computing and storing results 
would be more efficient than calculating on-demand. The trade-off is 
freshness vs performance - do users need real-time accuracy or is 
hourly refresh acceptable?

We should A/B test to validate the performance improvement justifies 
the added complexity."
```

**Aim for Level 3.**

---

### Final Day Before Interview Checklist

**Technical Review (2 hours):**
- ✅ Re-skim key concepts from this guide
- ✅ Practice drawing Snowflake architecture
- ✅ Write 3 complex SQL queries by hand
- ✅ Explain one DBT materialization strategy out loud

**Prepare Stories (1 hour):**
- ✅ Performance optimization (with metrics)
- ✅ Tough technical challenge (and resolution)
- ✅ Cost savings achievement (quantified)
- ✅ Team collaboration/leadership example

**Logistics:**
- ✅ Test video/audio setup
- ✅ Prepare notebook for notes
- ✅ Print resume copy
- ✅ Research company (recent news, tech stack)
- ✅ Prepare 3-5 questions to ask them

**Mental Prep:**
- Deep breaths
- They want you to succeed
- It's a conversation, not interrogation
- You're qualified (you got the interview!)

---

## Remember: You're Ready

**You've prepared:**
- ✅ Deep conceptual understanding (the "why")
- ✅ Technical implementation (the "how")
- ✅ Strategic thinking (the "when")
- ✅ Communication frameworks (the "explain")

**Tomorrow, focus on:**
1. **Clarify** before answering
2. **Structure** your responses
3. **Discuss trade-offs** (not just solutions)
4. **Use real examples** with metrics
5. **Think strategically** (business impact)
6. **Be yourself** (authentic confidence)

**You've got this! 🚀**

---

*Good luck with your director interview!*

*Remember: Directors care about how you think, not just what you know.*
