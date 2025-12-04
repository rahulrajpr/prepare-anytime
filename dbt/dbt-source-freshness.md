# 🕐 dbt Source Freshness Guide

<div align="center">

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Freshness](https://img.shields.io/badge/Freshness-00C853?style=for-the-badge)
![Monitoring](https://img.shields.io/badge/Monitoring-2196F3?style=for-the-badge)

</div>

A concise guide to monitoring data freshness in dbt - ensuring your source data is up-to-date.

---

## 📑 Quick Navigation

1. [🔍 What is Source Freshness?](#-what-is-source-freshness)
2. [⚙️ Basic Configuration](#️-basic-configuration)
3. [🎯 Freshness Checks](#-freshness-checks)
4. [🚀 Running Freshness Checks](#-running-freshness-checks)
5. [📊 Advanced Patterns](#-advanced-patterns)
6. [💡 Best Practices](#-best-practices)

---

## 🔍 What is Source Freshness?

**Source Freshness** checks when your source data was last updated. It helps you:

✅ **Detect Data Issues** - Know when upstream data pipelines fail  
✅ **Set SLAs** - Define acceptable data staleness  
✅ **Alert Teams** - Get notified when data is stale  
✅ **Monitor Pipelines** - Track data pipeline health  

### How It Works

```
1. dbt queries the max(loaded_at_field) from your source table
2. Compares it to current timestamp
3. Checks against your warn_after and error_after thresholds
4. Returns PASS, WARN, or ERROR status
```

---

## ⚙️ Basic Configuration

### 1. Define Source with Freshness

```yaml
# models/staging/sources.yml

version: 2

sources:
  - name: raw_database
    database: raw_db
    schema: public
    
    # Default freshness for all tables
    freshness:
      warn_after: {count: 12, period: hour}
      error_after: {count: 24, period: hour}
    
    tables:
      - name: orders
        description: "Raw orders data"
        
        # Specify which column tracks freshness
        loaded_at_field: updated_at
        
        # Override source-level freshness
        freshness:
          warn_after: {count: 1, period: hour}
          error_after: {count: 2, period: hour}
      
      - name: customers
        loaded_at_field: _fivetran_synced
        freshness:
          warn_after: {count: 6, period: hour}
          error_after: {count: 12, period: hour}
```

---

### 2. Freshness Parameters

```yaml
freshness:
  warn_after:
    count: 12        # Number (required)
    period: hour     # minute, hour, day (required)
  
  error_after:
    count: 24        # Number (required)
    period: hour     # minute, hour, day (required)
  
  filter: null       # Optional SQL filter
```

**Supported Periods:**
- `minute`
- `hour` 
- `day`

---

## 🎯 Freshness Checks

### Example 1: Real-Time Data (Hourly)

```yaml
sources:
  - name: event_stream
    tables:
      - name: events
        loaded_at_field: event_timestamp
        freshness:
          warn_after: {count: 1, period: hour}
          error_after: {count: 2, period: hour}
```

**Use Case:** Real-time analytics, event streams

---

### Example 2: Daily Batch Loads

```yaml
sources:
  - name: data_warehouse
    tables:
      - name: daily_orders
        loaded_at_field: load_date
        freshness:
          warn_after: {count: 26, period: hour}  # 2 AM +/- 2 hours
          error_after: {count: 30, period: hour}
```

**Use Case:** Overnight batch jobs, ETL pipelines

---

### Example 3: Weekly Data

```yaml
sources:
  - name: external_vendor
    tables:
      - name: weekly_reports
        loaded_at_field: report_date
        freshness:
          warn_after: {count: 7, period: day}
          error_after: {count: 10, period: day}
```

**Use Case:** Weekly vendor reports, monthly aggregates

---

### Example 4: Multiple Sources

```yaml
sources:
  # High-frequency data
  - name: production_db
    freshness:
      warn_after: {count: 30, period: minute}
      error_after: {count: 1, period: hour}
    
    tables:
      - name: user_activity
        loaded_at_field: activity_timestamp
      
      - name: transactions
        loaded_at_field: transaction_time
  
  # Low-frequency data
  - name: analytics_db
    freshness:
      warn_after: {count: 1, period: day}
      error_after: {count: 2, period: day}
    
    tables:
      - name: daily_metrics
        loaded_at_field: metric_date
```

---

## 🚀 Running Freshness Checks

### Command Line

```bash
# Check all sources
dbt source freshness

# Check specific source
dbt source freshness --select source:raw_database

# Check specific table
dbt source freshness --select source:raw_database.orders

# Output to JSON
dbt source freshness --output target/freshness.json

# Select by tag
dbt source freshness --select tag:critical
```

---

### Output Example

```
14:32:15  Running with dbt=1.7.0
14:32:15  Found 5 models, 3 sources, 0 exposures, 0 metrics
14:32:15  
14:32:15  Concurrency: 4 threads (target='prod')
14:32:15  
14:32:15  1 of 3 START freshness of raw_database.orders ........................ [RUN]
14:32:15  1 of 3 PASS freshness of raw_database.orders ......................... [PASS in 0.23s]
14:32:16  2 of 3 START freshness of raw_database.customers ..................... [RUN]
14:32:16  2 of 3 WARN freshness of raw_database.customers ...................... [WARN in 0.18s]
14:32:16  3 of 3 START freshness of raw_database.payments ...................... [RUN]
14:32:16  3 of 3 ERROR freshness of raw_database.payments ...................... [ERROR in 0.21s]
14:32:16  
14:32:16  Done. PASSED=1 WARN=1 ERROR=1 SKIP=0 TOTAL=3
```

---

### Exit Codes

| Status | Exit Code | Meaning |
|--------|-----------|---------|
| ✅ PASS | 0 | All sources fresh |
| ⚠️ WARN | 0 | Some warnings, no errors |
| ❌ ERROR | 1 | At least one error |

---

## 📊 Advanced Patterns

### 1. Using Filters

```yaml
sources:
  - name: raw_database
    tables:
      - name: orders
        loaded_at_field: updated_at
        
        # Only check completed orders
        freshness:
          warn_after: {count: 1, period: hour}
          error_after: {count: 2, period: hour}
          filter: "status = 'completed'"
```

---

### 2. Different Freshness by Environment

```yaml
# sources.yml
sources:
  - name: raw_database
    tables:
      - name: orders
        loaded_at_field: updated_at
        freshness:
          # Strict in prod
          warn_after: {count: "{{ 1 if target.name == 'prod' else 24 }}", period: hour}
          error_after: {count: "{{ 2 if target.name == 'prod' else 48 }}", period: hour}
```

---

### 3. Tagging for Selective Checks

```yaml
sources:
  - name: raw_database
    tables:
      - name: orders
        loaded_at_field: updated_at
        tags: ['critical', 'hourly']
        freshness:
          warn_after: {count: 1, period: hour}
          error_after: {count: 2, period: hour}
      
      - name: archived_orders
        loaded_at_field: updated_at
        tags: ['non_critical', 'daily']
        freshness:
          warn_after: {count: 1, period: day}
          error_after: {count: 2, period: day}
```

**Run:**
```bash
# Only critical sources
dbt source freshness --select tag:critical

# Only hourly checks
dbt source freshness --select tag:hourly
```

---

### 4. CI/CD Integration

```yaml
# .github/workflows/freshness_check.yml
name: Check Data Freshness

on:
  schedule:
    - cron: '0 * * * *'  # Every hour

jobs:
  freshness:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.9'
      
      - name: Install dbt
        run: pip install dbt-snowflake
      
      - name: Run freshness check
        run: |
          dbt source freshness --select tag:critical
        env:
          DBT_PROFILES_DIR: .
      
      - name: Alert on failure
        if: failure()
        run: |
          # Send Slack notification
          curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
            -H 'Content-Type: application/json' \
            -d '{"text": "⚠️ Data freshness check failed!"}'
```

---

### 5. Airflow Integration

```python
# airflow/dags/freshness_monitoring.py
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

def send_alert(**context):
    """Send alert if freshness check fails"""
    # Implement Slack/email notification
    pass

with DAG(
    'dbt_freshness_monitoring',
    start_date=datetime(2024, 1, 1),
    schedule_interval='@hourly',
    catchup=False,
) as dag:
    
    check_freshness = BashOperator(
        task_id='check_source_freshness',
        bash_command='cd /dbt && dbt source freshness --select tag:critical',
    )
    
    alert_on_failure = PythonOperator(
        task_id='alert_on_failure',
        python_callable=send_alert,
        trigger_rule='one_failed',
    )
    
    check_freshness >> alert_on_failure
```

---

### 6. Parsing Freshness Results

```python
# scripts/parse_freshness.py
import json

# Read freshness results
with open('target/sources.json', 'r') as f:
    results = json.load(f)

# Analyze results
for source in results['results']:
    name = f"{source['source_name']}.{source['table_name']}"
    status = source['status']
    max_loaded_at = source['max_loaded_at']
    
    if status == 'error':
        print(f"❌ ERROR: {name} - Last loaded: {max_loaded_at}")
    elif status == 'warn':
        print(f"⚠️  WARN: {name} - Last loaded: {max_loaded_at}")
    else:
        print(f"✅ PASS: {name}")
```

---

## 💡 Best Practices

### 1. 🎯 Set Realistic Thresholds

```yaml
# ❌ BAD: Too strict for daily batch
sources:
  - name: daily_etl
    tables:
      - name: daily_revenue
        loaded_at_field: load_date
        freshness:
          warn_after: {count: 1, period: hour}  # Will always fail!
          error_after: {count: 2, period: hour}

# ✅ GOOD: Appropriate for daily batch
sources:
  - name: daily_etl
    tables:
      - name: daily_revenue
        loaded_at_field: load_date
        freshness:
          warn_after: {count: 26, period: hour}  # 2 AM +/- 2 hours
          error_after: {count: 30, period: hour}
```

---

### 2. ⚡ Use Appropriate Loaded At Fields

```yaml
# ✅ GOOD: Use actual update timestamps
tables:
  - name: orders
    loaded_at_field: updated_at          # Row-level update time
  
  - name: fivetran_data
    loaded_at_field: _fivetran_synced    # Sync timestamp
  
  - name: stitch_data
    loaded_at_field: _sdc_batched_at     # Batch timestamp

# ❌ BAD: Using wrong columns
tables:
  - name: orders
    loaded_at_field: order_date          # Business date, not load time!
```

---

### 3. 📊 Monitor Different Data Tiers

```yaml
sources:
  # Tier 1: Critical real-time data
  - name: production_db
    freshness:
      warn_after: {count: 15, period: minute}
      error_after: {count: 30, period: minute}
    tags: ['tier1', 'critical']
    
    tables:
      - name: transactions
        loaded_at_field: created_at
  
  # Tier 2: Important hourly data
  - name: analytics_db
    freshness:
      warn_after: {count: 2, period: hour}
      error_after: {count: 4, period: hour}
    tags: ['tier2', 'important']
    
    tables:
      - name: user_sessions
        loaded_at_field: session_start
  
  # Tier 3: Less critical daily data
  - name: reporting_db
    freshness:
      warn_after: {count: 1, period: day}
      error_after: {count: 2, period: day}
    tags: ['tier3', 'standard']
    
    tables:
      - name: daily_summaries
        loaded_at_field: summary_date
```

---

### 4. 🔔 Implement Alerting

```bash
# Bash script with Slack notification
#!/bin/bash

dbt source freshness --select tag:critical

if [ $? -eq 0 ]; then
    echo "✅ All sources fresh"
else
    # Send alert
    curl -X POST $SLACK_WEBHOOK \
        -H 'Content-Type: application/json' \
        -d '{
            "text": "⚠️ Data freshness check failed!",
            "attachments": [{
                "color": "danger",
                "text": "Check dbt logs for details"
            }]
        }'
fi
```

---

### 5. 📝 Document Expectations

```yaml
sources:
  - name: raw_database
    description: |
      Source: Production PostgreSQL database
      Update Frequency: Every 15 minutes
      Owner: Data Engineering team
      Contact: data-eng@company.com
      
    tables:
      - name: orders
        description: |
          Raw orders from production system.
          
          **Freshness SLA:**
          - Warn: > 1 hour stale
          - Error: > 2 hours stale
          
          **Loaded At Field:** updated_at (timestamp when row was last modified)
          
          **Upstream:** Kafka -> Postgres replication
          **Owner:** Platform team
          
        loaded_at_field: updated_at
        freshness:
          warn_after: {count: 1, period: hour}
          error_after: {count: 2, period: hour}
```

---

## 🎯 Common Patterns

### Pattern 1: Real-Time Monitoring

```yaml
# For streaming/real-time data
sources:
  - name: kafka_streams
    freshness:
      warn_after: {count: 5, period: minute}
      error_after: {count: 15, period: minute}
    
    tables:
      - name: clickstream_events
        loaded_at_field: event_timestamp
```

**Schedule:** Every 15 minutes

---

### Pattern 2: Nightly Batch Jobs

```yaml
# For overnight ETL jobs (run at 2 AM)
sources:
  - name: nightly_etl
    freshness:
      warn_after: {count: 26, period: hour}  # 2 AM + 2 hour buffer
      error_after: {count: 30, period: hour}
    
    tables:
      - name: aggregated_metrics
        loaded_at_field: batch_date
```

**Schedule:** Check at 8 AM daily

---

### Pattern 3: External Vendors

```yaml
# For third-party data feeds
sources:
  - name: vendor_api
    freshness:
      warn_after: {count: 1, period: day}
      error_after: {count: 3, period: day}  # More lenient
    
    tables:
      - name: market_data
        loaded_at_field: feed_timestamp
```

**Schedule:** Check twice daily

---

## 📈 Monitoring Dashboard

### Create Freshness Summary

```sql
-- models/meta/source_freshness_summary.sql
with freshness_checks as (
    select
        source_name,
        table_name,
        loaded_at_field,
        max_loaded_at,
        snapshotted_at,
        datediff('hour', max_loaded_at, snapshotted_at) as hours_stale,
        status,
        warn_after_hours,
        error_after_hours
    from {{ ref('dbt_source_freshness') }}
)

select
    source_name,
    table_name,
    max_loaded_at as last_updated,
    hours_stale,
    status,
    case
        when status = 'pass' then '✅'
        when status = 'warn' then '⚠️'
        when status = 'error' then '❌'
    end as status_icon,
    case
        when hours_stale <= warn_after_hours * 0.5 then 'Healthy'
        when hours_stale <= warn_after_hours then 'Watch'
        when hours_stale <= error_after_hours then 'Warning'
        else 'Critical'
    end as health_status
from freshness_checks
order by hours_stale desc
```

---

## 🚨 Troubleshooting

### Issue 1: Freshness Check Always Fails

**Problem:** Check fails even though data is current

**Solutions:**
```yaml
# Check 1: Verify loaded_at_field has data
tables:
  - name: orders
    loaded_at_field: updated_at  # Does this column exist?

# Check 2: Verify timezone handling
# Use UTC timestamps

# Check 3: Check filter syntax
freshness:
  filter: "status = 'completed'"  # Correct SQL syntax?
```

---

### Issue 2: No Freshness Results

**Problem:** `dbt source freshness` returns nothing

**Solutions:**
1. Verify sources.yml exists
2. Check loaded_at_field is specified
3. Ensure freshness config is present
4. Verify source connection works

---

### Issue 3: Wrong Thresholds

**Problem:** Constant false positives/negatives

**Solution:**
```yaml
# Analyze your data update patterns first
# Query: 
# SELECT 
#   date_trunc('hour', updated_at) as hour,
#   max(updated_at) as last_update
# FROM orders
# GROUP BY 1
# ORDER BY 1 DESC
# LIMIT 168  -- Last week

# Then set appropriate thresholds
```

---

## 📚 Quick Reference

### Freshness Config Structure

```yaml
sources:
  - name: <source_name>
    freshness:                    # Source-level (inherited by all tables)
      warn_after: {count: X, period: minute|hour|day}
      error_after: {count: X, period: minute|hour|day}
    
    tables:
      - name: <table_name>
        loaded_at_field: <column_name>    # Required for freshness
        freshness:                         # Table-level (overrides source)
          warn_after: {count: X, period: minute|hour|day}
          error_after: {count: X, period: minute|hour|day}
          filter: "<SQL condition>"        # Optional
```

---

### Command Cheat Sheet

```bash
# Basic
dbt source freshness

# By selection
dbt source freshness --select source:raw_database
dbt source freshness --select source:raw_database.orders
dbt source freshness --select tag:critical

# Output options
dbt source freshness --output target/freshness.json
dbt source freshness --output-keys

# Help
dbt source freshness --help
```

---

### Recommended Thresholds

| Data Type | Update Frequency | warn_after | error_after |
|-----------|-----------------|------------|-------------|
| **Streaming** | Continuous | 5-15 min | 30-60 min |
| **Micro-batch** | Every 15 min | 30 min | 1 hour |
| **Hourly** | Every hour | 2 hours | 4 hours |
| **Daily (2 AM)** | Once daily | 26 hours | 30 hours |
| **Weekly** | Once weekly | 8 days | 10 days |
| **External vendor** | Variable | 2 days | 5 days |

---

<div align="center">

### 🎯 Key Takeaways

![Takeaway 1](https://img.shields.io/badge/💡_Set_Realistic_SLAs-Match_Update_Frequency-4CAF50?style=for-the-badge)
![Takeaway 2](https://img.shields.io/badge/💡_Monitor_Continuously-Catch_Issues_Early-2196F3?style=for-the-badge)
![Takeaway 3](https://img.shields.io/badge/💡_Alert_Smartly-Different_Tiers_Different_Rules-9C27B0?style=for-the-badge)

**Remember**: Freshness checks are about monitoring upstream data health, not dbt performance!

</div>

---

*Pro Tip: Start with lenient thresholds and tighten them as you understand your data update patterns.*
