# ⚡ dbt Optimization Guide

<div align="center">

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Performance](https://img.shields.io/badge/Performance-4CAF50?style=for-the-badge)
![Speed](https://img.shields.io/badge/Speed-FF6F00?style=for-the-badge)

</div>

A concise guide to optimizing dbt performance - faster builds, lower costs, better efficiency.

---

## 📑 Quick Navigation

1. [🎯 Model Optimization](#-model-optimization)
2. [📊 Materialization Strategy](#-materialization-strategy)
3. [⚙️ Query Performance](#️-query-performance)
4. [🔄 Incremental Models](#-incremental-models)
5. [🏗️ Project Structure](#️-project-structure)
6. [💾 Warehouse-Specific](#-warehouse-specific)
7. [📈 Monitoring & Metrics](#-monitoring--metrics)

---

## 🎯 Model Optimization

### Use Appropriate Materializations

```yaml
models:
  staging:
    +materialized: view          # Fast, no storage
  
  intermediate:
    +materialized: ephemeral     # No database object
  
  marts:
    +materialized: table         # Fast queries
    
  facts:
    large_fact_table:
      +materialized: incremental # Only new data
```

**Rule of Thumb:**
- **Views**: < 100K rows, simple logic
- **Tables**: 100K-10M rows, frequently queried
- **Incremental**: > 10M rows, append-only or updates

---

### Minimize CTEs and Subqueries

```sql
-- ❌ BAD: Nested CTEs
with step1 as (
    select * from {{ ref('orders') }}
),
step2 as (
    select * from step1 where status = 'complete'
),
step3 as (
    select * from step2 where amount > 100
)
select * from step3

-- ✅ GOOD: Single CTE with combined logic
with filtered_orders as (
    select *
    from {{ ref('orders') }}
    where status = 'complete'
      and amount > 100
)
select * from filtered_orders
```

---

### Filter Early, Aggregate Late

```sql
-- ❌ BAD: Aggregate then filter
with aggregated as (
    select
        customer_id,
        sum(amount) as total
    from {{ ref('orders') }}  -- All data
    group by 1
)
select * from aggregated
where total > 1000

-- ✅ GOOD: Filter then aggregate
with filtered as (
    select
        customer_id,
        amount
    from {{ ref('orders') }}
    where order_date >= '2024-01-01'  -- Filter first
)
select
    customer_id,
    sum(amount) as total
from filtered
group by 1
having sum(amount) > 1000
```

---

### Use ref() and source() Efficiently

```sql
-- ❌ BAD: Multiple refs to same model
select
    o.order_id,
    (select count(*) from {{ ref('orders') }}) as total_orders,
    (select sum(amount) from {{ ref('orders') }}) as total_amount
from {{ ref('orders') }} o

-- ✅ GOOD: Single ref with window functions
select
    order_id,
    count(*) over () as total_orders,
    sum(amount) over () as total_amount
from {{ ref('orders') }}
```

---

## 📊 Materialization Strategy

### Layer-Based Approach

```
┌─────────────────┐
│   Sources       │  ← Don't transform
└────────┬────────┘
         │
┌────────▼────────┐
│   Staging       │  ← Views (light cleaning)
└────────┬────────┘
         │
┌────────▼────────┐
│  Intermediate   │  ← Ephemeral/Views (business logic)
└────────┬────────┘
         │
┌────────▼────────┐
│     Marts       │  ← Tables/Incremental (business-facing)
└─────────────────┘
```

**Configuration:**
```yaml
models:
  staging:
    +materialized: view
    +schema: staging
  
  intermediate:
    +materialized: ephemeral  # No DB objects
  
  marts:
    +materialized: table
    +schema: analytics
    
    facts:
      +materialized: incremental
      +unique_key: id
```

---

## ⚙️ Query Performance

### 1. Use Indexes and Clustering

```sql
-- Snowflake
{{ config(
    materialized='table',
    cluster_by=['order_date', 'customer_id']
) }}

-- BigQuery
{{ config(
    materialized='table',
    partition_by={
        'field': 'order_date',
        'data_type': 'date'
    },
    cluster_by=['customer_id', 'region']
) }}

-- Redshift
{{ config(
    materialized='table',
    dist='customer_id',
    sort='order_date'
) }}
```

---

### 2. Limit Columns Selected

```sql
-- ❌ BAD: Select everything
select * from {{ ref('orders') }}

-- ✅ GOOD: Select only needed columns
select
    order_id,
    customer_id,
    order_date,
    order_total
from {{ ref('orders') }}

-- ✅ BETTER: Use dbt_utils.star() with exclusions
select
    {{ dbt_utils.star(from=ref('orders'), except=['internal_notes', 'debug_info']) }}
from {{ ref('orders') }}
```

---

### 3. Avoid Cartesian Joins

```sql
-- ❌ BAD: Missing join condition
select *
from {{ ref('orders') }} o
cross join {{ ref('customers') }} c

-- ✅ GOOD: Proper join
select *
from {{ ref('orders') }} o
inner join {{ ref('customers') }} c
    on o.customer_id = c.customer_id
```

---

### 4. Use EXISTS Instead of IN for Large Sets

```sql
-- ❌ SLOW: IN with subquery
select *
from {{ ref('orders') }}
where customer_id in (
    select customer_id 
    from {{ ref('premium_customers') }}
)

-- ✅ FAST: EXISTS
select *
from {{ ref('orders') }} o
where exists (
    select 1
    from {{ ref('premium_customers') }} pc
    where pc.customer_id = o.customer_id
)
```

---

## 🔄 Incremental Models

### Basic Incremental Pattern

```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    on_schema_change='append_new_columns'
) }}

select
    order_id,
    customer_id,
    order_date,
    order_total,
    updated_at
from {{ ref('stg_orders') }}

{% if is_incremental() %}
    -- Only process new/updated records
    where updated_at > (select max(updated_at) from {{ this }})
{% endif %}
```

---

### Optimized Incremental with Lookback

```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge'
) }}

select * from {{ ref('stg_orders') }}

{% if is_incremental() %}
    where updated_at > (
        select dateadd(day, -3, max(updated_at))  -- 3-day lookback
        from {{ this }}
    )
{% endif %}
```

**Why Lookback?**
- Handles late-arriving data
- Captures backdated updates
- Ensures data completeness

---

### Partition-Based Incremental

```sql
{{ config(
    materialized='incremental',
    unique_key='event_id',
    incremental_strategy='insert_overwrite',
    partition_by={
        'field': 'event_date',
        'data_type': 'date'
    }
) }}

select * from {{ ref('stg_events') }}

{% if is_incremental() %}
    -- Only last 3 days
    where event_date >= dateadd(day, -3, current_date)
{% endif %}
```

---

## 🏗️ Project Structure

### Efficient Model Organization

```
models/
├── staging/           # Views only
│   ├── _staging.yml
│   └── stg_orders.sql
│
├── intermediate/      # Ephemeral (no DB objects)
│   └── int_order_items_joined.sql
│
└── marts/
    ├── core/          # Tables (frequently queried)
    │   └── dim_customers.sql
    │
    └── finance/       # Incremental (large facts)
        └── fct_revenue.sql
```

---

### Use Model Selection Efficiently

```bash
# Run only changed models and downstream
dbt run --select state:modified+

# Run specific mart
dbt run --select marts.finance

# Run by tag
dbt run --select tag:daily

# Exclude long-running models
dbt run --exclude tag:weekly
```

**Tag Strategy:**
```yaml
models:
  marts:
    finance:
      fct_revenue:
        +tags: ['daily', 'critical', 'finance']
      
      fct_historical_revenue:
        +tags: ['weekly', 'finance']
```

---

### Leverage dbt Artifacts

```yaml
# profiles.yml - Enable state comparison
target:
  prod:
    type: snowflake
    # ... connection details
    
# Use in CI/CD
dbt run --select state:modified+ --state ./prod-artifacts
```

---

## 💾 Warehouse-Specific

### Snowflake Optimization

```sql
{{ config(
    materialized='incremental',
    unique_key='id',
    
    -- Clustering
    cluster_by=['date_column', 'high_cardinality_column'],
    automatic_clustering=true,
    
    -- Warehouse sizing
    snowflake_warehouse='transforming_xl',
    
    -- Query acceleration
    query_tag='daily_transform'
) }}
```

**Tips:**
- Use larger warehouses for heavy transforms
- Cluster on frequently filtered columns
- Enable automatic clustering for large tables

---

### BigQuery Optimization

```sql
{{ config(
    materialized='incremental',
    unique_key='id',
    
    -- Partitioning (required for large tables)
    partition_by={
        'field': 'created_date',
        'data_type': 'date',
        'granularity': 'day'
    },
    
    -- Clustering (up to 4 columns)
    cluster_by=['customer_id', 'region', 'product_id'],
    
    -- Partitioning expiration
    partition_expiration_days=730,  -- 2 years
    
    -- Require partition filter
    require_partition_filter=true
) }}
```

**Tips:**
- Always partition tables > 1GB
- Cluster on frequently filtered/joined columns
- Use partition pruning in queries

---

### Redshift Optimization

```sql
{{ config(
    materialized='table',
    
    -- Distribution
    dist='customer_id',  -- or 'all' for small tables, 'even' for large
    
    -- Sort keys
    sort='order_date',   -- or ['col1', 'col2'] for compound
    
    -- Compression
    bind=false  -- Allow automatic compression
) }}
```

**Tips:**
- Use `dist='all'` for small dimension tables (< 1M rows)
- Use `dist='even'` for large fact tables with no obvious key
- Sort keys improve range-restricted queries

---

## 📈 Monitoring & Metrics

### Track Model Performance

```sql
-- models/meta/model_timing.sql
select
    model_name,
    execution_time,
    rows_affected,
    execution_time / nullif(rows_affected, 0) as seconds_per_row
from {{ ref('dbt_run_results') }}
where execution_time > 60  -- Models taking > 1 minute
order by execution_time desc
```

---

### Use dbt Artifacts

```bash
# Generate and analyze artifacts
dbt compile
dbt docs generate

# Analyze run_results.json
jq '.results[] | select(.execution_time > 60) | {name: .unique_id, time: .execution_time}' \
    target/run_results.json
```

---

### Key Metrics to Monitor

| Metric | Target | Action |
|--------|--------|--------|
| **Model build time** | < 5 min per model | Optimize query, use incremental |
| **Total pipeline time** | < 1 hour (hourly jobs) | Parallelize, optimize DAG |
| **Data warehouse costs** | Decrease MoM | Use smaller warehouses, optimize queries |
| **Test failure rate** | < 1% | Improve data quality at source |
| **Full refresh time** | < 4 hours | Use incremental, optimize queries |

---

## 🎯 Quick Wins Checklist

### Immediate Optimizations

- [ ] Convert large tables to incremental
- [ ] Change intermediate models to ephemeral
- [ ] Add clustering/partitioning to big tables
- [ ] Remove SELECT * from models
- [ ] Add filters to incremental models
- [ ] Use `state:modified+` in CI/CD
- [ ] Enable parallel execution (set threads > 1)
- [ ] Add indexes to frequently filtered columns

### dbt_project.yml Settings

```yaml
# Optimize dbt behavior
models:
  +persist_docs:
    relation: true
    columns: true

# Increase parallelism
threads: 8  # Adjust based on warehouse

# Use variables for dynamic behavior
vars:
  # Limit data in dev
  limit_in_dev: true
  dev_limit: 1000
```

---

## 🚀 Performance Comparison

### Before vs After Optimization

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Total build time** | 45 min | 12 min | 73% faster |
| **Largest model** | 15 min | 2 min | 87% faster |
| **Warehouse costs** | $1,200/mo | $400/mo | 67% reduction |
| **Data freshness** | 1 hour | 15 min | 4x faster |

**Key Changes:**
1. Converted 5 large tables to incremental → 60% time savings
2. Changed 20 intermediate models to ephemeral → No DB objects
3. Added clustering to 10 fact tables → 40% query speed
4. Implemented proper incremental filters → 80% less data processed

---

## 📚 Quick Reference

### Optimization Priority Matrix

```
High Impact, Low Effort (Do First):
├── Use incremental for large tables
├── Add clustering/partitioning
├── Filter early in queries
└── Use appropriate materializations

High Impact, High Effort (Plan & Execute):
├── Refactor complex models
├── Implement proper incremental strategy
├── Optimize warehouse usage
└── Restructure project layout

Low Impact (Nice to Have):
├── Rename models for clarity
├── Add documentation
└── Standardize naming
```

---

### Common Anti-Patterns

| Anti-Pattern | Impact | Solution |
|--------------|--------|----------|
| `SELECT *` everywhere | ⚠️⚠️⚠️ High | Select only needed columns |
| All models as tables | ⚠️⚠️⚠️ High | Use views/ephemeral where appropriate |
| No incremental models | ⚠️⚠️⚠️ High | Use for tables > 10M rows |
| Missing clustering | ⚠️⚠️ Medium | Cluster on filtered columns |
| Nested subqueries | ⚠️⚠️ Medium | Use CTEs, simplify logic |
| No partition filters | ⚠️⚠️ Medium | Always filter partitioned tables |

---

<div align="center">

### 🎯 Key Takeaways

![Takeaway 1](https://img.shields.io/badge/💡_Right_Materialization-70%25_of_Optimization-4CAF50?style=for-the-badge)
![Takeaway 2](https://img.shields.io/badge/💡_Incremental_Models-Biggest_Time_Saver-2196F3?style=for-the-badge)
![Takeaway 3](https://img.shields.io/badge/💡_Filter_Early-Simple_but_Powerful-9C27B0?style=for-the-badge)

**Remember**: Measure first, optimize second. Focus on the 20% of models that take 80% of the time!

</div>

---

*Pro Tip: Use `dbt run --select state:modified+` in production to only run changed models and their downstream dependencies.*
