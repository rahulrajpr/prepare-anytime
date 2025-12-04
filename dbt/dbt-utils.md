# 🛠️ dbt_utils: Essential Functions Guide

<div align="center">

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![dbt_utils](https://img.shields.io/badge/dbt__utils-00C853?style=for-the-badge)
![Utilities](https://img.shields.io/badge/Utilities-2196F3?style=for-the-badge)

</div>

A comprehensive guide to the most commonly used dbt_utils functions - the essential toolkit for every dbt developer.

---

## 📑 Table of Contents

1. [🔍 What is dbt_utils?](#-what-is-dbt_utils)
2. [⚙️ Installation](#️-installation)
3. [🔑 SQL Helpers](#-sql-helpers)
4. [📊 Generic Tests](#-generic-tests)
5. [🔄 Cross-Database Macros](#-cross-database-macros)
6. [📅 Date & Time Functions](#-date--time-functions)
7. [🎯 Data Generation](#-data-generation)
8. [🔗 Relationship Functions](#-relationship-functions)
9. [💡 Web Analytics](#-web-analytics)
10. [📈 Best Practices](#-best-practices)

---

## 🔍 What is dbt_utils?

**dbt_utils** is the most popular dbt package, providing a collection of macros and tests that extend dbt's functionality. It's maintained by dbt Labs and is considered essential for most dbt projects.

### Why Use dbt_utils?

✅ **Cross-Database Compatibility** - Works across Snowflake, BigQuery, Redshift, etc.  
✅ **Tested & Maintained** - Battle-tested by thousands of projects  
✅ **Time Savers** - Common patterns pre-built  
✅ **Best Practices** - Implements industry standards  
✅ **Active Development** - Regular updates and improvements

---

## ⚙️ Installation

### Add to packages.yml

```yaml
# packages.yml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1  # Check for latest version
```

### Install the package

```bash
dbt deps
```

### Verify installation

```bash
dbt list --resource-type macro --package dbt_utils
```

---

## 🔑 SQL Helpers

### 1. surrogate_key() ⭐⭐⭐⭐⭐

**Purpose:** Generate a unique hash key from multiple columns (composite key).

**Syntax:**
```sql
{{ dbt_utils.surrogate_key(['column1', 'column2', ...]) }}
```

**Example:**
```sql
-- models/dim_customers.sql

select
    {{ dbt_utils.surrogate_key(['customer_id', 'email']) }} as customer_key,
    customer_id,
    email,
    first_name,
    last_name
from {{ ref('stg_customers') }}
```

**Output:**
```sql
select
    md5(cast(coalesce(cast(customer_id as varchar), '') as varchar) || '-' || 
        cast(coalesce(cast(email as varchar), '') as varchar)) as customer_key,
    customer_id,
    email,
    first_name,
    last_name
from stg_customers
```

**Use Cases:**
- Creating primary keys for dimension tables
- Joining tables without natural keys
- Deduplication logic
- Creating unique identifiers

---

### 2. generate_surrogate_key() ⭐⭐⭐⭐⭐

**Purpose:** Similar to `surrogate_key()` but newer, with better NULL handling.

**Syntax:**
```sql
{{ dbt_utils.generate_surrogate_key(['column1', 'column2']) }}
```

**Example:**
```sql
select
    {{ dbt_utils.generate_surrogate_key(['order_id', 'line_number']) }} as order_line_key,
    order_id,
    line_number,
    product_id,
    quantity
from {{ ref('stg_order_items') }}
```

**Difference from surrogate_key:**
- Better performance
- Improved NULL handling
- Recommended for new projects

---

### 3. star() ⭐⭐⭐⭐⭐

**Purpose:** Select all columns from a relation, with optional exclusions.

**Syntax:**
```sql
{{ dbt_utils.star(from=ref('model_name'), except=['column1', 'column2']) }}
```

**Example:**
```sql
-- Select all columns except sensitive ones
select
    {{ dbt_utils.star(from=ref('raw_customers'), except=['ssn', 'credit_card', 'password']) }}
from {{ ref('raw_customers') }}
```

**Advanced Usage:**
```sql
-- Rename columns while selecting
select
    {{ dbt_utils.star(
        from=ref('raw_customers'), 
        except=['id'],
        relation_alias='c',
        prefix='customer_'
    ) }},
    id as customer_id
from {{ ref('raw_customers') }} as c
```

**Use Cases:**
- Excluding PII fields
- Avoiding SELECT *
- Staging models
- Column renaming

---

### 4. union_relations() ⭐⭐⭐⭐⭐

**Purpose:** Union multiple tables/views with automatic column alignment.

**Syntax:**
```sql
{{ dbt_utils.union_relations(
    relations=[ref('table1'), ref('table2'), ref('table3')],
    exclude=['column_to_exclude'],
    include=['column_to_include']
) }}
```

**Example:**
```sql
-- Union multiple years of data
{{ config(materialized='view') }}

{{ dbt_utils.union_relations(
    relations=[
        ref('orders_2021'),
        ref('orders_2022'),
        ref('orders_2023'),
        ref('orders_2024')
    ],
    source_column_name='_source_table'
) }}
```

**Output:**
```sql
select
    '2021' as _source_table,
    order_id,
    customer_id,
    order_date,
    order_total
from orders_2021

union all

select
    '2022' as _source_table,
    order_id,
    customer_id,
    order_date,
    order_total
from orders_2022
-- ... and so on
```

**Use Cases:**
- Combining historical tables
- Multi-source data integration
- Schema evolution handling
- Data lake queries

---

### 5. pivot() ⭐⭐⭐⭐

**Purpose:** Transform rows into columns (SQL pivot operation).

**Syntax:**
```sql
{{ dbt_utils.pivot(
    column='column_to_pivot',
    values=['value1', 'value2', 'value3'],
    agg='sum',
    then_value='1',
    else_value='0',
    prefix='',
    suffix=''
) }}
```

**Example:**
```sql
-- Pivot product categories into columns
select
    customer_id,
    {{ dbt_utils.pivot(
        column='product_category',
        values=dbt_utils.get_column_values(ref('orders'), 'product_category'),
        agg='sum',
        then_value='order_total',
        else_value='0',
        prefix='revenue_'
    ) }}
from {{ ref('orders') }}
group by 1
```

**Output:**
```sql
select
    customer_id,
    sum(case when product_category = 'Electronics' then order_total else 0 end) as revenue_Electronics,
    sum(case when product_category = 'Clothing' then order_total else 0 end) as revenue_Clothing,
    sum(case when product_category = 'Food' then order_total else 0 end) as revenue_Food
from orders
group by 1
```

**Use Cases:**
- Creating wide tables for BI tools
- Cohort analysis
- Time-series transformations
- Category-based metrics

---

### 6. unpivot() ⭐⭐⭐⭐

**Purpose:** Transform columns into rows (reverse of pivot).

**Syntax:**
```sql
{{ dbt_utils.unpivot(
    relation=ref('wide_table'),
    exclude=['id_column'],
    remove=['prefix_'],
    field_name='metric_name',
    value_name='metric_value'
) }}
```

**Example:**
```sql
-- Transform wide revenue table to long format
with wide_data as (
    select
        date,
        revenue_jan,
        revenue_feb,
        revenue_mar
    from {{ ref('monthly_revenue') }}
)

select
    date,
    metric_name,
    metric_value
from {{ dbt_utils.unpivot(
    relation=ref('monthly_revenue'),
    exclude=['date'],
    field_name='month',
    value_name='revenue'
) }}
```

**Output:**
```sql
select date, 'revenue_jan' as month, revenue_jan as revenue from monthly_revenue
union all
select date, 'revenue_feb' as month, revenue_feb as revenue from monthly_revenue
union all
select date, 'revenue_mar' as month, revenue_mar as revenue from monthly_revenue
```

---

### 7. get_column_values() ⭐⭐⭐⭐⭐

**Purpose:** Get a list of distinct values from a column (at compile time).

**Syntax:**
```sql
{% set values = dbt_utils.get_column_values(table=ref('model'), column='column_name') %}
```

**Example:**
```sql
-- Get all product categories dynamically
{% set categories = dbt_utils.get_column_values(
    table=ref('products'),
    column='category'
) %}

select
    product_id,
    product_name,
    {%- for category in categories %}
    sum(case when category = '{{ category }}' then sales else 0 end) as {{ category }}_sales
    {%- if not loop.last %},{% endif %}
    {%- endfor %}
from {{ ref('sales') }}
group by 1, 2
```

**Use Cases:**
- Dynamic column generation
- Creating pivot tables
- Building test cases
- Parameter generation

---

### 8. get_relations_by_pattern() ⭐⭐⭐

**Purpose:** Get a list of relations matching a pattern.

**Syntax:**
```sql
{% set tables = dbt_utils.get_relations_by_pattern(
    schema_pattern='%',
    table_pattern='stg_%'
) %}
```

**Example:**
```sql
-- Union all staging tables
{{ config(materialized='view') }}

{% set staging_tables = dbt_utils.get_relations_by_pattern(
    schema_pattern='staging',
    table_pattern='stg_orders_%'
) %}

{{ dbt_utils.union_relations(relations=staging_tables) }}
```

---

### 9. group_by() ⭐⭐⭐⭐⭐

**Purpose:** Generate GROUP BY clause with column numbers.

**Syntax:**
```sql
{{ dbt_utils.group_by(n=3) }}
```

**Example:**
```sql
select
    customer_id,
    order_date,
    product_category,
    sum(order_total) as total_revenue,
    count(*) as order_count
from {{ ref('orders') }}
{{ dbt_utils.group_by(n=3) }}  -- GROUP BY 1, 2, 3
```

**Output:**
```sql
select
    customer_id,
    order_date,
    product_category,
    sum(order_total) as total_revenue,
    count(*) as order_count
from orders
group by 1, 2, 3
```

**Use Cases:**
- Cleaner SQL code
- Avoiding column name repetition
- Easier refactoring

---

### 10. deduplicate() ⭐⭐⭐⭐

**Purpose:** Remove duplicate rows based on partition and order.

**Syntax:**
```sql
{{ dbt_utils.deduplicate(
    relation=ref('raw_table'),
    partition_by='id',
    order_by='updated_at desc'
) }}
```

**Example:**
```sql
-- Keep only the most recent record per customer
{{ config(materialized='view') }}

{{ dbt_utils.deduplicate(
    relation=ref('raw_customers'),
    partition_by='customer_id',
    order_by='updated_at desc'
) }}
```

**Output:**
```sql
select *
from (
    select
        *,
        row_number() over (
            partition by customer_id
            order by updated_at desc
        ) as _row_number
    from raw_customers
) as subquery
where _row_number = 1
```

**Use Cases:**
- Cleaning duplicate data
- Getting latest records
- Data quality fixes
- Staging layer transformations

---

## 📊 Generic Tests

### 1. unique_combination_of_columns ⭐⭐⭐⭐⭐

**Purpose:** Test that a combination of columns is unique.

**Syntax:**
```yaml
tests:
  - dbt_utils.unique_combination_of_columns:
      combination_of_columns:
        - column1
        - column2
```

**Example:**
```yaml
# models/schema.yml

version: 2

models:
  - name: order_items
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - order_id
            - line_number
    
    columns:
      - name: order_id
        description: "Order identifier"
      
      - name: line_number
        description: "Line item number within order"
```

**Use Cases:**
- Testing composite keys
- Validating grain
- Ensuring data quality

---

### 2. expression_is_true ⭐⭐⭐⭐⭐

**Purpose:** Test that a SQL expression evaluates to true.

**Syntax:**
```yaml
tests:
  - dbt_utils.expression_is_true:
      expression: "column_a > column_b"
```

**Example:**
```yaml
models:
  - name: orders
    tests:
      # Order total should equal sum of line items
      - dbt_utils.expression_is_true:
          expression: "order_total = (select sum(line_total) from order_items where order_items.order_id = orders.order_id)"
    
    columns:
      - name: order_total
        tests:
          - dbt_utils.expression_is_true:
              expression: ">= 0"  # No negative orders
      
      - name: discount_amount
        tests:
          - dbt_utils.expression_is_true:
              expression: "<= order_subtotal"  # Discount can't exceed subtotal
      
      - name: order_date
        tests:
          - dbt_utils.expression_is_true:
              expression: "<= current_date"  # No future orders
```

**Use Cases:**
- Business logic validation
- Cross-column validation
- Range checks
- Complex assertions

---

### 3. recency ⭐⭐⭐⭐⭐

**Purpose:** Test that a timestamp column contains recent data.

**Syntax:**
```yaml
tests:
  - dbt_utils.recency:
      datepart: day
      field: created_at
      interval: 1
```

**Example:**
```yaml
models:
  - name: events
    description: "Real-time event stream"
    tests:
      - dbt_utils.recency:
          datepart: hour
          field: event_timestamp
          interval: 2  # Fail if no events in last 2 hours
  
  - name: daily_orders
    tests:
      - dbt_utils.recency:
          datepart: day
          field: order_date
          interval: 1  # Fail if no orders yesterday
```

**Use Cases:**
- Data freshness checks
- Pipeline monitoring
- SLA validation
- Alerting on stale data

---

### 4. at_least_one ⭐⭐⭐⭐

**Purpose:** Test that a column has at least one non-null value.

**Syntax:**
```yaml
tests:
  - dbt_utils.at_least_one:
      column_name: column_name
```

**Example:**
```yaml
models:
  - name: customers
    tests:
      - dbt_utils.at_least_one:
          column_name: customer_id
```

---

### 5. not_constant ⭐⭐⭐⭐

**Purpose:** Test that a column has more than one distinct value.

**Syntax:**
```yaml
tests:
  - dbt_utils.not_constant:
      column_name: column_name
```

**Example:**
```yaml
models:
  - name: products
    columns:
      - name: price
        tests:
          - dbt_utils.not_constant  # Ensures prices vary
      
      - name: category
        tests:
          - dbt_utils.not_constant  # Ensures multiple categories exist
```

---

### 6. cardinality_equality ⭐⭐⭐⭐

**Purpose:** Test that two columns have the same number of distinct values.

**Syntax:**
```yaml
tests:
  - dbt_utils.cardinality_equality:
      field: column_name
      to: ref('other_table')
      to_field: other_column
```

**Example:**
```yaml
models:
  - name: orders
    tests:
      - dbt_utils.cardinality_equality:
          field: customer_id
          to: ref('customers')
          to_field: customer_id
          # Ensures all customers in orders exist in customers table
```

---

### 7. equal_rowcount ⭐⭐⭐⭐

**Purpose:** Test that two models have the same number of rows.

**Syntax:**
```yaml
tests:
  - dbt_utils.equal_rowcount:
      compare_model: ref('other_model')
```

**Example:**
```yaml
models:
  - name: orders_staging
    tests:
      - dbt_utils.equal_rowcount:
          compare_model: source('raw', 'orders')
```

---

### 8. fewer_rows_than ⭐⭐⭐

**Purpose:** Test that a model has fewer rows than another model.

**Syntax:**
```yaml
tests:
  - dbt_utils.fewer_rows_than:
      compare_model: ref('other_model')
```

**Example:**
```yaml
models:
  - name: high_value_customers
    tests:
      - dbt_utils.fewer_rows_than:
          compare_model: ref('all_customers')
```

---

### 9. not_null_proportion ⭐⭐⭐⭐

**Purpose:** Test that a column has a minimum proportion of non-null values.

**Syntax:**
```yaml
tests:
  - dbt_utils.not_null_proportion:
      at_least: 0.95
```

**Example:**
```yaml
models:
  - name: customers
    columns:
      - name: email
        tests:
          - dbt_utils.not_null_proportion:
              at_least: 0.99  # At least 99% of customers should have email
      
      - name: phone
        tests:
          - dbt_utils.not_null_proportion:
              at_least: 0.80  # At least 80% should have phone
```

---

### 10. relationships_where ⭐⭐⭐⭐⭐

**Purpose:** Test referential integrity with a WHERE clause.

**Syntax:**
```yaml
tests:
  - dbt_utils.relationships_where:
      to: ref('other_model')
      field: other_column
      from_condition: "column_a = 'value'"
      to_condition: "column_b = 'value'"
```

**Example:**
```yaml
models:
  - name: orders
    columns:
      - name: customer_id
        tests:
          - dbt_utils.relationships_where:
              to: ref('customers')
              field: customer_id
              from_condition: "order_status != 'cancelled'"
              # Only check active orders have valid customers
```

---

## 🔄 Cross-Database Macros

### 1. date_trunc() ⭐⭐⭐⭐⭐

**Purpose:** Cross-database date truncation.

**Syntax:**
```sql
{{ dbt_utils.date_trunc(datepart, date) }}
```

**Example:**
```sql
select
    {{ dbt_utils.date_trunc('month', 'order_date') }} as order_month,
    {{ dbt_utils.date_trunc('week', 'order_date') }} as order_week,
    {{ dbt_utils.date_trunc('day', 'order_date') }} as order_day,
    count(*) as order_count
from {{ ref('orders') }}
group by 1, 2, 3
```

**Cross-Database Support:**
- Snowflake: `date_trunc('month', order_date)`
- BigQuery: `date_trunc(order_date, month)`
- Redshift: `date_trunc('month', order_date)`
- Postgres: `date_trunc('month', order_date)`

---

### 2. datediff() ⭐⭐⭐⭐⭐

**Purpose:** Cross-database date difference calculation.

**Syntax:**
```sql
{{ dbt_utils.datediff(first_date, second_date, datepart) }}
```

**Example:**
```sql
select
    order_id,
    order_date,
    ship_date,
    {{ dbt_utils.datediff('order_date', 'ship_date', 'day') }} as days_to_ship,
    {{ dbt_utils.datediff('order_date', 'current_date', 'month') }} as months_since_order
from {{ ref('orders') }}
```

---

### 3. split_part() ⭐⭐⭐⭐⭐

**Purpose:** Cross-database string splitting.

**Syntax:**
```sql
{{ dbt_utils.split_part(string_text, delimiter_text, part_number) }}
```

**Example:**
```sql
select
    email,
    {{ dbt_utils.split_part('email', "'@'", 1) }} as email_user,
    {{ dbt_utils.split_part('email', "'@'", 2) }} as email_domain
from {{ ref('customers') }}
```

---

### 4. concat() ⭐⭐⭐⭐

**Purpose:** Cross-database string concatenation.

**Syntax:**
```sql
{{ dbt_utils.concat(['string1', 'string2', ...]) }}
```

**Example:**
```sql
select
    customer_id,
    {{ dbt_utils.concat(['first_name', "' '", 'last_name']) }} as full_name,
    {{ dbt_utils.concat(['street', "', '", 'city', "', '", 'state']) }} as full_address
from {{ ref('customers') }}
```

---

### 5. cast_bool_to_text() ⭐⭐⭐

**Purpose:** Cross-database boolean to text conversion.

**Syntax:**
```sql
{{ dbt_utils.cast_bool_to_text(field) }}
```

**Example:**
```sql
select
    order_id,
    {{ dbt_utils.cast_bool_to_text('is_shipped') }} as ship_status_text
from {{ ref('orders') }}
```

---

### 6. safe_cast() ⭐⭐⭐⭐

**Purpose:** Cross-database safe type casting.

**Syntax:**
```sql
{{ dbt_utils.safe_cast(field, type) }}
```

**Example:**
```sql
select
    order_id,
    {{ dbt_utils.safe_cast('order_total', dbt_utils.type_numeric()) }} as order_total_numeric,
    {{ dbt_utils.safe_cast('order_date', dbt_utils.type_timestamp()) }} as order_timestamp
from {{ ref('orders') }}
```

---

## 📅 Date & Time Functions

### 1. date_spine() ⭐⭐⭐⭐⭐

**Purpose:** Generate a series of dates.

**Syntax:**
```sql
{{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2020-01-01' as date)",
    end_date="cast('2025-12-31' as date)"
) }}
```

**Example:**
```sql
-- Create a calendar table
{{ config(materialized='table') }}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="dateadd(year, 1, current_date)"
    ) }}
)

select
    date_day,
    extract(year from date_day) as year,
    extract(month from date_day) as month,
    extract(day from date_day) as day,
    extract(dayofweek from date_day) as day_of_week,
    case extract(dayofweek from date_day)
        when 0 then 'Sunday'
        when 1 then 'Monday'
        when 2 then 'Tuesday'
        when 3 then 'Wednesday'
        when 4 then 'Thursday'
        when 5 then 'Friday'
        when 6 then 'Saturday'
    end as day_name,
    case
        when extract(dayofweek from date_day) in (0, 6) then true
        else false
    end as is_weekend
from date_spine
```

**Use Cases:**
- Calendar dimension tables
- Gap analysis
- Time series analysis
- Revenue forecasting

---

### 2. dateadd() ⭐⭐⭐⭐⭐

**Purpose:** Cross-database date addition.

**Syntax:**
```sql
{{ dbt_utils.dateadd(datepart, interval, from_date_or_timestamp) }}
```

**Example:**
```sql
select
    order_date,
    {{ dbt_utils.dateadd('day', 7, 'order_date') }} as expected_delivery,
    {{ dbt_utils.dateadd('month', 1, 'order_date') }} as one_month_later,
    {{ dbt_utils.dateadd('year', -1, 'order_date') }} as one_year_ago
from {{ ref('orders') }}
```

---

### 3. last_day() ⭐⭐⭐⭐

**Purpose:** Get the last day of a month.

**Syntax:**
```sql
{{ dbt_utils.last_day(date, datepart) }}
```

**Example:**
```sql
select
    order_date,
    {{ dbt_utils.last_day('order_date', 'month') }} as end_of_month,
    {{ dbt_utils.last_day('order_date', 'quarter') }} as end_of_quarter
from {{ ref('orders') }}
```

---

## 🎯 Data Generation

### 1. generate_series() ⭐⭐⭐⭐

**Purpose:** Generate a series of numbers.

**Syntax:**
```sql
{{ dbt_utils.generate_series(upper_bound) }}
```

**Example:**
```sql
-- Generate 1 to 12 for months
with months as (
    select {{ dbt_utils.generate_series(12) }} as month_number
)

select
    month_number,
    case month_number
        when 1 then 'January'
        when 2 then 'February'
        when 3 then 'March'
        when 4 then 'April'
        when 5 then 'May'
        when 6 then 'June'
        when 7 then 'July'
        when 8 then 'August'
        when 9 then 'September'
        when 10 then 'October'
        when 11 then 'November'
        when 12 then 'December'
    end as month_name
from months
```

---

## 🔗 Relationship Functions

### 1. get_relations_by_prefix() ⭐⭐⭐

**Purpose:** Get all relations with a specific prefix.

**Syntax:**
```sql
{% set relations = dbt_utils.get_relations_by_prefix(
    schema='schema_name',
    prefix='table_prefix'
) %}
```

**Example:**
```sql
-- Union all staging tables
{% set staging_relations = dbt_utils.get_relations_by_prefix(
    schema='staging',
    prefix='stg_'
) %}

{{ dbt_utils.union_relations(relations=staging_relations) }}
```

---

## 💡 Web Analytics

### 1. get_url_parameter() ⭐⭐⭐⭐

**Purpose:** Extract query parameter from URL.

**Syntax:**
```sql
{{ dbt_utils.get_url_parameter(field, url_parameter) }}
```

**Example:**
```sql
select
    session_id,
    landing_page_url,
    {{ dbt_utils.get_url_parameter('landing_page_url', 'utm_source') }} as utm_source,
    {{ dbt_utils.get_url_parameter('landing_page_url', 'utm_medium') }} as utm_medium,
    {{ dbt_utils.get_url_parameter('landing_page_url', 'utm_campaign') }} as utm_campaign
from {{ ref('sessions') }}
```

---

### 2. get_url_host() ⭐⭐⭐

**Purpose:** Extract host from URL.

**Syntax:**
```sql
{{ dbt_utils.get_url_host(field) }}
```

**Example:**
```sql
select
    referrer_url,
    {{ dbt_utils.get_url_host('referrer_url') }} as referrer_domain
from {{ ref('sessions') }}
```

---

### 3. get_url_path() ⭐⭐⭐

**Purpose:** Extract path from URL.

**Syntax:**
```sql
{{ dbt_utils.get_url_path(field) }}
```

**Example:**
```sql
select
    page_url,
    {{ dbt_utils.get_url_path('page_url') }} as page_path
from {{ ref('page_views') }}
```

---

## 📈 Best Practices

### 1. 🎯 Use Surrogate Keys Consistently

```sql
-- ✅ GOOD: Consistent key generation
{{ config(materialized='table') }}

select
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'order_date']) }} as daily_customer_key,
    customer_id,
    order_date,
    sum(order_total) as total_revenue
from {{ ref('orders') }}
group by 1, 2, 3

-- ❌ BAD: Inconsistent approach
select
    md5(customer_id || order_date) as daily_customer_key,  -- Manual hash
    ...
```

---

### 2. ⚡ Leverage get_column_values() for Dynamic SQL

```sql
-- ✅ GOOD: Dynamic pivot
{% set categories = dbt_utils.get_column_values(
    table=ref('products'),
    column='category'
) %}

select
    customer_id,
    {{ dbt_utils.pivot(
        column='category',
        values=categories,
        agg='sum',
        then_value='order_total'
    ) }}
from {{ ref('orders') }}
group by 1

-- ❌ BAD: Hardcoded values
select
    customer_id,
    sum(case when category = 'Electronics' then order_total end) as electronics_total,
    sum(case when category = 'Clothing' then order_total end) as clothing_total
    -- What if new categories are added?
```

---

### 3. 📊 Comprehensive Testing

```yaml
# ✅ GOOD: Multiple test types
models:
  - name: fct_orders
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - order_id
            - line_number
      
      - dbt_utils.recency:
          datepart: day
          field: order_date
          interval: 1
      
      - dbt_utils.expression_is_true:
          expression: "order_total >= 0"
    
    columns:
      - name: customer_id
        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id

# ❌ BAD: Minimal testing
models:
  - name: fct_orders
    columns:
      - name: order_id
        tests:
          - unique
```

---

### 4. 🔄 Use Cross-Database Macros

```sql
-- ✅ GOOD: Cross-database compatible
select
    {{ dbt_utils.date_trunc('month', 'order_date') }} as order_month,
    {{ dbt_utils.datediff('order_date', 'ship_date', 'day') }} as days_to_ship,
    {{ dbt_utils.concat(['first_name', "' '", 'last_name']) }} as full_name
from {{ ref('orders') }}

-- ❌ BAD: Database-specific syntax
select
    date_trunc('month', order_date) as order_month,  -- Snowflake only
    datediff(day, order_date, ship_date) as days_to_ship,  -- Won't work in BigQuery
    first_name || ' ' || last_name as full_name  -- Different across databases
```

---

### 5. 📅 Build Calendar/Date Dimension

```sql
-- ✅ GOOD: Reusable date dimension
{{ config(materialized='table') }}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="dateadd(year, 2, current_date)"
    ) }}
)

select
    date_day,
    extract(year from date_day) as year,
    extract(quarter from date_day) as quarter,
    extract(month from date_day) as month,
    extract(week from date_day) as week_of_year,
    extract(dayofweek from date_day) as day_of_week,
    {{ dbt_utils.last_day('date_day', 'month') }} as last_day_of_month,
    case when extract(dayofweek from date_day) in (0, 6) then true else false end as is_weekend
from date_spine
```

---

### 6. 🧹 Data Quality Framework

```yaml
# Create a comprehensive testing framework
version: 2

models:
  - name: dim_customers
    description: "Customer dimension table"
    
    tests:
      # Table-level tests
      - dbt_utils.recency:
          datepart: day
          field: updated_at
          interval: 1
      
      - dbt_utils.at_least_one:
          column_name: customer_id
    
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null
      
      - name: email
        tests:
          - unique
          - not_null
          - dbt_utils.not_constant
      
      - name: lifetime_value
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      
      - name: account_status
        tests:
          - accepted_values:
              values: ['active', 'inactive', 'churned']
          - dbt_utils.not_constant
```

---

## 🎓 Real-World Examples

### Example 1: Customer Segmentation with Pivot

```sql
-- models/marts/customer_product_matrix.sql

{{ config(materialized='table') }}

{% set product_categories = dbt_utils.get_column_values(
    table=ref('stg_products'),
    column='category'
) %}

with customer_orders as (
    select
        o.customer_id,
        p.category,
        sum(oi.line_total) as category_revenue
    from {{ ref('stg_orders') }} o
    inner join {{ ref('stg_order_items') }} oi
        on o.order_id = oi.order_id
    inner join {{ ref('stg_products') }} p
        on oi.product_id = p.product_id
    group by 1, 2
)

select
    customer_id,
    {{ dbt_utils.pivot(
        column='category',
        values=product_categories,
        agg='sum',
        then_value='category_revenue',
        else_value='0',
        prefix='revenue_'
    ) }}
from customer_orders
{{ dbt_utils.group_by(n=1) }}
```

---

### Example 2: Time Series Analysis with Date Spine

```sql
-- models/marts/daily_revenue_complete.sql

{{ config(materialized='table') }}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2023-01-01' as date)",
        end_date="current_date"
    ) }}
),

daily_orders as (
    select
        {{ dbt_utils.date_trunc('day', 'order_date') }} as order_day,
        sum(order_total) as daily_revenue,
        count(*) as order_count
    from {{ ref('fct_orders') }}
    where order_status = 'completed'
    group by 1
)

select
    d.date_day,
    coalesce(o.daily_revenue, 0) as daily_revenue,
    coalesce(o.order_count, 0) as order_count,
    -- 7-day moving average
    avg(coalesce(o.daily_revenue, 0)) over (
        order by d.date_day
        rows between 6 preceding and current row
    ) as revenue_7d_ma,
    -- Year over year comparison
    {{ dbt_utils.dateadd('year', -1, 'd.date_day') }} as same_day_last_year
from date_spine d
left join daily_orders o
    on d.date_day = o.order_day
order by d.date_day
```

---

### Example 3: Multi-Source Data Integration

```sql
-- models/staging/stg_all_orders.sql

{{ config(materialized='view') }}

{% set order_tables = [
    source('shopify', 'orders'),
    source('amazon', 'orders'),
    source('ebay', 'orders')
] %}

with unioned as (
    {{ dbt_utils.union_relations(
        relations=order_tables,
        source_column_name='_source_system'
    ) }}
),

standardized as (
    select
        {{ dbt_utils.generate_surrogate_key(['order_id', '_source_system']) }} as unified_order_id,
        _source_system as source_system,
        order_id,
        customer_id,
        {{ dbt_utils.cast_bool_to_text('is_paid') }} as payment_status,
        {{ dbt_utils.safe_cast('order_total', dbt_utils.type_numeric()) }} as order_total,
        order_date
    from unioned
)

select * from standardized
```

---

### Example 4: Web Analytics Attribution

```sql
-- models/marts/session_attribution.sql

{{ config(materialized='table') }}

select
    session_id,
    user_id,
    landing_page,
    
    -- Extract UTM parameters
    {{ dbt_utils.get_url_parameter('landing_page', 'utm_source') }} as utm_source,
    {{ dbt_utils.get_url_parameter('landing_page', 'utm_medium') }} as utm_medium,
    {{ dbt_utils.get_url_parameter('landing_page', 'utm_campaign') }} as utm_campaign,
    {{ dbt_utils.get_url_parameter('landing_page', 'utm_content') }} as utm_content,
    
    -- Extract referrer info
    referrer_url,
    {{ dbt_utils.get_url_host('referrer_url') }} as referrer_domain,
    {{ dbt_utils.get_url_path('referrer_url') }} as referrer_path,
    
    -- Session metrics
    session_start,
    session_end,
    {{ dbt_utils.datediff('session_start', 'session_end', 'minute') }} as session_duration_minutes
    
from {{ ref('stg_sessions') }}
```

---

## 📚 Quick Reference

### Most Used Functions (Top 10)

| Function | Use Case | Frequency |
|----------|----------|-----------|
| `generate_surrogate_key()` | Create composite keys | ⭐⭐⭐⭐⭐ |
| `star()` | Select columns with exclusions | ⭐⭐⭐⭐⭐ |
| `date_trunc()` | Cross-DB date truncation | ⭐⭐⭐⭐⭐ |
| `union_relations()` | Combine multiple tables | ⭐⭐⭐⭐⭐ |
| `get_column_values()` | Dynamic SQL generation | ⭐⭐⭐⭐⭐ |
| `group_by()` | Clean GROUP BY clauses | ⭐⭐⭐⭐⭐ |
| `pivot()` | Transform rows to columns | ⭐⭐⭐⭐ |
| `date_spine()` | Generate date series | ⭐⭐⭐⭐⭐ |
| `datediff()` | Cross-DB date difference | ⭐⭐⭐⭐⭐ |
| `deduplicate()` | Remove duplicates | ⭐⭐⭐⭐ |

### Most Used Tests (Top 10)

| Test | Use Case | Frequency |
|------|----------|-----------|
| `unique_combination_of_columns` | Composite key validation | ⭐⭐⭐⭐⭐ |
| `expression_is_true` | Business logic validation | ⭐⭐⭐⭐⭐ |
| `recency` | Data freshness checks | ⭐⭐⭐⭐⭐ |
| `relationships_where` | Conditional FK checks | ⭐⭐⭐⭐ |
| `not_null_proportion` | Data quality metrics | ⭐⭐⭐⭐ |
| `equal_rowcount` | ETL validation | ⭐⭐⭐⭐ |
| `not_constant` | Value variety check | ⭐⭐⭐⭐ |
| `at_least_one` | Minimum data check | ⭐⭐⭐ |
| `cardinality_equality` | Relationship validation | ⭐⭐⭐ |
| `fewer_rows_than` | Subset validation | ⭐⭐⭐ |

---

<div align="center">

### 🎯 Key Takeaways

![Takeaway 1](https://img.shields.io/badge/💡_Cross_Database-Works_Everywhere-4CAF50?style=for-the-badge)
![Takeaway 2](https://img.shields.io/badge/💡_Battle_Tested-Production_Ready-2196F3?style=for-the-badge)
![Takeaway 3](https://img.shields.io/badge/💡_Essential_Toolkit-Must_Have_Package-9C27B0?style=for-the-badge)

**Remember**: dbt_utils is the Swiss Army knife of dbt development!

</div>

---

## 📖 Additional Resources

- **dbt_utils Documentation**: https://github.com/dbt-labs/dbt-utils
- **dbt Package Hub**: https://hub.getdbt.com/
- **dbt Slack Community**: https://getdbt.slack.com
- **dbt Discourse**: https://discourse.getdbt.com/

---

*Note: This guide covers dbt_utils 1.x. Always check the official documentation for the latest features and updates.*
