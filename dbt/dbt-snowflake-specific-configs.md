# dbt + Snowflake: Configuration Guide

## Overview
This guide covers Snowflake-specific dbt configurations that differ from Redshift. Coming from dbt + Redshift, these are the key areas requiring attention when working with dbt + Snowflake.

---

## Table of Contents
1. [Materialization Strategies](#1-materialization-strategies)
2. [Table Configuration](#2-table-configuration)
3. [Performance Optimization](#3-performance-optimization)
4. [Python Models](#4-python-models)
5. [Security & Access Control](#5-security--access-control)
6. [Monitoring & Debugging](#6-monitoring--debugging)
7. [Quick Reference](#7-quick-reference)

---

## 1. Materialization Strategies

### 1.1 Dynamic Tables (Snowflake-Exclusive)
Dynamic tables are Snowflake's alternative to materialized views, offering auto-refresh capabilities.

**Basic Configuration:**
```sql
{{ config(
    materialized='dynamic_table',
    snowflake_warehouse='COMPUTE_WH',
    target_lag='30 minutes',
    on_configuration_change='apply'
) }}

select
    user_id,
    count(*) as event_count,
    max(event_time) as last_event
from {{ source('analytics', 'events') }}
group by 1
```

**Target Lag Options:**
- **Time-based**: `'30 minutes'`, `'1 hour'`, `'2 days'`
- **Downstream**: `'downstream'` (refresh controlled by downstream tables)

**Important Notes:**
- ⚠️ Requires `QUOTED_IDENTIFIERS_IGNORE_CASE = FALSE` in Snowflake account
- ⚠️ SQL cannot be updated (requires `--full-refresh` with DROP/CREATE)
- ✅ Supports clustering (since dbt Core v1.11)
- ❌ Cannot be downstream from: materialized views, external tables, streams
- ❌ Model contracts and copy grants NOT supported

**When to Use:**
- Near real-time data pipelines
- Incremental-like behavior with automatic refresh
- Dependency-driven refresh patterns

---

### 1.2 Incremental Models

Snowflake supports **5 incremental strategies** (vs 3-4 in Redshift):

```sql
{{ config(
    materialized='incremental',
    incremental_strategy='delete+insert',  -- See options below
    unique_key='id',
    tmp_relation_type='view'  -- Default: view (not table)
) }}
```

**Strategy Options:**

| Strategy | Use Case | Notes |
|----------|----------|-------|
| `merge` | Upserts with unique key | Default; fails if `unique_key` not truly unique |
| `delete+insert` | Non-deterministic keys | Two-step process; safer for duplicates |
| `append` | Append-only data | No deduplication |
| `insert_overwrite` | Full table replacement | Truncate + re-insert (not partition-based) |
| `microbatch` | Time-series data | Batch processing by time window |

**Temporary Relation Behavior (Snowflake-Specific):**
```sql
{{ config(
    tmp_relation_type='view'  -- Default: saves compile time
    -- OR
    tmp_relation_type='table'  -- Use for complex scenarios
) }}
```

**Key Difference from Redshift:**
- Snowflake prefers **views** over temporary tables for incremental merges
- Avoids database write steps → faster compilation
- Exception: `delete+insert` with `unique_key` requires table

---

## 2. Table Configuration

### 2.1 Transient Tables (Default Behavior)

**Critical:** Unlike Redshift, **all dbt-created Snowflake tables are TRANSIENT by default**.

```sql
{{ config(
    materialized='table',
    transient=true  -- DEFAULT (can omit)
) }}
```

**Transient vs Permanent:**

| Feature | Transient (Default) | Permanent |
|---------|---------------------|-----------|
| Time Travel | 1 day | 90 days (configurable) |
| Fail-safe | ❌ None | ✅ 7 days |
| Storage Cost | Lower | Higher |
| Use Case | ETL, staging | Critical business data |

**Project-Level Configuration:**
```yaml
# dbt_project.yml
models:
  +transient: true  # Explicit default
  
  my_project:
    marts:
      +transient: false  # Permanent tables for final outputs
```

**When to Use Permanent Tables:**
- Critical business metrics requiring extended Time Travel
- Regulatory compliance requirements
- Data recovery requirements beyond 1 day

---

### 2.2 Table Clustering

Snowflake's clustering improves query performance for large tables.

```sql
{{ config(
    materialized='table',
    cluster_by=['date_column', 'user_id']
) }}
```

**How It Works:**
1. dbt implicitly **orders table results** by `cluster_by` fields
2. Adds clustering keys via `ALTER TABLE ... CLUSTER BY`
3. Snowflake's automatic clustering maintains cluster health

**Dynamic Table Clustering (v1.11+):**
```sql
{{ config(
    materialized='dynamic_table',
    target_lag='1 minute',
    cluster_by=['session_start', 'user_id']
) }}
```

**Best Practices:**
- Use on tables > 1TB
- Select high-cardinality columns used in filters/joins
- Avoid over-clustering (max 3-4 columns)
- Monitor clustering health with `SYSTEM$CLUSTERING_INFORMATION`

**vs Redshift:**
- Redshift: `sort_key` + `dist_key`
- Snowflake: `cluster_by` (auto-clustering enabled by default)

---

## 3. Performance Optimization

### 3.1 Virtual Warehouse Configuration

Override warehouse size per model or test for cost and performance optimization.

**Model-Level Configuration:**
```sql
-- models/finance/revenue_report.sql
{{ config(
    snowflake_warehouse='EXTRA_LARGE'
) }}
```

**Project-Level Configuration:**
```yaml
# dbt_project.yml
models:
  +snowflake_warehouse: "SMALL"  # Default for all models
  
  my_project:
    heavy_transforms:
      +snowflake_warehouse: "LARGE"  # Large models
    
snapshots:
  +snowflake_warehouse: "MEDIUM"

data_tests:
  +snowflake_warehouse: "XSMALL"  # Cost-effective for tests
```

**Strategy:**
- **XSMALL/SMALL**: Tests, simple transformations
- **MEDIUM**: Standard models
- **LARGE/XLARGE**: Heavy aggregations, large joins
- **2XLARGE+**: Complex analytics, ML workloads

---

### 3.2 Copy Grants

Preserve privilege grants when rebuilding tables/views (important for production).

```sql
{{ config(
    copy_grants=true
) }}
```

**Project-Level:**
```yaml
models:
  +copy_grants: true  # Maintain permissions on table rebuilds
```

**When to Enable:**
- Production environments
- Tables with complex permission structures
- Shared datasets across teams

**Default:** `false` (grants are dropped on rebuild)

---

## 4. Python Models

### 4.1 Snowpark Configuration

Snowflake uses **Snowpark** (not PySpark) for Python models.

**Basic Setup:**
```python
def model(dbt, session):
    dbt.config(
        materialized="table",
        python_version="3.11",  # Options: 3.9, 3.10, 3.11
        packages=['pandas==1.5.3', 'numpy', 'scikit-learn']
    )
    
    import pandas as pd
    
    # Your transformation logic
    df = session.table('source_table').to_pandas()
    df['new_column'] = df['existing_column'] * 2
    
    return session.create_dataframe(df)
```

**Prerequisites:**
- ✅ Accept Snowflake Third Party Terms for Anaconda packages
- ✅ Use dedicated warehouse for performance (not shared)

**Available Packages:**
- View complete list: [Snowflake Anaconda Channel](https://repo.anaconda.com/pkgs/snowflake/)
- Packages installed at runtime (per model)

---

### 4.2 External APIs & Custom Packages

**External Access (Secrets & Integrations):**
```python
def model(dbt, session):
    dbt.config(
        materialized="table",
        secrets={"api_key": "my_snowflake_secret"},
        external_access_integrations=["api_integration"]
    )
    
    import _snowflake
    api_key = _snowflake.get_generic_secret_string('api_key')
    
    # Call external API with secret
    # ...
```

**Third-Party Packages (via Staging):**
```python
def model(dbt, session):
    dbt.config(
        imports=["@mystage/custom_package.zip"]
    )
    
    import custom_package
    # Use custom package functions
```

**Upload Process:**
1. Create Snowflake stage: `CREATE STAGE mystage;`
2. Upload package: `PUT file://custom_package.zip @mystage;`
3. Reference in dbt model via `imports` config

---

## 5. Security & Access Control

### 5.1 Secure Views

Create secure views to protect sensitive data (with performance tradeoff).

```sql
{{ config(
    materialized='view',
    secure=true
) }}

select
    user_id,
    masked_email,
    -- Sensitive columns hidden from view definition
from {{ ref('users') }}
```

**Project-Level:**
```yaml
models:
  my_project:
    sensitive:
      +materialized: view
      +secure: true
```

**Characteristics:**
- ⚠️ Performance penalty (query optimization limited)
- ✅ Prevents view definition inspection
- ✅ Use only for PII/sensitive data

---

## 6. Monitoring & Debugging

### 6.1 Query Tags

Tag dbt queries for tracking in `QUERY_HISTORY` view.

**Model-Level:**
```sql
{{ config(
    query_tag='dbt_finance_models'
) }}
```

**Project-Level:**
```yaml
models:
  my_project:
    finance:
      +query_tag: 'finance_analytics'
```

**Custom Macro (Dynamic Tags):**
```sql
-- macros/set_query_tag.sql
{% macro set_query_tag() -%}
  {% set new_query_tag = model.name %}
  {% if new_query_tag %}
    {% do run_query("alter session set query_tag = '{}'".format(new_query_tag)) %}
  {% endif %}
{% endmacro %}
```

**Query History Analysis:**
```sql
SELECT
    query_tag,
    warehouse_name,
    total_elapsed_time,
    credits_used_cloud_services
FROM snowflake.account_usage.query_history
WHERE query_tag LIKE 'dbt_%'
ORDER BY start_time DESC;
```

---

### 6.2 Source Freshness Limitation

**Important:** Snowflake's `LAST_ALTERED` updates on **any object modification**, not just data changes.

**What Triggers Updates:**
- ✅ DML operations (data changes)
- ⚠️ DDL operations (schema changes)
- ⚠️ Background maintenance (Snowflake internal)

**Impact:**
- Source freshness checks may show false positives
- Consider this when setting freshness thresholds

**Mitigation:**
- Use metadata columns (`_loaded_at` timestamp) where possible
- Adjust freshness `warn_after`/`error_after` thresholds accordingly

---

## 7. Quick Reference

### 7.1 Snowflake vs Redshift Comparison

| Feature | Snowflake | Redshift |
|---------|-----------|----------|
| **Dynamic Tables** | ✅ Native support | ❌ Not available |
| **Default Table Type** | Transient | Permanent |
| **Incremental Temp Relations** | View (default) | Table |
| **Clustering** | `cluster_by` (auto) | `sort_key` + `dist_key` |
| **Secure Views** | `secure=true` | Not applicable |
| **Warehouse per Model** | `snowflake_warehouse` | N/A (cluster-level) |
| **Python Framework** | Snowpark | N/A |
| **Query Tags** | ✅ Supported | ❌ Not available |
| **Copy Grants** | `copy_grants` | Not applicable |
| **Incremental Strategies** | 5 options | 3-4 options |

---

### 7.2 Common Configuration Patterns

**High-Performance Model:**
```sql
{{ config(
    materialized='table',
    transient=false,  -- Permanent for critical data
    cluster_by=['date', 'region'],
    snowflake_warehouse='LARGE',
    query_tag='critical_analytics'
) }}
```

**Cost-Optimized Model:**
```sql
{{ config(
    materialized='incremental',
    incremental_strategy='append',
    tmp_relation_type='view',
    transient=true,
    snowflake_warehouse='SMALL'
) }}
```

**Near Real-Time Model:**
```sql
{{ config(
    materialized='dynamic_table',
    target_lag='5 minutes',
    snowflake_warehouse='MEDIUM',
    cluster_by=['event_timestamp']
) }}
```

**Secure Sensitive Data:**
```sql
{{ config(
    materialized='view',
    secure=true,
    copy_grants=true
) }}
```

---

### 7.3 Migration Checklist (Redshift → Snowflake)

- [ ] Update `profiles.yml` with Snowflake connection details
- [ ] Review table materialization (`transient` defaults)
- [ ] Convert `sort_key`/`dist_key` to `cluster_by`
- [ ] Evaluate dynamic tables for incremental models
- [ ] Configure warehouse sizes per model type
- [ ] Implement query tags for cost monitoring
- [ ] Enable `copy_grants` for production models
- [ ] Test incremental strategies (handle `merge` errors)
- [ ] Review source freshness thresholds
- [ ] Migrate Python models to Snowpark (if applicable)

---

### 7.4 Key Snowflake-Specific Configs Summary

```yaml
# dbt_project.yml - Comprehensive Example
models:
  +transient: true
  +copy_grants: true
  +query_tag: 'dbt_production'
  +snowflake_warehouse: 'MEDIUM'
  
  my_project:
    staging:
      +materialized: view
      +snowflake_warehouse: 'SMALL'
    
    intermediate:
      +materialized: ephemeral
    
    marts:
      +materialized: table
      +transient: false
      +cluster_by: ['date_day']
      +snowflake_warehouse: 'LARGE'
      +copy_grants: true
    
    realtime:
      +materialized: dynamic_table
      +target_lag: '10 minutes'
      +snowflake_warehouse: 'MEDIUM'
    
    sensitive:
      +materialized: view
      +secure: true

snapshots:
  +snowflake_warehouse: 'SMALL'
  +transient: false

data_tests:
  +snowflake_warehouse: 'XSMALL'
```

---

## Additional Resources

- **Official Documentation**: [dbt Snowflake Configs](https://docs.getdbt.com/reference/resource-configs/snowflake-configs)
- **Snowflake Dynamic Tables**: [User Guide](https://docs.snowflake.com/en/user-guide/dynamic-tables-about)
- **Snowpark Python**: [Developer Guide](https://docs.snowflake.com/en/developer-guide/snowpark/python/index.html)
- **Clustering Guide**: [Table Clustering Keys](https://docs.snowflake.net/manuals/user-guide/tables-clustering-keys.html)
- **Query Tags**: [Parameter Reference](https://docs.snowflake.com/en/sql-reference/parameters.html#query-tag)

---

## Best Practices Summary

1. **Start with defaults**: Leverage transient tables and view-based incremental builds
2. **Cluster strategically**: Only for large tables with clear access patterns
3. **Size warehouses appropriately**: Match compute to workload complexity
4. **Use dynamic tables**: For near real-time pipelines instead of complex incremental logic
5. **Monitor costs**: Use query tags and Snowflake's cost monitoring tools
6. **Secure sensitive data**: Apply `secure=true` judiciously (performance impact)
7. **Test incremental strategies**: Validate `unique_key` constraints to avoid merge errors
8. **Plan for Time Travel**: Use `transient=false` for critical data requiring extended recovery

---

*Last Updated: February 2026*
*dbt Core Version: 1.11+*
*Snowflake Adapter: Latest*
