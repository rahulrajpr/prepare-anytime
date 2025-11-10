# 🐍 DataFrame & Dataset API - Interview Q&A

***

## 3.4 Column Operations & Functions

### 3.4.1 ❓ What is the syntax difference when passing multiple columns: `.drop("col1", "col2")` vs `.dropDuplicates(["col1", "col2"])`?
* **`.drop()`**: Uses **varargs** (Variable arguments); accepts multiple column names as direct string arguments. *Example: `df.drop("colA", "colB")`*.
* **`.dropDuplicates()`**: Requires a **List/Array** of strings; accepts a single collection of column names. *Example: `df.dropDuplicates(["colA", "colB"])`*.

### 3.4.2 ❓ When do you use varargs vs list for passing multiple column names?
* Use **Varargs** when the API method is designed to accept multiple positional string arguments (e.g., for dropping columns).
* Use a **List** when the API method expects column names to be grouped into a single collection (e.g., for subset operations like duplicate checking).

### 3.4.3 ❓ What is the difference between `count(*)`, `count(1)`, and `count(col)`?
* **`count(*)` / `count(1)`**: Counts the **total number of rows**, including nulls.
* **`count(col)`**: Counts the **number of non-null values** specifically in the column `col`.

### 3.4.4 ❓ How do these count variations handle null values differently?
* **`count(*)` / `count(1)`**: **Include** null rows in the count.
* **`count(col)`**: **Exclude** rows where the specified column is null. This measures data completeness.

### 3.4.5 ❓ What does `monotonically_increasing_id()` function generate? Is it guaranteed to be sequential?
* **Generates**: A column of **unique 64-bit integers** (LongType) per row.
* **Sequential**: **No, it is not guaranteed** to be globally sequential. Gaps are expected across partition boundaries.

### 3.4.6 ❓ What are the practical use cases for `monotonically_increasing_id()`?
* Generating **surrogate keys** for data ingestion.
* Creating a unique **row identifier** for lineage tracking (efficient as it avoids a full shuffle).

### 3.4.7 ❓ What is the difference between `row_number()`, `rank()`, and `dense_rank()` window functions?
| Function | Tie Handling | Output Sequence | Best Use Case |
| :--- | :--- | :--- | :--- |
| **`row_number()`** | Ignores ties, assigns unique number. | **Sequential** (1, 2, 3, 4) | Finding the **Top N** record (e.g., *most recent event*). |
| **`rank()`** | Same rank for ties, but **leaves a gap**. | **Gaps for Ties** (1, 2, 2, **4**) | Standard competition ranking. |
| **`dense_rank()`** | Same rank for ties, and **does not leave a gap**. | **No Gaps for Ties** (1, 2, 2, **3**) | Assigning performance tiers or classifications. |

### 3.4.8 ❓ When would you use `lead()` and `lag()` functions?
* **`lag(col, offset)`**: Accesses the value from a **previous** (past) row. *Use Case: Calculating month-over-month growth.*
* **`lead(col, offset)`**: Accesses the value from a **subsequent** (future) row. *Use Case: Comparing current value to a future price.*

### 3.4.9 ❓ What is the `first()` and `last()` aggregate function? How do they handle nulls?
* **Function**: Returns the first or last value encountered in a group.
* **Null Handling**: By default, they **ignore nulls**. Behavior can be configured using the `ignoreNulls` parameter.

### 3.4.10 ❓ Explain the difference between `collect_list()` and `collect_set()`.
* **`collect_list()`**: Aggregates values into a List/Array and **allows duplicates**.
* **`collect_set()`**: Aggregates values into a List/Array but **removes duplicates**.

### 3.4.11 ❓ What does `explode()` function do? Provide an example use case.
* **Function**: Transforms elements of an **Array or Map** column into **separate rows**.
* **Use Case Example**: Flattening a JSON field that contains an array of tags, creating one row per tag.

### 3.4.12 ❓ What is the difference between `explode()` and `explode_outer()`?
* **`explode()`**: **Drops rows** where the array is **null or empty** (lossy).
* **`explode_outer()`**: **Preserves rows** with null/empty arrays, creating a row with a **null** value for the exploded column (non-lossy).

### 3.4.13 ❓ What does `posexplode()` do and how is it different from `explode()`?
* **Function**: `posexplode()` explodes the array/map, and also returns the **position (index)** of the element.
* **Difference**: Returns **two output columns** (`position` and `value`) instead of just one (`value`).

### 3.4.14 ❓ When to use `posexplode()` vs `posexplode_outer()`?
* Use **`posexplode()`** when **element order/index is important** and you are fine **dropping** rows with empty arrays.
* Use **`posexplode_outer()`** when element order/index is important and you **must preserve** rows with empty arrays.

