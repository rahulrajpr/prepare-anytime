# 🎯 dbt Materializations Guide

<div align="center">

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Materializations](https://img.shields.io/badge/Materializations-9C27B0?style=for-the-badge)
![Performance](https://img.shields.io/badge/Performance-4CAF50?style=for-the-badge)

</div>

A comprehensive guide to dbt materializations - how your models are built and persisted in the data warehouse.

---

## 📑 Table of Contents

1. [🔍 What are Materializations?](#-what-are-materializations)
2. [📊 Core Materializations](#-core-materializations)
3. [⚙️ Configuration Methods](#️-configuration-methods)
4. [🎯 Choosing the Right Materialization](#-choosing-the-right-materialization)
5. [🔧 Advanced Configurations](#-advanced-configurations)
6. [💡 Best Practices](#-best-practices)
7. [📈 Performance Comparison](#-performance-comparison)

---

## 🔍 What are Materializations?

**Materializations** determine how dbt builds and persists your models in the data warehouse. They define the DDL (Data Definition Language) statements that dbt uses to create database objects.

### Key Concept

- **Ephemeral**: Not materialized in the database (CTE only)
- **View**: SELECT statement stored as a database view
- **Table**: Physical table built from SELECT statement
- **Incremental**: Table that is built incrementally over time

---

## 📊 Core Materializations

### 1. 🪟 View Materialization

**Definition**: Creates a database view - a saved query that executes every time it's queried.

| Aspect | Details |
|--------|---------|
| **Syntax** | **```{{ config(materialized='view') }}```** |
| **Database Object** | View (virtual table) |
| **Build Time** | Fast - just creates view definition |
| **Query Time** | Slower - executes underlying query each time |
| **Storage** | No additional storage (only SQL definition) |
| **Data Freshness** | Always up-to-date with source data |
| **Best For** | Lightweight transformations, frequently changing data, models used occasionally |

#### Configuration Examples

```sql
-- In model file
{{ config(
    materialized='view'
) }}

select
    customer_id,
    first_name,
    last_name,
    email
from {{ ref('stg_customers') }}
```

```yaml
# In dbt_project.yml
models:
  my_project:
    staging:
      +materialized: view
```

#### ✅ When to Use Views

- **Staging models** that perform light transformations
- **Models queried infrequently** but need fresh data
- **Simple transformations** on small datasets
- **Development/testing** environments
- When **storage is a concern**

#### ❌ When to Avoid Views

- Complex queries with multiple joins
- Models queried frequently by BI tools
- Large datasets requiring heavy computation
- When query performance is critical

---

### 2. 🗄️ Table Materialization

**Definition**: Creates a physical table in the database by running a CREATE TABLE AS SELECT statement.

| Aspect | Details |
|--------|---------|
| **Syntax** | **```{{ config(materialized='table') }}```** |
| **Database Object** | Physical table |
| **Build Time** | Slower - creates and populates entire table |
| **Query Time** | Fast - data is pre-computed |
| **Storage** | Uses storage for the full table |
| **Data Freshness** | Updated only when dbt runs |
| **Best For** | Complex transformations, frequently queried models, large datasets |

#### Configuration Examples

```sql
-- Basic table
{{ config(
    materialized='table'
) }}

select
    order_id,
    customer_id,
    order_date,
    order_total,
    order_status
from {{ ref('stg_orders') }}
```

```sql
-- Table with additional configs
{{ config(
    materialized='table',
    sort='order_date',
    dist='customer_id',
    cluster_by=['order_date', 'customer_id']
) }}

select
    order_id,
    customer_id,
    order_date,
    sum(line_item_total) as order_total
from {{ ref('stg_order_items') }}
group by 1, 2, 3
```

#### ✅ When to Use Tables

- **Frequently queried** models by BI tools
- **Complex transformations** with multiple joins/aggregations
- **Mart/fact tables** in your data warehouse
- Models that are **downstream dependencies** for many other models
- When **query performance** is critical

#### ❌ When to Avoid Tables

- Very large datasets that change frequently (consider incremental)
- Simple pass-through transformations (use views)
- When build time is a constraint
- Development environments with limited resources

---

### 3. ➕ Incremental Materialization

**Definition**: Builds tables incrementally, adding or updating only new/changed records since the last run.

| Aspect | Details |
|--------|---------|
| **Syntax** | **```{{ config(materialized='incremental') }}```** |
| **Database Object** | Physical table |
| **Build Time** | Fast after initial build - only processes new data |
| **Query Time** | Fast - data is pre-computed |
| **Storage** | Uses storage for the full table |
| **Data Freshness** | Updated incrementally with each run |
| **Best For** | Large fact tables, event logs, time-series data |

#### Configuration Examples

```sql
-- Basic incremental model
{{ config(
    materialized='incremental',
    unique_key='event_id'
) }}

select
    event_id,
    user_id,
    event_timestamp,
    event_type
from {{ ref('stg_events') }}

{% if is_incremental() %}
    -- This filter will only be applied on incremental runs
    where event_timestamp > (select max(event_timestamp) from {{ this }})
{% endif %}
```

```sql
-- Incremental with merge strategy
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge',
    merge_update_columns=['order_status', 'updated_at']
) }}

select
    order_id,
    customer_id,
    order_date,
    order_status,
    order_total,
    updated_at
from {{ ref('stg_orders') }}

{% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
{% endif %}
```

#### Incremental Strategies

| Strategy | Description | Use Case |
|----------|-------------|----------|
| **```append```** | Add new rows only (default) | Immutable event data, logs |
| **```merge```** | Update existing rows and add new ones | Slowly changing dimensions, updatable records |
| **```delete+insert```** | Delete matching rows then insert | Partition-based updates |
| **```insert_overwrite```** | Overwrite partitions (Bigquery/Spark) | Partitioned tables |

#### ✅ When to Use Incremental

- **Large fact tables** (millions+ rows)
- **Event logs** that only append
- **Time-series data** with date filters
- Models with **long build times**
- When **full refresh is expensive**

#### ❌ When to Avoid Incremental

- Small tables that rebuild quickly
- Tables requiring frequent full refreshes
- Complex logic that's hard to incrementalize
- When data can arrive out of order (without proper handling)

---

### 4. 💨 Ephemeral Materialization

**Definition**: Not materialized in the database - exists only as a CTE in dependent models.

| Aspect | Details |
|--------|---------|
| **Syntax** | **```{{ config(materialized='ephemeral') }}```** |
| **Database Object** | None (CTE in downstream models) |
| **Build Time** | N/A - compiled into dependent models |
| **Query Time** | Depends on downstream model |
| **Storage** | No storage used |
| **Data Freshness** | Always fresh (executed with downstream model) |
| **Best For** | Shared logic, intermediate transformations |

#### Configuration Examples

```sql
-- Ephemeral model
{{ config(
    materialized='ephemeral'
) }}

select
    customer_id,
    first_name || ' ' || last_name as full_name,
    email
from {{ ref('stg_customers') }}
```

```sql
-- Downstream model using ephemeral
{{ config(
    materialized='table'
) }}

select
    o.order_id,
    c.full_name,  -- From ephemeral model
    c.email,
    o.order_total
from {{ ref('orders') }} o
left join {{ ref('customer_names') }} c  -- Ephemeral model
    on o.customer_id = c.customer_id
```

**Compiled SQL (example):**
```sql
-- The ephemeral model becomes a CTE
with customer_names as (
    select
        customer_id,
        first_name || ' ' || last_name as full_name,
        email
    from stg_customers
)

select
    o.order_id,
    c.full_name,
    c.email,
    o.order_total
from orders o
left join customer_names c
    on o.customer_id = c.customer_id
```

#### ✅ When to Use Ephemeral

- **Shared logic** used in multiple models
- **Intermediate transformations** that don't need persistence
- **DRY principle** - avoiding code duplication
- When you want to **reduce database objects**

#### ❌ When to Avoid Ephemeral

- Complex transformations used in many models (can bloat SQL)
- When you need to query the model independently
- When downstream models are already complex
- Debugging scenarios (can't query ephemeral models directly)

---

## ⚙️ Configuration Methods

### 1. 📄 In Model File (Highest Priority)

```sql
{{ config(
    materialized='incremental',
    unique_key='id',
    schema='marts'
) }}

select * from {{ ref('source_model') }}
```

### 2. 📁 In dbt_project.yml (Project Level)

```yaml
models:
  my_project:
    # All staging models as views
    staging:
      +materialized: view
    
    # All marts as tables
    marts:
      +materialized: table
      
      # Specific folder as incremental
      finance:
        +materialized: incremental
        +unique_key: transaction_id
```

### 3. 🎯 In Model Properties (schema.yml)

```yaml
models:
  - name: orders_incremental
    config:
      materialized: incremental
      unique_key: order_id
      incremental_strategy: merge
```

### Configuration Precedence (Highest to Lowest)

1. **Model file** config block
2. **schema.yml** model config
3. **dbt_project.yml** specific folder config
4. **dbt_project.yml** parent folder config
5. **dbt_project.yml** project-level config
6. **dbt defaults** (view)

---

## 🎯 Choosing the Right Materialization

### Decision Framework

```
Start Here
    ↓
Is it used by multiple downstream models?
    ↓ YES                           ↓ NO
    ↓                               ↓
Is it simple logic?          Is it queried directly?
    ↓ YES         ↓ NO              ↓ YES        ↓ NO
EPHEMERAL      Continue         Continue      VIEW/EPHEMERAL
                   ↓                 ↓
           Is the dataset large?  Is transformation complex?
               ↓ YES    ↓ NO         ↓ YES       ↓ NO
           Continue    TABLE        TABLE       VIEW
               ↓
       Does it change frequently?
           ↓ YES              ↓ NO
       INCREMENTAL          TABLE
```

### Quick Reference Matrix

| Scenario | Recommended | Why |
|----------|-------------|-----|
| **Staging models** | **```view```** | Light transformations, source freshness |
| **Intermediate transformations** | **```ephemeral```** or **```view```** | DRY principle, reduce clutter |
| **Mart/dimension tables** | **```table```** | Frequently queried, complex joins |
| **Large fact tables (< 100M rows)** | **```table```** | Performance for queries |
| **Large fact tables (> 100M rows)** | **```incremental```** | Build time optimization |
| **Event logs** | **```incremental```** | Append-only, continuous growth |
| **Slowly changing dimensions** | **```incremental```** with **```merge```** | Track changes efficiently |
| **Real-time dashboards** | **```table```** or **```incremental```** | Pre-computed for speed |
| **Ad-hoc analysis** | **```view```** | Flexibility, fresh data |
| **Development environment** | **```view```** | Fast iteration, low storage |

---

## 🔧 Advanced Configurations

### Incremental Strategy Details

#### 1. **```append```** Strategy (Default)

```sql
{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

select * from {{ ref('events') }}
{% if is_incremental() %}
    where event_date > (select max(event_date) from {{ this }})
{% endif %}
```

**Behavior**: Only inserts new rows, never updates or deletes
**Use for**: Immutable event data, logs

---

#### 2. **```merge```** Strategy

```sql
{{ config(
    materialized='incremental',
    unique_key='user_id',
    incremental_strategy='merge',
    merge_update_columns=['email', 'updated_at'],
    merge_exclude_columns=['created_at']
) }}

select
    user_id,
    email,
    status,
    created_at,
    updated_at
from {{ ref('stg_users') }}
{% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
{% endif %}
```

**Behavior**: Updates existing rows based on unique_key, inserts new rows
**Use for**: Dimensions, records that can change

---

#### 3. **```delete+insert```** Strategy

```sql
{{ config(
    materialized='incremental',
    unique_key='date_day',
    incremental_strategy='delete+insert'
) }}

select
    date_day,
    sum(revenue) as daily_revenue
from {{ ref('transactions') }}
group by 1
{% if is_incremental() %}
    where date_day >= dateadd(day, -7, current_date)
{% endif %}
```

**Behavior**: Deletes rows matching unique_key, then inserts new rows
**Use for**: Date-partitioned aggregations

---

#### 4. **```insert_overwrite```** Strategy (BigQuery/Spark)

```sql
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by={
        'field': 'event_date',
        'data_type': 'date'
    }
) }}

select
    event_id,
    event_date,
    user_id,
    event_type
from {{ ref('stg_events') }}
{% if is_incremental() %}
    where event_date >= dateadd(day, -3, current_date)
{% endif %}
```

**Behavior**: Overwrites entire partitions
**Use for**: Partitioned tables with late-arriving data

---

### Warehouse-Specific Configurations

#### Snowflake

```sql
{{ config(
    materialized='incremental',
    unique_key='id',
    cluster_by=['event_date', 'user_id'],
    automatic_clustering=true,
    snowflake_warehouse='TRANSFORMING_XL'
) }}
```

#### BigQuery

```sql
{{ config(
    materialized='incremental',
    unique_key='id',
    partition_by={
        'field': 'event_date',
        'data_type': 'date',
        'granularity': 'day'
    },
    cluster_by=['user_id', 'event_type']
) }}
```

#### Redshift

```sql
{{ config(
    materialized='table',
    dist='customer_id',
    sort='order_date',
    bind=false
) }}
```

#### Databricks/Spark

```sql
{{ config(
    materialized='incremental',
    file_format='delta',
    partition_by=['year', 'month'],
    incremental_strategy='merge',
    unique_key='id'
) }}
```

---

## 💡 Best Practices

### 1. 🎯 Materialization Strategy by Layer

```yaml
models:
  my_project:
    # Raw/Staging Layer - Views
    staging:
      +materialized: view
      +schema: staging
    
    # Intermediate Layer - Views or Ephemeral
    intermediate:
      +materialized: view
      +schema: intermediate
    
    # Marts Layer - Tables or Incremental
    marts:
      +materialized: table
      +schema: analytics
      
      # Large fact tables - Incremental
      facts:
        +materialized: incremental
        +unique_key: id
```

### 2. ⚡ Performance Optimization

**Do:**
- ✅ Use **incremental** for large, growing tables (> 1M rows)
- ✅ Add **indexes/clustering** to frequently filtered columns
- ✅ Use **partitioning** for time-series data
- ✅ Set **appropriate unique_key** for incremental models
- ✅ Use **full-refresh** periodically for incremental models

**Don't:**
- ❌ Use ephemeral for complex transformations
- ❌ Use views for frequently queried, complex models
- ❌ Forget to add incremental filters in `is_incremental()` blocks
- ❌ Use incremental for small tables (< 100K rows)

### 3. 🔄 Incremental Model Best Practices

```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    on_schema_change='fail'  -- or 'append_new_columns', 'sync_all_columns'
) }}

select
    order_id,
    customer_id,
    order_date,
    order_total,
    updated_at
from {{ ref('stg_orders') }}

{% if is_incremental() %}
    -- Always include a time-based filter
    where updated_at > (select max(updated_at) from {{ this }})
    
    -- Handle late-arriving data
    or (
        updated_at > dateadd(day, -7, current_date)
        and order_id not in (select order_id from {{ this }})
    )
{% endif %}
```

### 4. 🧪 Testing Materializations

```yaml
models:
  - name: orders_incremental
    config:
      materialized: incremental
      unique_key: order_id
    
    # Test for duplicates
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - order_id
    
    columns:
      - name: order_id
        tests:
          - unique
          - not_null
```

### 5. 🔄 Full Refresh Strategy

```bash
# Force full refresh of incremental models
dbt run --full-refresh

# Full refresh specific model
dbt run --full-refresh --select orders_incremental

# Schedule periodic full refreshes
# Weekly full refresh in production
dbt run --full-refresh --select tag:weekly_refresh
```

---

## 📈 Performance Comparison

### Build Time Comparison (10M Row Table)

| Materialization | Initial Build | Incremental Build | Storage | Query Speed |
|-----------------|---------------|-------------------|---------|-------------|
| **View** | < 1 sec | < 1 sec | 0 GB | ⭐⭐ (Slow) |
| **Table** | 5-10 min | 5-10 min | 10 GB | ⭐⭐⭐⭐⭐ (Fast) |
| **Incremental** | 5-10 min | 10-30 sec | 10 GB | ⭐⭐⭐⭐⭐ (Fast) |
| **Ephemeral** | N/A | N/A | 0 GB | ⭐⭐⭐ (Depends) |

### Cost Considerations

| Factor | View | Table | Incremental | Ephemeral |
|--------|------|-------|-------------|-----------|
| **Storage Cost** | 💰 Low | 💰💰💰 High | 💰💰💰 High | 💰 Low |
| **Compute Cost (Build)** | 💰 Low | 💰💰💰 High | 💰💰 Medium | 💰 Low |
| **Compute Cost (Query)** | 💰💰💰 High | 💰 Low | 💰 Low | 💰💰 Medium |
| **Total Cost (Freq Queries)** | 💰💰💰 High | 💰💰 Medium | 💰💰 Medium | 💰💰 Medium |
| **Total Cost (Rare Queries)** | 💰 Low | 💰💰💰 High | 💰💰💰 High | 💰 Low |

---

## 🎓 Real-World Examples

### Example 1: E-commerce Data Model

```yaml
models:
  ecommerce:
    # Staging - Raw data as views
    staging:
      +materialized: view
      +schema: staging
    
    # Intermediate - Ephemeral for DRY
    intermediate:
      customer_segments:
        +materialized: ephemeral
      product_categories:
        +materialized: ephemeral
    
    # Marts - Mixed based on size
    marts:
      # Small dimension tables - Tables
      dim_customers:
        +materialized: table
      dim_products:
        +materialized: table
      
      # Large fact table - Incremental
      fct_orders:
        +materialized: incremental
        +unique_key: order_id
        +incremental_strategy: merge
      
      # Event logs - Incremental append
      fct_page_views:
        +materialized: incremental
        +unique_key: event_id
        +incremental_strategy: append
```

### Example 2: SaaS Metrics

```sql
-- fct_daily_active_users.sql
{{ config(
    materialized='incremental',
    unique_key='date_day',
    incremental_strategy='delete+insert'
) }}

with events as (
    select
        date_trunc('day', event_timestamp) as date_day,
        user_id,
        event_type
    from {{ ref('stg_events') }}
    {% if is_incremental() %}
        where date_trunc('day', event_timestamp) >= dateadd(day, -7, current_date)
    {% endif %}
)

select
    date_day,
    count(distinct user_id) as daily_active_users,
    count(distinct case when event_type = 'login' then user_id end) as daily_logins,
    count(*) as total_events
from events
group by 1
```

### Example 3: Financial Reporting

```sql
-- fct_monthly_revenue.sql
{{ config(
    materialized='table',
    tags=['finance', 'monthly']
) }}

select
    date_trunc('month', order_date) as month,
    product_category,
    sum(order_total) as monthly_revenue,
    count(distinct customer_id) as unique_customers,
    count(distinct order_id) as order_count
from {{ ref('fct_orders') }}
where order_status = 'completed'
group by 1, 2
```

---

## 🚀 Migration Guide

### Converting View to Table

```sql
-- Before (View)
{{ config(materialized='view') }}

-- After (Table)
{{ config(materialized='table') }}

-- No other changes needed!
```

### Converting Table to Incremental

```sql
-- Before (Table)
{{ config(materialized='table') }}

select * from {{ ref('source') }}

-- After (Incremental)
{{ config(
    materialized='incremental',
    unique_key='id'
) }}

select * from {{ ref('source') }}

{% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
{% endif %}
```

---

## 📚 Quick Reference Card

| Need | Use | Syntax |
|------|-----|--------|
| Fast build, simple logic | **View** | **```{{ config(materialized='view') }}```** |
| Frequently queried, complex | **Table** | **```{{ config(materialized='table') }}```** |
| Large growing table | **Incremental** | **```{{ config(materialized='incremental', unique_key='id') }}```** |
| Shared logic, no persistence | **Ephemeral** | **```{{ config(materialized='ephemeral') }}```** |
| Event logs, append only | **Incremental append** | **```{{ config(materialized='incremental', incremental_strategy='append') }}```** |
| Updating records | **Incremental merge** | **```{{ config(materialized='incremental', incremental_strategy='merge', unique_key='id') }}```** |

---

<div align="center">

### 🎯 Key Takeaways

![Takeaway 1](https://img.shields.io/badge/💡_Views-Fast_builds,_slow_queries-4CAF50?style=for-the-badge)
![Takeaway 2](https://img.shields.io/badge/💡_Tables-Slow_builds,_fast_queries-2196F3?style=for-the-badge)
![Takeaway 3](https://img.shields.io/badge/💡_Incremental-Best_of_both_worlds-9C27B0?style=for-the-badge)

</div>

---

*Note: Specific features and configurations may vary by data warehouse. Always refer to [dbt documentation](https://docs.getdbt.com/docs/build/materializations) for your specific platform.*
