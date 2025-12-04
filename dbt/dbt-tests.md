# 🧪 dbt Tests Guide

<div align="center">

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Testing](https://img.shields.io/badge/Testing-00C853?style=for-the-badge)
![Quality](https://img.shields.io/badge/Data_Quality-2196F3?style=for-the-badge)

</div>

A comprehensive guide to dbt tests - ensuring data quality and integrity in your analytics engineering workflow.

---

## 📑 Table of Contents

1. [🔍 What are dbt Tests?](#-what-are-dbt-tests)
2. [📊 Core Test Types](#-core-test-types)
3. [🎯 Schema Tests](#-schema-tests)
4. [🔧 Data Tests](#-data-tests)
5. [📦 dbt-utils Test Package](#-dbt-utils-test-package)
6. [🛠️ Custom Generic Tests](#️-custom-generic-tests)
7. [💡 Best Practices](#-best-practices)
8. [📈 Advanced Testing Patterns](#-advanced-testing-patterns)

---

## 🔍 What are dbt Tests?

**dbt Tests** are assertions about your data that dbt can execute to validate data quality, integrity, and business logic.

### Key Concepts

- **Schema Tests**: Tests defined in YAML files on models, columns, sources, and seeds
- **Data Tests**: Custom SQL queries that return failing rows
- **Generic Tests**: Reusable tests that accept parameters
- **Singular Tests**: One-off assertions for specific use cases

### Why Test?

✅ **Catch Data Issues Early** - Before they reach stakeholders  
✅ **Document Assumptions** - Tests serve as documentation  
✅ **Build Confidence** - Stakeholders trust your data  
✅ **Prevent Regressions** - Catch breaking changes automatically  
✅ **Enable CI/CD** - Automated data quality checks

---

## 📊 Core Test Types

### 1. 🎯 Schema Tests (Generic Tests)

Tests defined in `.yml` files that validate column-level and table-level properties.

### 2. 🔧 Data Tests (Singular Tests)

Custom SQL queries saved as `.sql` files in the `tests/` directory.

### Comparison Matrix

| Aspect | Schema Tests | Data Tests |
|--------|-------------|------------|
| **Location** | YAML files (`schema.yml`, `models.yml`) | `.sql` files in `tests/` folder |
| **Scope** | Column or model level | Any custom SQL logic |
| **Reusability** | Highly reusable | One-off assertions |
| **Parameterization** | Yes | No (but can use Jinja) |
| **Maintenance** | Easy - declarative | Moderate - SQL logic |

---

## 🎯 Schema Tests

### Built-in Generic Tests

dbt comes with four built-in generic tests:

#### 1. **unique** - No Duplicate Values

```yaml
models:
  - name: customers
    columns:
      - name: customer_id
        tests:
          - unique
```

**What it checks**: Every value in the column is unique (no duplicates)

---

#### 2. **not_null** - No Missing Values

```yaml
models:
  - name: customers
    columns:
      - name: customer_id
        tests:
          - not_null
      - name: email
        tests:
          - not_null
```

**What it checks**: No NULL values in the column

---

#### 3. **accepted_values** - Values in Allowed List

```yaml
models:
  - name: orders
    columns:
      - name: status
        tests:
          - accepted_values:
              values: ['pending', 'processing', 'shipped', 'delivered', 'cancelled']
      
      - name: payment_method
        tests:
          - accepted_values:
              values: ['credit_card', 'debit_card', 'paypal', 'bank_transfer']
              quote: false  # Don't quote values in SQL
```

**What it checks**: Column values are in the specified list

---

#### 4. **relationships** - Foreign Key Integrity

```yaml
models:
  - name: orders
    columns:
      - name: customer_id
        tests:
          - relationships:
              to: ref('customers')
              field: customer_id
      
      - name: product_id
        tests:
          - relationships:
              to: ref('products')
              field: product_id
```

**What it checks**: Values exist in the referenced table (foreign key constraint)

---

### Multiple Tests on One Column

```yaml
models:
  - name: customers
    columns:
      - name: customer_id
        description: "Primary key for customers table"
        tests:
          - unique
          - not_null
      
      - name: email
        description: "Customer email address"
        tests:
          - unique
          - not_null
          - accepted_values:
              values: ['@gmail.com', '@yahoo.com', '@outlook.com']
              quote: false
      
      - name: customer_status
        tests:
          - not_null
          - accepted_values:
              values: ['active', 'inactive', 'churned', 'prospect']
```

---

### Test Configurations

```yaml
models:
  - name: orders
    columns:
      - name: order_id
        tests:
          - unique:
              config:
                severity: error  # or 'warn'
                error_if: ">100"  # Fail if more than 100 violations
                warn_if: ">10"   # Warn if more than 10 violations
          
          - not_null:
              config:
                severity: warn
                where: "order_date >= '2024-01-01'"  # Only test recent data
                limit: 10  # Show only first 10 failures
```

#### Severity Levels

| Severity | Behavior | Use Case |
|----------|----------|----------|
| **error** | Fails the test, exits with error code | Critical data quality issues |
| **warn** | Test fails but dbt continues | Non-critical issues, monitoring |

---

### Model-Level Tests

```yaml
models:
  - name: orders
    description: "One record per order"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - order_id
            - order_line_number
```

---

### Source Tests

```yaml
sources:
  - name: raw_database
    database: raw_db
    schema: ecommerce
    tables:
      - name: raw_customers
        columns:
          - name: id
            tests:
              - unique
              - not_null
          
          - name: email
            tests:
              - unique
              - not_null
        
        # Freshness test
        freshness:
          warn_after: {count: 12, period: hour}
          error_after: {count: 24, period: hour}
        
        # Row count test
        loaded_at_field: updated_at
```

---

## 🔧 Data Tests (Singular Tests)

Custom SQL queries in the `tests/` folder that return failing rows.

### File Structure

```
my_dbt_project/
├── tests/
│   ├── assert_positive_order_totals.sql
│   ├── assert_no_orphaned_orders.sql
│   ├── assert_email_format.sql
│   └── assert_valid_dates.sql
```

### Example 1: Positive Order Totals

```sql
-- tests/assert_positive_order_totals.sql

-- This test will fail if any order_total is <= 0
select
    order_id,
    order_total
from {{ ref('fct_orders') }}
where order_total <= 0
```

**Logic**: Return rows that violate the rule. If the query returns 0 rows, test passes.

---

### Example 2: No Orphaned Orders

```sql
-- tests/assert_no_orphaned_orders.sql

-- Fail if any orders don't have a matching customer
select
    o.order_id,
    o.customer_id
from {{ ref('fct_orders') }} o
left join {{ ref('dim_customers') }} c
    on o.customer_id = c.customer_id
where c.customer_id is null
```

---

### Example 3: Email Format Validation

```sql
-- tests/assert_email_format.sql

-- Fail if any email doesn't match basic email pattern
select
    customer_id,
    email
from {{ ref('dim_customers') }}
where email not like '%_@__%.__%'
   or email is null
```

---

### Example 4: Valid Date Ranges

```sql
-- tests/assert_valid_dates.sql

-- Fail if order_date is in the future or before company founding
select
    order_id,
    order_date
from {{ ref('fct_orders') }}
where order_date > current_date
   or order_date < '2010-01-01'  -- Company founding date
```

---

### Example 5: Cross-Model Validation

```sql
-- tests/assert_revenue_reconciliation.sql

-- Revenue in orders should match revenue in payments
with order_revenue as (
    select sum(order_total) as total
    from {{ ref('fct_orders') }}
    where order_status = 'completed'
),

payment_revenue as (
    select sum(payment_amount) as total
    from {{ ref('fct_payments') }}
    where payment_status = 'completed'
)

select
    o.total as order_total,
    p.total as payment_total,
    abs(o.total - p.total) as difference
from order_revenue o
cross join payment_revenue p
where abs(o.total - p.total) > 0.01  -- Allow 1 cent rounding
```

---

### Data Test with Configuration

```sql
-- tests/assert_reasonable_discounts.sql

{{ config(
    severity = 'warn',
    tags = ['finance', 'daily']
) }}

-- Warn if discounts exceed 50% of order total
select
    order_id,
    order_total,
    discount_amount,
    (discount_amount / nullif(order_total, 0)) as discount_percentage
from {{ ref('fct_orders') }}
where discount_amount > (order_total * 0.5)
```

---

## 📦 dbt-utils Test Package

Extended test library from dbt-labs. Install via `packages.yml`:

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
```

Then run: `dbt deps`

### Popular dbt-utils Tests

#### 1. **unique_combination_of_columns**

```yaml
models:
  - name: order_items
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - order_id
            - product_id
```

---

#### 2. **expression_is_true**

```yaml
models:
  - name: orders
    tests:
      - dbt_utils.expression_is_true:
          expression: "order_total >= 0"
      
      - dbt_utils.expression_is_true:
          expression: "order_date <= current_date"
```

---

#### 3. **recency**

```yaml
models:
  - name: events
    tests:
      - dbt_utils.recency:
          datepart: day
          field: created_at
          interval: 1  # Fail if no records in last 1 day
```

---

#### 4. **at_least_one**

```yaml
models:
  - name: customers
    tests:
      - dbt_utils.at_least_one:
          column_name: customer_id
```

---

#### 5. **not_constant**

```yaml
models:
  - name: products
    columns:
      - name: price
        tests:
          - dbt_utils.not_constant  # Ensures column has more than 1 distinct value
```

---

#### 6. **cardinality_equality**

```yaml
models:
  - name: orders
    tests:
      - dbt_utils.cardinality_equality:
          field: customer_id
          to: ref('customers')
          to_field: customer_id
```

**What it checks**: The number of distinct values in both columns is the same

---

#### 7. **not_null_proportion**

```yaml
models:
  - name: customers
    columns:
      - name: phone_number
        tests:
          - dbt_utils.not_null_proportion:
              at_least: 0.95  # At least 95% non-null
```

---

#### 8. **equal_rowcount**

```yaml
models:
  - name: orders_staging
    tests:
      - dbt_utils.equal_rowcount:
          compare_model: source('raw', 'orders')
```

---

#### 9. **fewer_rows_than**

```yaml
models:
  - name: orders_filtered
    tests:
      - dbt_utils.fewer_rows_than:
          compare_model: ref('orders_all')
```

---

#### 10. **sequential_values**

```yaml
models:
  - name: date_spine
    columns:
      - name: date_day
        tests:
          - dbt_utils.sequential_values:
              interval: 1
              datepart: day
```

---

### Complete dbt-utils Example

```yaml
models:
  - name: fct_orders
    description: "Fact table for all orders"
    
    # Model-level tests
    tests:
      - dbt_utils.equal_rowcount:
          compare_model: source('raw', 'orders')
      
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - order_id
            - order_line_id
      
      - dbt_utils.recency:
          datepart: day
          field: order_date
          interval: 1
    
    columns:
      - name: order_id
        tests:
          - unique
          - not_null
      
      - name: order_total
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      
      - name: order_status
        tests:
          - not_null
          - accepted_values:
              values: ['pending', 'processing', 'shipped', 'delivered']
      
      - name: customer_id
        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id
```

---

## 🛠️ Custom Generic Tests

Create your own reusable tests!

### File Structure

```
my_dbt_project/
├── tests/
│   └── generic/
│       ├── test_is_email.sql
│       ├── test_is_positive.sql
│       └── test_is_within_range.sql
```

### Example 1: Email Validation Test

```sql
-- tests/generic/test_is_email.sql

{% test is_email(model, column_name) %}

select
    {{ column_name }} as invalid_email
from {{ model }}
where {{ column_name }} not like '%_@__%.__%'
   or {{ column_name }} is null

{% endtest %}
```

**Usage:**
```yaml
models:
  - name: customers
    columns:
      - name: email
        tests:
          - is_email
```

---

### Example 2: Positive Number Test

```sql
-- tests/generic/test_is_positive.sql

{% test is_positive(model, column_name) %}

select
    {{ column_name }} as non_positive_value
from {{ model }}
where {{ column_name }} <= 0
   or {{ column_name }} is null

{% endtest %}
```

**Usage:**
```yaml
models:
  - name: orders
    columns:
      - name: order_total
        tests:
          - is_positive
      
      - name: quantity
        tests:
          - is_positive
```

---

### Example 3: Range Validation Test

```sql
-- tests/generic/test_is_within_range.sql

{% test is_within_range(model, column_name, min_value, max_value) %}

select
    {{ column_name }} as out_of_range_value
from {{ model }}
where {{ column_name }} < {{ min_value }}
   or {{ column_name }} > {{ max_value }}
   or {{ column_name }} is null

{% endtest %}
```

**Usage:**
```yaml
models:
  - name: products
    columns:
      - name: price
        tests:
          - is_within_range:
              min_value: 0
              max_value: 10000
      
      - name: discount_percentage
        tests:
          - is_within_range:
              min_value: 0
              max_value: 100
```

---

### Example 4: Recent Timestamp Test

```sql
-- tests/generic/test_is_recent.sql

{% test is_recent(model, column_name, interval=1, datepart='day') %}

select
    {{ column_name }} as stale_timestamp
from {{ model }}
where {{ column_name }} < dateadd({{ datepart }}, -{{ interval }}, current_timestamp)
   or {{ column_name }} is null

{% endtest %}
```

**Usage:**
```yaml
models:
  - name: events
    columns:
      - name: event_timestamp
        tests:
          - is_recent:
              interval: 2
              datepart: hour
```

---

### Example 5: Regex Pattern Test

```sql
-- tests/generic/test_matches_regex.sql

{% test matches_regex(model, column_name, regex_pattern) %}

select
    {{ column_name }} as invalid_value
from {{ model }}
where not regexp_like({{ column_name }}, '{{ regex_pattern }}')
   or {{ column_name }} is null

{% endtest %}
```

**Usage:**
```yaml
models:
  - name: customers
    columns:
      - name: phone_number
        tests:
          - matches_regex:
              regex_pattern: '^\+?[1-9]\d{1,14}$'  # E.164 format
      
      - name: zip_code
        tests:
          - matches_regex:
              regex_pattern: '^\d{5}(-\d{4})?$'  # US ZIP format
```

---

## 💡 Best Practices

### 1. 🎯 Test Coverage Strategy

```yaml
# Minimal tests for ALL models
models:
  - name: every_model
    columns:
      - name: primary_key
        tests:
          - unique
          - not_null

# Comprehensive tests for CRITICAL models
models:
  - name: fct_revenue
    tests:
      - dbt_utils.recency:
          datepart: hour
          field: updated_at
          interval: 2
    
    columns:
      - name: revenue_amount
        tests:
          - not_null
          - is_positive
      
      - name: customer_id
        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id
```

---

### 2. ⚡ Test Performance Tips

**DO:**
- ✅ Use `where` clauses to test only recent data
- ✅ Use `limit` to see sample failures
- ✅ Set appropriate severity levels
- ✅ Use incremental tests for large tables
- ✅ Run critical tests first with tags

```yaml
models:
  - name: large_table
    columns:
      - name: id
        tests:
          - unique:
              config:
                where: "created_at >= current_date - interval '7 days'"
                limit: 100
                severity: warn
```

**DON'T:**
- ❌ Test entire historical tables daily
- ❌ Use overly complex test logic
- ❌ Run all tests on every commit
- ❌ Ignore test performance issues

---

### 3. 🏷️ Test Tagging Strategy

```yaml
models:
  - name: fct_orders
    tests:
      - unique:
          config:
            tags: ['critical', 'daily']
      
      - dbt_utils.recency:
          config:
            tags: ['freshness', 'hourly']
```

**Run specific test tags:**
```bash
# Run only critical tests
dbt test --select tag:critical

# Run hourly tests
dbt test --select tag:hourly

# Run tests for specific model
dbt test --select fct_orders
```

---

### 4. 📊 Test Documentation

```yaml
models:
  - name: fct_orders
    description: |
      ## Fact Table: Orders
      
      **Grain**: One row per order
      **Updated**: Hourly
      
      ### Quality Checks
      - Primary key uniqueness
      - No orphaned customer references
      - Order totals must be positive
      - Order dates must be within business range
    
    columns:
      - name: order_id
        description: "Primary key - unique identifier for each order"
        tests:
          - unique:
              config:
                severity: error
          - not_null:
              config:
                severity: error
        meta:
          test_rationale: "Ensures data integrity for joins and deduplication"
```

---

### 5. 🔄 CI/CD Testing Strategy

```yaml
# .github/workflows/dbt_test.yml
name: dbt Test

on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Run Critical Tests
        run: dbt test --select tag:critical
      
      - name: Run All Tests
        run: dbt test
        if: success()
```

---

## 📈 Advanced Testing Patterns

### 1. Incremental Test Pattern

```yaml
models:
  - name: fct_events
    tests:
      - dbt_utils.recency:
          datepart: hour
          field: event_timestamp
          interval: 1
          config:
            enabled: "{{ target.name == 'prod' }}"  # Only in prod
```

---

### 2. Environment-Specific Tests

```yaml
models:
  - name: fct_orders
    columns:
      - name: order_id
        tests:
          - unique:
              config:
                # More strict in prod
                error_if: "{{ '>0' if target.name == 'prod' else '>100' }}"
                severity: "{{ 'error' if target.name == 'prod' else 'warn' }}"
```

---

### 3. Multi-Column Validation

```sql
-- tests/assert_discount_logic.sql

-- Discount amount should never exceed order subtotal
select
    order_id,
    order_subtotal,
    discount_amount
from {{ ref('fct_orders') }}
where discount_amount > order_subtotal
```

---

### 4. Time-Based Testing

```sql
-- tests/assert_no_future_orders.sql

-- No orders should have future dates
select
    order_id,
    order_date,
    current_date as today
from {{ ref('fct_orders') }}
where order_date > current_date
```

---

### 5. Cross-Model Consistency

```sql
-- tests/assert_order_payment_consistency.sql

-- Every completed order should have a payment
with orders as (
    select order_id
    from {{ ref('fct_orders') }}
    where order_status = 'completed'
),

payments as (
    select order_id
    from {{ ref('fct_payments') }}
    where payment_status = 'completed'
)

select
    o.order_id
from orders o
left join payments p
    on o.order_id = p.order_id
where p.order_id is null
```

---

## 🎓 Real-World Testing Example

### Complete Model with Comprehensive Tests

```yaml
version: 2

models:
  - name: fct_customer_orders
    description: |
      Customer order facts aggregated by customer.
      Updated daily with full refresh.
    
    config:
      tags: ['mart', 'customer']
    
    # Model-level tests
    tests:
      - dbt_utils.equal_rowcount:
          compare_model: ref('dim_customers')
          config:
            severity: error
      
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - customer_id
            - order_month
    
    columns:
      - name: customer_id
        description: "Foreign key to dim_customers"
        tests:
          - not_null:
              config:
                severity: error
          - unique:
              config:
                severity: error
          - relationships:
              to: ref('dim_customers')
              field: customer_id
              config:
                severity: error
      
      - name: order_month
        description: "Month of the order aggregation"
        tests:
          - not_null
      
      - name: order_count
        description: "Total number of orders"
        tests:
          - not_null
          - is_positive
      
      - name: total_revenue
        description: "Sum of all order totals"
        tests:
          - not_null
          - is_positive
      
      - name: average_order_value
        description: "Average order value for the month"
        tests:
          - not_null
          - is_positive
          - dbt_utils.expression_is_true:
              expression: "<= total_revenue"  # Can't exceed total
      
      - name: first_order_date
        description: "Date of first order in month"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "<= current_date"
      
      - name: last_order_date
        description: "Date of last order in month"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= first_order_date"
```

---

## 📚 Quick Reference Card

| Test Type | Purpose | Example |
|-----------|---------|---------|
| **unique** | No duplicates | `- unique` |
| **not_null** | No missing values | `- not_null` |
| **accepted_values** | Enum validation | `- accepted_values: {values: ['A', 'B']}` |
| **relationships** | Foreign key check | `- relationships: {to: ref('table'), field: id}` |
| **expression_is_true** | Custom validation | `- dbt_utils.expression_is_true: {expression: "> 0"}` |
| **recency** | Data freshness | `- dbt_utils.recency: {field: created_at, interval: 1}` |
| **Custom Generic** | Reusable logic | Create in `tests/generic/` |
| **Singular Test** | One-off check | SQL file in `tests/` |

---

## 🚀 Command Reference

```bash
# Run all tests
dbt test

# Test specific model
dbt test --select fct_orders

# Test specific model and downstream
dbt test --select fct_orders+

# Test by tag
dbt test --select tag:critical

# Test sources
dbt test --select source:*

# Test with specific threads
dbt test --threads 4

# Store test failures
dbt test --store-failures

# Show failing rows
dbt test --select fct_orders --store-failures
```

---

<div align="center">

### 🎯 Key Takeaways

![Takeaway 1](https://img.shields.io/badge/💡_Test_Everything-Primary_Keys_First-4CAF50?style=for-the-badge)
![Takeaway 2](https://img.shields.io/badge/💡_Use_Tags-Organize_Test_Runs-2196F3?style=for-the-badge)
![Takeaway 3](https://img.shields.io/badge/💡_Custom_Tests-Reusable_Logic-9C27B0?style=for-the-badge)

**Remember**: Tests are living documentation of your data quality expectations!

</div>

---

*Note: Test capabilities may vary by data warehouse. Always refer to [dbt testing documentation](https://docs.getdbt.com/docs/build/tests) for platform-specific features.*****