### 3.4.15 ❓ What is the difference between `explode()` and `posexplode()` in terms of output columns?
* **`explode()`**: Single output column with array values.
* **`posexplode()`**: Two output columns: the **position index** and the array **value**.

### 3.4.16 ❓ How does `inline()` differ from `inline_outer()` when working with arrays of structs?
* Both flatten an **Array of Structs** into **multiple columns** (one column per struct field).
* **Difference**: **`inline()`** drops rows on null/empty arrays, while **`inline_outer()`** preserves them, filling the new columns with nulls.

### 3.4.17 ❓ How do you use `array_contains()` function?
* **Usage**: Checks if a column of type ArrayType contains a specific value.
* **Returns**: A **Boolean column**.

### 3.4.18 ❓ What does `split()` function return and what is its data type?
* **Returns**: An **array of strings**.
* **Data Type**: `ArrayType(StringType)`.

### 3.4.19 ❓ How do you use `concat()` vs `concat_ws()` (concat with separator)?
* **`concat()`**: Joins strings **without a separator**.
* **`concat_ws()`**: Joins strings **with a specified separator** (`ws` = with separator).

### 3.4.20 ❓ What is `coalesce()` function and how does it differ from `coalesce()` for repartitioning?
* **`coalesce()` function (Column)**: Returns the **first non-null value** from a list of input columns.
* **`coalesce()` method (DataFrame)**: A DataFrame method that **reduces the number of partitions** (without a full shuffle).

### 3.4.21 ❓ What does `nvl()` or `ifnull()` do? Are they the same?
* **Function**: Returns the first expression if it is not null; otherwise, returns the second expression.
* **Same**: **Yes**, `ifnull()` is an alias for `nvl()` in Spark.

### 3.4.22 ❓ Explain `when().otherwise()` construct with examples.
* **Purpose**: Spark's programmatic equivalent of the **SQL `CASE WHEN`** statement.
* *Example:* `df.withColumn("Tier", when(col("score") > 90, "Gold").otherwise("Silver"))`

### 3.4.23 ❓ What is the difference between `withColumn()` and `select()` for adding/transforming columns?
* **`withColumn()`**: **Adds/replaces a single column**, preserving all existing columns.
* **`select()`**: **Defines the entire output column set**, allowing transformation, addition, and dropping of columns.

### 3.4.24 ❓ Can you use `withColumn()` multiple times in a chain? What are the performance implications?
* **Yes**, it can be chained.
* **Performance Implications**: Each call creates a **new DataFrame instance**. It's often clearer and sometimes more efficient to batch transformations within a single `.select()`.

### 3.4.25 ❓ What does `withColumnRenamed()` do? Can you rename multiple columns at once?
* **Function**: Renames a **single column**.
* **Multiple Renames**: **No**. Requires chaining multiple calls or using **`.select()`** with column aliases.

### 3.4.26 ❓ What is `selectExpr()` and when would you use it instead of `select()`?
* **`selectExpr()`**: Accepts **SQL expressions as strings** for column transformations.
* **Use Case**: Preferred when **SQL syntax is easier** or when expressions are **dynamically generated**.

### 3.4.27 ❓ How do you drop multiple columns efficiently?
* Use the **varargs** syntax with the `.drop()` method: `df.drop("col1", "col2", "col3")`.

### 3.4.28 ❓ What does `drop()` return if you try to drop a non-existent column?
* It returns the **original DataFrame unchanged** (no error is thrown).

***

## 3.5 String Functions

### 3.5.1 ❓ Explain the `regexp_extract()` function and its usage for pattern matching.
* **Function**: Extracts a matched substring from a string column using a **regular expression (regex)** pattern.
* **Usage**: Used for pattern-based data extraction (e.g., parsing IDs from log messages).

### 3.5.2 ❓ What is the difference between `regexp_extract()` and `regexp_replace()`?
* **`regexp_extract()`**: **Retrieves** the matching text.
* **`regexp_replace()`**: **Substitutes** the matching text with a replacement string.

### 3.5.3 ❓ How do you use `like()` and `rlike()` for pattern matching?
* **`like()`**: Uses **SQL wildcards** (`%`, `_`).
* **`rlike()`**: Uses **full Regular Expressions** (regex).

### 3.5.4 ❓ What is the difference between `like()`, `ilike()`, and `rlike()`?
| Function | Pattern Type | Case Sensitivity |
| :--- | :--- | :--- |
| **`like()`** | SQL Wildcards | **Case-Sensitive** |
| **`ilike()`** | SQL Wildcards | **Case-Insensitive** |
| **`rlike()`** | Regular Expressions | **Case-Sensitive** (by default) |

### 3.5.5 ❓ Which pattern matching function is case-insensitive?
* The **`ilike()`** function.

### 3.5.6 ❓ What pattern type does `rlike()` use (SQL wildcards or regex)?
* It uses **Regular Expressions** (regex).

### 3.5.7 ❓ What does `substring()` function do? What are its parameters?
* **Function**: Extracts a portion of a string.
* **Parameters**: `substring(str, pos, len)`: string column, **1-based** starting position, length.

### 3.5.8 ❓ How do you use `trim()`, `ltrim()`, and `rtrim()`?
* **`trim()`**: Removes whitespace from **both ends**.
* **`ltrim()`**: Removes whitespace from the **left** end.
* **`rtrim()`**: Removes whitespace from the **right** end.

### 3.5.9 ❓ What is `upper()`, `lower()`, `initcap()` used for?
* **`upper()`**: Converts text to **UPPERCASE**.
* **`lower()`**: Converts text to **lowercase**.
* **`initcap()`**: Converts to **Title Case** (first letter of each word is capitalized).

### 3.5.10 ❓ How do you use `lpad()` and `rpad()` for padding strings?
* **`lpad(str, len, pad)`**: Pads the string on the **left** to a specified total length.
* **`rpad()`**: Pads the string on the **right**.

### 3.5.11 ❓ What does `length()` function return for null values?
* It returns **`null`** for null input values.

### 3.5.12 ❓ How do you check if a string contains a substring in Spark?
* Use the **`.contains()`** method on the column object, the **`instr()`** function, or the **`like()`** function with the `%` wildcard.

***

## 3.6 Date & Time Functions

### 3.6.1 ❓ What are the key date and time functions in Spark?
* **`current_date()`**, **`current_timestamp()`**, **`date_add()`**, **`date_sub()`**.

### 3.6.2 ❓ How do you extract year, month, day from a date column?
* Use the dedicated functions: **`year()`, `month()`, and `dayofmonth()`**.

### 3.6.3 ❓ What does `datediff()` function calculate?
* Calculates the difference between two date columns, returned as the number of **days** (IntegerType).

### 3.6.4 ❓ How do you use `to_date()` and `to_timestamp()` for type conversion?
* **`to_date(string, format)`**: Converts a string to **DateType**.
* **`to_timestamp(string, format)`**: Converts a string to **TimestampType**.

### 3.6.5 ❓ What is the difference between `unix_timestamp()` and `from_unixtime()`?
* **`unix_timestamp()`**: Converts Timestamp/Date to **Unix epoch seconds**.
* **`from_unixtime()`**: Converts **epoch seconds** back to a TimestampType.

### 3.6.6 ❓ How do you handle different date formats when reading data?
* Use **`to_date(col, format_pattern)`** or specify the `dateFormat` option in the data source reader.

### 3.6.7 ❓ What does `date_format()` function do?
* Formats a Date or Timestamp column as a **string** using a specified pattern.

### 3.6.8 ❓ How do you calculate the difference between two timestamps?
* Use **`datediff()`** for days, or subtract the timestamps directly to get an **interval**.

### 3.6.9 ❓ What is `add_months()` function used for?
* Adds a specified number of **months** to a date, respecting calendar boundaries.

### 3.6.10 ❓ How do you get the last day of the month using `last_day()`?
* The **`last_day(date)`** function returns the date of the last day of the month.

### 3.6.11 ❓ What does `next_day()` function do?
* Returns the **first date after** a given date that matches the specified **day of the week**.

### 3.6.12 ❓ How do you handle timezone conversions in Spark?
* Use **`from_utc_timestamp()`** and **`to_utc_timestamp()`**.

***

## 3.6.1 Date & Time Intervals in Spark

### 3.6.1.1 ❓ What are the two main interval families in Spark?
1.  **YEAR-MONTH Intervals**.
2.  **DAY-TIME Intervals**.

### 3.6.1.2 ❓ When do you use YEAR-MONTH interval vs DAY-TIME interval?
* **YEAR-MONTH**: For **calendar-based** calculations (variable months).
* **DAY-TIME**: For **exact time-based** calculations (fixed hours/seconds).

### 3.6.1.3 ❓ Why can't you directly cast a day interval to a month interval?
* Because months have a **variable number of days** (28-31), making direct conversion ambiguous.

### 3.6.1.4 ❓ What is the common approximation used when converting between interval types?
* **1 month $\approx$ 30 days** (used for rough estimation only).

### 3.6.1.5 ❓ What is `make_interval()` function? What makes it unique?
* **Function**: Creates a single interval from multiple time components.
* **Unique**: It handles **both YEAR-MONTH and DAY-TIME** components in one call.

### 3.6.1.6 ❓ What parameters can you specify in `make_interval()`?
* `years`, `months`, `weeks`, `days`, `hours`, `minutes`, and `seconds`.

### 3.6.1.7 ❓ When would you use `make_interval()` over other interval functions?
* When creating complex, **mixed intervals**.

### 3.6.1.8 ❓ What is `make_dt_interval()` function? What is its specific purpose?
* **Function**: Creates **DAY-TIME** intervals specifically.
* **Purpose**: Ensuring calculations are based on **precise, fixed time units**.

### 3.6.1.9 ❓ What units does `make_dt_interval()` handle?
* `days`, `hours`, `minutes`, `seconds`.

### 3.6.1.10 ❓ When would you use `make_dt_interval()` instead of `make_interval()`?
* When working exclusively with **fixed time units** for high precision.

### 3.6.1.11 ❓ What is `make_ym_interval()` function? What is its specific purpose?
* **Function**: Creates **YEAR-MONTH** intervals specifically.
* **Purpose**: Ensuring calculations are **calendar-aware**.

### 3.6.1.12 ❓ How does `make_ym_interval()` handle variable month lengths correctly?
* It performs **calendar-aware arithmetic**, respecting the actual length of the target months.

### 3.6.1.13 ❓ When would you use `make_ym_interval()` for calendar-based calculations?
* When adding or subtracting months/years where **calendar correctness** is mandatory.

### 3.6.1.14 ❓ Compare `make_interval()` vs `make_dt_interval()` vs `make_ym_interval()` - when to use each?
* **`make_interval()`**: **General Purpose** for mixed components.
* **`make_dt_interval()`**: Use for **precision-based** time math.
* **`make_ym_interval()`**: Use for **calendar-based** month/year math.

***

## 3.6.2 Date Parsing & Formatting

### 3.6.2.1 ❓ What are the two main approaches to parsing dates in Spark SQL?
1.  The **`DATE()`** function (or `CAST AS DATE`).
2.  The **`TO_DATE(expr, format)`** function with an explicit format pattern.

### 3.6.2.2 ❓ What date format does default `DATE()` or `CAST AS DATE` reliably support?
* The **ISO format (`yyyy-MM-dd`)**.

### 3.6.2.3 ❓ What happens when you use `DATE()` on non-ISO format strings?
* It returns **`null`**.

### 3.6.2.4 ❓ When must you use `TO_DATE(expr, format)` instead of `DATE()`?
* When date strings are in **non-ISO formats**.

### 3.6.2.5 ❓ What format patterns are commonly used with `TO_DATE()`?
* `yyyy-MM-dd`, `MM/dd/yyyy`, `dd-MMM-yyyy`.

### 3.6.2.6 ❓ Are format pattern letters case-sensitive in `TO_DATE()`? Provide examples.
* **Yes**, they are **case-sensitive** (`MM` for Month vs. `mm` for minute).

### 3.6.2.7 ❓ What is the difference between 'MM' and 'MMM' in date format patterns?
* **`MM`**: Month as a **number** (01-12).
* **`MMM`**: Month as an **abbreviated name** (Jan, Feb).

### 3.6.2.8 ❓ What is the difference between 'd', 'dd', and 'D' in date format patterns?
* **`d`**: Day of month (1-31).
* **`dd`**: Day of month with **leading zero** (01-31).
* **`D`**: **Day of year** (1-366).

### 3.6.2.9 ❓ How does `DATE()` handle timestamp strings with time components?
* It **truncates the time component**, extracting only the date part.

### 3.6.2.10 ❓ What does `TO_DATE()` return for unparseable strings?
* It returns **`null`**.

### 3.6.2.11 ❓ What are best practices for handling date formats in Spark pipelines?
* Always use **explicit format patterns** and validate parsing results (handle `null`s).

### 3.6.2.12 ❓ What is `to_char()` function used for?
* Formats a Date/Timestamp column **as a string** (same as `date_format()`).

### 3.6.2.13 ❓ How do you use `to_timestamp()` with custom formats?
* `to_timestamp(string_col, 'custom_datetime_pattern')`.

### 3.6.2.14 ❓ What is the Java `DateTimeFormatter` pattern syntax used in Spark?
* Spark uses the **Java `DateTimeFormatter`** pattern syntax.
