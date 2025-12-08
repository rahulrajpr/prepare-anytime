# Snowflake Interview Prep Guide for Senior Data Engineers
## A Concept-Driven, Scenario-Based Study Resource

---

## Table of Contents
1. [Snowflake Architecture & Core Concepts](#1-snowflake-architecture--core-concepts)
2. [Virtual Warehouses & Compute](#2-virtual-warehouses--compute)
3. [Storage & Data Organization](#3-storage--data-organization)
4. [Query Performance & Optimization](#4-query-performance--optimization)
5. [Data Loading & Unloading](#5-data-loading--unloading)
6. [Security & Governance](#6-security--governance)
7. [Data Sharing & Collaboration](#7-data-sharing--collaboration)
8. [Snowflake + dbt Integration](#8-snowflake--dbt-integration)
9. [Cost Optimization Strategies](#9-cost-optimization-strategies)
10. [Time Travel, Fail-Safe, and Data Recovery](#10-time-travel-fail-safe-and-data-recovery)
11. [Advanced Topics & Real-World Scenarios](#11-advanced-topics--real-world-scenarios)
12. [Interview Questions by Category](#12-interview-questions-by-category)

---

## 1. Snowflake Architecture & Core Concepts

### The Three-Layer Architecture

**Why this matters**: Understanding Snowflake's unique architecture is fundamental. Unlike traditional databases or even Redshift, Snowflake completely separates compute, storage, and metadata management.

#### Layer 1: Database Storage
- **What it is**: All data is stored in Snowflake's cloud storage (S3, Azure Blob, or GCS)
- **Key concept**: Data is automatically compressed, encrypted, and organized into micro-partitions (typically 50-500MB uncompressed)
- **Why it's different**: Storage is completely independent of compute. You can pause all warehouses and data remains accessible when you resume.

**Interview scenario**: 
*"We have seasonal analytics workloads. During off-season, can we reduce costs to near zero?"*
- **Answer**: Yes, you can suspend all virtual warehouses. You only pay for storage (typically $23-40/TB/month depending on cloud). No compute charges when suspended. When you need to analyze again, resume warehouses instantly.

#### Layer 2: Query Processing (Virtual Warehouses)
- **What it is**: Clusters of compute resources (VMs) that execute queries
- **Key concept**: Multiple warehouses can run simultaneously against the same data without contention
- **Why it's different**: Each warehouse is completely isolated. No resource competition between teams/workloads.

**Interview scenario**:
*"Our ETL jobs interfere with analyst queries, causing slowdowns. How would you solve this in Snowflake?"*
- **Answer**: Create separate virtual warehouses:
  - `ETL_WH` (Large, for batch processing)
  - `ANALYST_WH` (Medium, for interactive queries)
  - `BI_DASHBOARD_WH` (X-Small with auto-suspend, for dashboard refreshes)
- Each runs independently, no interference. ETL workload doesn't impact analyst experience.

#### Layer 3: Cloud Services
- **What it is**: Manages authentication, metadata, query optimization, transaction coordination
- **Key concept**: Handles query parsing, optimization, access control, and metadata operations
- **Why it matters**: You don't manage this layer, but understanding it helps explain query compilation time and metadata operations

### Micro-Partitions: The Secret Sauce

**Concept**: Snowflake automatically divides tables into immutable, compressed micro-partitions (roughly 16MB compressed).

**Why this matters**:
1. **Automatic clustering**: Snowflake orders data by ingestion/modification order, maintaining natural clustering
2. **Pruning efficiency**: Query optimizer can skip entire micro-partitions based on metadata
3. **Time Travel**: Immutability enables point-in-time queries without complex logging

**Real-world example**:
```sql
-- You load data daily by date
INSERT INTO sales 
SELECT * FROM daily_sales 
WHERE sale_date = '2025-01-15';

-- Next day
INSERT INTO sales 
SELECT * FROM daily_sales 
WHERE sale_date = '2025-01-16';

-- Query for specific date
SELECT * FROM sales 
WHERE sale_date = '2025-01-15';

-- Snowflake's optimizer:
-- 1. Reads partition metadata (min/max values per partition)
-- 2. Identifies only partitions containing 2025-01-15
-- 3. Scans only those partitions, skipping all others
-- This is "partition pruning" - happens automatically
```

**Interview insight**: Compare to Redshift where you must explicitly define sort keys and distribution keys. In Snowflake, much of this is automatic, but you can enhance with clustering keys for very large tables.

---

## 2. Virtual Warehouses & Compute

### Sizing and Scaling

**Concept**: Virtual warehouses come in T-shirt sizes (X-Small to 6X-Large), each size doubling compute capacity and cost.

| Size | Credits/Hour | Servers | Use Case |
|------|-------------|---------|-----------|
| X-Small | 1 | 1 | Small queries, dev/test |
| Small | 2 | 2 | Light production workloads |
| Medium | 4 | 4 | Standard analytics |
| Large | 8 | 8 | Heavy ETL, large datasets |
| X-Large | 16 | 16 | Very large data processing |
| 2X-Large+ | 32+ | 32+ | Massive parallel processing |

**The Scaling Decision Matrix**:

1. **Scale UP** (resize warehouse):
   - When: Single large query is slow
   - Effect: More compute per query, faster individual queries
   - Cost: 2x compute = 2x cost per hour, but query finishes faster
   
2. **Scale OUT** (multi-cluster):
   - When: Many concurrent queries queuing
   - Effect: More queries run simultaneously
   - Cost: Elastic, only pay for clusters actually running

**Interview scenario**:
*"Our nightly ETL job processes 5TB of data and takes 4 hours on a Medium warehouse. It needs to complete in 2 hours. What do you do?"*

**Analysis approach**:
1. Current: Medium (4 credits/hour) × 4 hours = 16 credits
2. Scale up to Large (8 credits/hour): Likely ~2 hours = 16 credits (same cost!)
3. Scale up to X-Large (16 credits/hour): Likely ~1 hour = 16 credits (still same cost!)

**Answer**: "I'd scale up to Large or X-Large. Since we're CPU-bound on a single job, vertical scaling is more efficient. The total cost remains similar (time × rate = constant for CPU-bound workloads), but we finish faster. I'd test Large first, monitor with `QUERY_HISTORY`, and adjust if needed."

### Auto-Suspend and Auto-Resume

**Concept**: Warehouses can automatically suspend after inactivity and resume on new query.

**Default settings** (usually too aggressive or conservative):
- Auto-suspend: 600 seconds (10 minutes)
- Auto-resume: Enabled

**Best practices by workload**:

**ETL Warehouses**:
```sql
ALTER WAREHOUSE ETL_WH SET 
    AUTO_SUSPEND = 60  -- Suspend after 1 minute
    AUTO_RESUME = TRUE;
```
- Why: ETL jobs are scheduled, not ad-hoc. Suspend quickly between jobs.

**Interactive Analytics**:
```sql
ALTER WAREHOUSE ANALYST_WH SET 
    AUTO_SUSPEND = 600  -- 10 minutes
    AUTO_RESUME = TRUE;
```
- Why: Analysts often run multiple queries in succession. Longer suspend prevents constant start/stop.

**BI Dashboards**:
```sql
ALTER WAREHOUSE DASHBOARD_WH SET 
    AUTO_SUSPEND = 300  -- 5 minutes
    AUTO_RESUME = TRUE;
```
- Why: Dashboards refresh periodically. Medium timeout balances responsiveness with cost.

**Interview question**:
*"We notice our warehouse is starting and stopping constantly during business hours. What's happening?"*

**Answer**: "Likely auto-suspend is too aggressive for the query pattern. When users run queries every 3-5 minutes but auto-suspend is 60 seconds, you get constant cold starts. This wastes the 60-second minimum billing increment and increases query latency. I'd analyze query patterns in `QUERY_HISTORY`, calculate actual idle periods, and adjust auto-suspend to slightly exceed typical gaps between queries. For this pattern, 5-10 minutes is probably optimal."

### Multi-Cluster Warehouses

**Concept**: Automatically scale out to handle concurrent query loads.

**Configuration**:
```sql
CREATE WAREHOUSE ANALYST_WH WITH
    WAREHOUSE_SIZE = 'MEDIUM'
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 5
    SCALING_POLICY = 'STANDARD'  -- or 'ECONOMY'
    AUTO_SUSPEND = 600
    AUTO_RESUME = TRUE;
```

**Scaling Policies**:

1. **STANDARD** (favor performance):
   - Starts additional cluster as soon as queuing detected
   - Keeps clusters running for at least 2-3 queries
   - Best for: Interactive, user-facing workloads

2. **ECONOMY** (favor cost):
   - Waits ~6 minutes before adding cluster (allows queue to build)
   - Aggressively shuts down clusters when idle
   - Best for: Batch workloads, less time-sensitive queries

**Real scenario**:
*"We have 50 analysts running queries from 9 AM to 5 PM. Query times are acceptable at off-peak but terrible during lunch hour rush."*

**Solution**:
```sql
-- Multi-cluster with time-based adjustment
CREATE WAREHOUSE ANALYST_WH WITH
    WAREHOUSE_SIZE = 'MEDIUM'
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 8
    SCALING_POLICY = 'STANDARD';

-- During peak hours (via scheduled task or resource monitor)
ALTER WAREHOUSE ANALYST_WH SET MIN_CLUSTER_COUNT = 3;

-- After hours
ALTER WAREHOUSE ANALYST_WH SET MIN_CLUSTER_COUNT = 1;
```

**Monitoring approach**:
```sql
-- Check warehouse load
SELECT 
    start_time,
    warehouse_name,
    AVG(execution_time)/1000 as avg_seconds,
    AVG(queued_time)/1000 as avg_queue_seconds,
    COUNT(*) as query_count
FROM snowflake.account_usage.query_history
WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
    AND warehouse_name = 'ANALYST_WH'
GROUP BY 1, 2
ORDER BY 1;
```

---

## 3. Storage & Data Organization

### Clustering Keys

**Concept**: While Snowflake auto-clusters data, you can define explicit clustering keys for very large tables (multi-TB) to improve pruning.

**When to use clustering keys**:
1. Table > 1TB
2. Queries filter on specific columns
3. Query performance is unacceptable despite proper warehousing
4. Table has poor natural clustering (random inserts/updates)

**When NOT to use**:
- Small tables (< 100GB) - overhead exceeds benefit
- Columns with very high cardinality (e.g., unique IDs)
- Frequently updated tables - constant re-clustering cost

**Example scenario**:
*"We have a 10TB events table. Queries always filter by `event_date` and `user_country`. Scans are still expensive."*

```sql
-- Check current clustering depth (lower is better)
SELECT SYSTEM$CLUSTERING_INFORMATION('events', '(event_date, user_country)');

-- Result shows poor clustering (high average_depth)
-- Add clustering key
ALTER TABLE events CLUSTER BY (event_date, user_country);

-- Snowflake automatically re-clusters in background
-- Monitor progress
SELECT SYSTEM$CLUSTERING_INFORMATION('events', '(event_date, user_country)');
```

**Cost consideration**:
- Re-clustering consumes Snowflake credits
- Monitor using `AUTOMATIC_CLUSTERING_HISTORY`
```sql
SELECT 
    start_time,
    table_name,
    credits_used,
    bytes_reclustered
FROM snowflake.account_usage.automatic_clustering_history
WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY credits_used DESC;
```

**Interview insight**: "Clustering is powerful but has ongoing cost. I'd first validate the query patterns truly warrant it, estimate re-clustering costs, and ensure simpler optimizations (better WHERE clauses, materialized views) aren't sufficient."

### Table Types and Use Cases

#### Permanent Tables
```sql
CREATE TABLE sales (
    sale_id NUMBER,
    sale_date DATE,
    amount DECIMAL(10,2)
);
```
- Default type
- Time Travel enabled (1-90 days, default 1 day)
- Fail-safe enabled (7 days)
- Use for: Production data, anything needing recovery

#### Transient Tables
```sql
CREATE TRANSIENT TABLE staging_sales (
    sale_id NUMBER,
    sale_date DATE,
    amount DECIMAL(10,2)
);
```
- Time Travel enabled (0-1 days, default 1 day)
- NO Fail-safe
- Lower storage costs (~50% less)
- Use for: Staging data, intermediate transformations, non-critical data

#### Temporary Tables
```sql
CREATE TEMPORARY TABLE session_temp (
    user_id NUMBER,
    calculation DECIMAL(10,2)
);
```
- Exists only for session duration
- No Time Travel
- No Fail-safe
- Automatically dropped when session ends
- Use for: ETL intermediate steps, one-time calculations, session-specific data

#### External Tables
```sql
CREATE EXTERNAL TABLE external_sales
WITH LOCATION = @my_s3_stage/sales/
FILE_FORMAT = (TYPE = PARQUET)
PATTERN = '.*[.]parquet';
```
- Data stays in external storage (S3, Azure, GCS)
- Snowflake stores only metadata
- Use for: Data lake integration, avoiding data duplication, cost optimization

**Decision matrix**:

| Need | Permanent | Transient | Temporary | External |
|------|-----------|-----------|-----------|----------|
| Production data | ✓ | | | |
| Staging/ETL | | ✓ | ✓ | |
| Session work | | | ✓ | |
| Data lake query | | | | ✓ |
| Time Travel needed | ✓ | Limited | | |
| Fail-safe needed | ✓ | | | |
| Minimize storage cost | | ✓ | ✓ | ✓ |

### Data Types and Storage Optimization

**Key principle**: Choose the smallest data type that fits your data.

**Common mistakes**:
```sql
-- BAD: Wastes storage
CREATE TABLE users (
    user_id NUMBER(38,0),        -- Default, way too large for most IDs
    email VARCHAR(16777216),     -- Default, excessive
    age NUMBER(38,0),            -- 38 digits for age?
    is_active VARCHAR(16777216)  -- String for boolean?
);

-- GOOD: Right-sized types
CREATE TABLE users (
    user_id NUMBER(12,0),        -- Handles up to 999 billion
    email VARCHAR(255),          -- Reasonable max email length
    age NUMBER(3,0),             -- 0-999
    is_active BOOLEAN            -- Native boolean type
);
```

**Storage impact**:
- `NUMBER(38,0)` uses up to 16 bytes
- `NUMBER(12,0)` uses up to 8 bytes
- Over millions of rows, this compounds

**Interview tip**: "While Snowflake compresses well, right-sizing data types improves compression ratios, reduces I/O, and lowers costs. It also serves as implicit documentation and validation."

---

## 4. Query Performance & Optimization

### Understanding Query Profiles

**Concept**: Query Profile is Snowflake's visual explain plan that shows actual execution statistics.

**Key metrics to analyze**:

1. **Partitions Scanned vs. Total**
   ```
   Partitions scanned: 15 of 10,000
   ```
   - Good: Efficient pruning
   - Bad: Scanning most partitions suggests poor filtering or missing clustering

2. **Bytes Spilled to Local/Remote Storage**
   ```
   Bytes spilled to local disk: 5.2 GB
   ```
   - Indicates warehouse too small for query
   - Solution: Scale up warehouse or optimize query

3. **Query Compilation Time**
   ```
   Compilation: 2.5s, Execution: 0.3s
   ```
   - High compilation vs execution suggests complex query
   - Consider simplifying or breaking into steps

**Real debugging scenario**:

*"Query takes 5 minutes but only scans 100MB of data. What's wrong?"*

**Investigation steps**:
```sql
-- Get query ID from history
SELECT query_id, query_text, execution_time, bytes_scanned
FROM snowflake.account_usage.query_history
WHERE query_text ILIKE '%my_slow_query%'
ORDER BY start_time DESC
LIMIT 5;

-- Examine in UI: Query Profile
-- Look for:
-- 1. "Bytes spilled" - warehouse too small
-- 2. "Join explosion" - cartesian product
-- 3. "Sequential operations" - lack of parallelism
```

### Pruning Strategies

**Concept**: Making Snowflake scan fewer micro-partitions.

**1. Predicate Pushdown**
```sql
-- BAD: Filters after join
SELECT o.order_id, c.customer_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= '2025-01-01';

-- BETTER: Filter pushed down
SELECT o.order_id, c.customer_name
FROM (
    SELECT * FROM orders 
    WHERE order_date >= '2025-01-01'
) o
JOIN customers c ON o.customer_id = c.customer_id;

-- Actually, Snowflake's optimizer does this automatically
-- But be explicit with complex queries or views
```

**2. Partition Pruning via WHERE**
```sql
-- Excellent pruning (assuming date clustering)
SELECT * FROM events
WHERE event_date BETWEEN '2025-01-01' AND '2025-01-31'
  AND user_country = 'US';

-- Poor pruning (function on column prevents pruning)
SELECT * FROM events
WHERE YEAR(event_date) = 2025
  AND MONTH(event_date) = 1;

-- Fixed: Use range instead
SELECT * FROM events
WHERE event_date >= '2025-01-01' 
  AND event_date < '2025-02-01';
```

**Interview question**:
*"How do you optimize a query that's scanning too many partitions?"*

**Answer framework**:
1. Analyze Query Profile: Identify partition scan ratio
2. Check WHERE clauses: Ensure filters on clustered columns
3. Avoid functions on filtered columns (breaks pruning)
4. Consider materialized views for complex aggregations
5. For multi-TB tables, evaluate clustering keys
6. Use `SEARCH OPTIMIZATION SERVICE` for point lookups

### Result Set Caching

**Concept**: Snowflake caches query results for 24 hours if the underlying data hasn't changed.

**When it works**:
- Exact same SQL query (byte-for-byte match)
- No data changes in queried tables
- No time-dependent functions (CURRENT_TIMESTAMP, CURRENT_DATE)

**Example**:
```sql
-- First execution: Scans data, takes 30s
SELECT region, SUM(sales) 
FROM sales_history
WHERE year = 2024
GROUP BY region;

-- Second execution (within 24 hours): Instant, from cache
-- Same exact query by same or different user

-- This does NOT use cache (different query):
SELECT region, SUM(sales) 
FROM sales_history
WHERE year = 2024
GROUP BY 1;  -- GROUP BY position vs column name
```

**Practical use**:
```sql
-- Dashboard queries that don't need real-time data
-- Add comment to prevent cache (for testing):
SELECT /* NO_CACHE */ region, SUM(sales) 
FROM sales_history
WHERE year = 2024
GROUP BY region;
```

### Materialized Views

**Concept**: Pre-computed results automatically maintained by Snowflake.

**When to use**:
- Query is expensive (minutes)
- Query is frequently run
- Underlying data changes infrequently or predictably
- Trade-off: Storage + maintenance compute vs query compute

**Example scenario**:
*"Dashboard queries aggregate 1TB table daily. Each query takes 2 minutes. 50 users access throughout the day."*

```sql
-- Without MV: 50 users × 2 min × multiple times = hours of compute
-- With MV:

CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
    sale_date,
    region,
    product_category,
    SUM(amount) as total_sales,
    COUNT(*) as transaction_count,
    AVG(amount) as avg_sale
FROM sales
GROUP BY sale_date, region, product_category;

-- User queries hit MV (milliseconds):
SELECT * FROM daily_sales_summary
WHERE sale_date >= '2025-01-01';

-- Snowflake automatically refreshes MV when sales table updates
```

**Cost consideration**:
```sql
-- Monitor MV maintenance cost
SELECT 
    table_name,
    SUM(credits_used) as total_credits,
    COUNT(*) as refresh_count
FROM snowflake.account_usage.materialized_view_refresh_history
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1
ORDER BY 2 DESC;
```

**Interview insight**: "Materialized views are excellent for dashboard-type queries with stable aggregations. However, they have ongoing maintenance costs and increase storage. I'd validate that query frequency × query cost exceeds MV maintenance cost before implementing."

---

## 5. Data Loading & Unloading

### Loading Strategies

**Snowpipe (Continuous Loading)**

**Concept**: Event-driven micro-batch loading from cloud storage.

**Use case**: Real-time or near-real-time data ingestion.

```sql
-- Create stage pointing to S3
CREATE STAGE my_s3_stage
    URL = 's3://mybucket/data/'
    CREDENTIALS = (AWS_KEY_ID = 'xxx' AWS_SECRET_KEY = 'yyy');

-- Create pipe with auto-ingest
CREATE PIPE my_pipe 
    AUTO_INGEST = TRUE
    AS 
    COPY INTO my_table
    FROM @my_s3_stage
    FILE_FORMAT = (TYPE = 'JSON');

-- S3 event notification triggers pipe when new files arrive
-- Snowpipe loads data within minutes (typically < 1 minute)
```

**Key characteristics**:
- Uses serverless compute (Snowflake-managed)
- Charges per-file overhead + compute
- Best for files > 100MB for cost efficiency
- Automatically handles failures and retries

**Cost optimization**:
```sql
-- Monitor Snowpipe usage
SELECT 
    pipe_name,
    SUM(credits_used) as total_credits,
    SUM(files_inserted) as total_files,
    SUM(credits_used)/SUM(files_inserted) as credits_per_file
FROM snowflake.account_usage.pipe_usage_history
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1
ORDER BY 2 DESC;

-- If credits_per_file is high: Files too small, combine before loading
```

**Bulk Loading (COPY INTO)**

**Use case**: Batch loading, scheduled ETL, historical data loads.

```sql
-- Load from stage with pattern matching
COPY INTO orders
FROM @my_stage/orders/
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"')
PATTERN = '.*orders_[0-9]{8}\.csv'
ON_ERROR = 'CONTINUE'  -- Skip bad records
VALIDATION_MODE = 'RETURN_ERRORS';  -- Test before actual load

-- Load Parquet (most efficient)
COPY INTO events
FROM @my_stage/events/
FILE_FORMAT = (TYPE = 'PARQUET')
MATCH_BY_COLUMN_NAME = 'CASE_INSENSITIVE';
```

**Best practices**:

1. **File size**: 100-250MB compressed optimal
   - Too small: Overhead dominates
   - Too large: Reduces parallelism

2. **File format**: Parquet > ORC > JSON > CSV
   - Parquet: Columnar, compressed, typed → 10x faster than CSV
   - Avoid CSV if possible

3. **Error handling**:
```sql
-- Check for errors after load
SELECT * FROM TABLE(VALIDATE(orders, JOB_ID => '_last'));

-- Load with size limits
COPY INTO orders
FROM @my_stage
FILE_FORMAT = (TYPE = 'CSV')
SIZE_LIMIT = 10485760  -- 10MB per statement (for testing)
ON_ERROR = 'ABORT_STATEMENT';
```

**Interview scenario**:
*"We receive 10,000 small JSON files (1-5MB each) per hour. Loading is slow and expensive. What do you recommend?"*

**Answer**: 
"The issue is file overhead. With 10,000 files, you're paying significant per-file processing cost. Solutions:
1. **Upstream**: Combine files before landing in S3 (e.g., AWS Kinesis Firehose buffering)
2. **Intermediate**: Use AWS Lambda to concatenate files into 100-250MB batches
3. **Format**: Convert JSON to Parquet using AWS Glue or similar
4. **Alternative**: If truly need micro-batching, Snowpipe is designed for this, but I'd still try to get files to 10-100MB range

Expected improvement: 10-50x reduction in load time and cost."

### Unloading Data (COPY INTO)

**Use case**: Export data to S3/Azure/GCS for downstream processing or archival.

```sql
-- Unload to Parquet (most efficient)
COPY INTO @my_stage/exports/sales_
FROM (
    SELECT * FROM sales 
    WHERE sale_date >= '2024-01-01'
)
FILE_FORMAT = (TYPE = 'PARQUET' COMPRESSION = 'SNAPPY')
MAX_FILE_SIZE = 268435456  -- 256MB per file
HEADER = TRUE
OVERWRITE = TRUE;

-- Unload partitioned by column
COPY INTO @my_stage/exports/sales/year=2024/month=01/
FROM (
    SELECT * FROM sales 
    WHERE year = 2024 AND month = 1
)
FILE_FORMAT = (TYPE = 'PARQUET')
PARTITION BY (year, month);
```

**Real scenario**: *"We need to export 5TB to S3 for ML model training. How do you optimize this?"*

```sql
-- Use large warehouse for parallelism
USE WAREHOUSE LARGE_WH;

-- Partition exports for parallel processing
COPY INTO @my_stage/ml_training/partition_
FROM (
    SELECT 
        *,
        MOD(feature_id, 100) as partition_id  -- 100 partitions
    FROM ml_features
)
FILE_FORMAT = (TYPE = 'PARQUET' COMPRESSION = 'SNAPPY')
PARTITION BY (partition_id)
MAX_FILE_SIZE = 268435456;  -- 256MB files

-- Result: ~200 files × 256MB = optimal for distributed ML training
```

---

## 6. Security & Governance

### Role-Based Access Control (RBAC)

**Concept**: Snowflake uses roles (not users) for permissions. Users assume roles.

**Role hierarchy example**:
```
ACCOUNTADMIN (top-level, avoid using)
    └── SECURITYADMIN (manages users, roles)
        └── SYSADMIN (manages warehouses, databases)
            └── Custom roles (specific permissions)
                └── PUBLIC (all users inherit)
```

**Best practice setup**:
```sql
-- Create functional roles
CREATE ROLE DATA_ENGINEER;
CREATE ROLE DATA_ANALYST;
CREATE ROLE DATA_SCIENTIST;

-- Grant to SYSADMIN (for management)
GRANT ROLE DATA_ENGINEER TO ROLE SYSADMIN;
GRANT ROLE DATA_ANALYST TO ROLE SYSADMIN;

-- Grant database privileges
GRANT USAGE ON DATABASE analytics TO ROLE DATA_ANALYST;
GRANT USAGE ON SCHEMA analytics.core TO ROLE DATA_ANALYST;
GRANT SELECT ON ALL TABLES IN SCHEMA analytics.core TO ROLE DATA_ANALYST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA analytics.core TO ROLE DATA_ANALYST;

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE ANALYST_WH TO ROLE DATA_ANALYST;

-- Grant role to users
GRANT ROLE DATA_ANALYST TO USER john_smith;

-- Set default role
ALTER USER john_smith SET DEFAULT_ROLE = DATA_ANALYST;
```

**Real scenario**: 
*"We have analysts who should only see aggregated data, not PII. How do you implement this?"*

**Solution using Secure Views**:
```sql
-- Raw table (restricted)
CREATE TABLE customer_transactions (
    customer_id NUMBER,
    email VARCHAR,
    ssn VARCHAR,
    transaction_amount DECIMAL(10,2),
    transaction_date DATE
);

GRANT SELECT ON customer_transactions TO ROLE DATA_ENGINEER;

-- Create secure view (hides PII)
CREATE SECURE VIEW customer_transaction_summary AS
SELECT 
    DATE_TRUNC('month', transaction_date) as month,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(transaction_amount) as total_amount,
    AVG(transaction_amount) as avg_amount
FROM customer_transactions
GROUP BY 1;

-- Grant to analysts
GRANT SELECT ON customer_transaction_summary TO ROLE DATA_ANALYST;

-- Analysts see aggregates, never PII
-- "Secure" prevents view definition inspection
```

### Row-Level Security (Secure UDFs/Policies)

**Concept**: Control which rows users see based on their role.

**Example**: Multi-tenant SaaS where each customer sees only their data.

```sql
-- Create mapping table
CREATE TABLE user_company_mapping (
    username VARCHAR,
    company_id NUMBER
);

-- Create secure UDF for current user's companies
CREATE SECURE FUNCTION current_user_companies()
RETURNS TABLE (company_id NUMBER)
AS
$$
    SELECT company_id 
    FROM user_company_mapping 
    WHERE username = CURRENT_USER()
$$;

-- Create row access policy
CREATE ROW ACCESS POLICY company_isolation AS (company_id NUMBER) 
RETURNS BOOLEAN ->
    company_id IN (SELECT company_id FROM TABLE(current_user_companies()))
    OR CURRENT_ROLE() = 'ACCOUNTADMIN';

-- Apply policy to table
ALTER TABLE transactions 
    ADD ROW ACCESS POLICY company_isolation ON (company_id);

-- Now, when users query:
SELECT * FROM transactions;
-- They automatically see only their company's data
-- Transparent to application code
```

**Interview tip**: "Row-level security keeps application code simple - no need for WHERE clauses in every query. The database enforces access at the lowest level."

### Column-Level Security (Dynamic Data Masking)

**Use case**: Show/hide sensitive columns based on role.

```sql
-- Create masking policy
CREATE MASKING POLICY email_mask AS (val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('DATA_ENGINEER', 'ACCOUNTADMIN') 
            THEN val
        WHEN CURRENT_ROLE() IN ('DATA_ANALYST') 
            THEN REGEXP_REPLACE(val, '^(.{2}).*(@.*)$', '\1****\2')  -- jo****@example.com
        ELSE '***MASKED***'
    END;

-- Apply to column
ALTER TABLE customers 
    MODIFY COLUMN email 
    SET MASKING POLICY email_mask;

-- Different roles see different outputs:
-- DATA_ENGINEER: john.smith@example.com
-- DATA_ANALYST: jo****@example.com
-- Others: ***MASKED***
```

**Practical scenario**:
*"GDPR requires we protect EU customer data. How do you implement this in Snowflake?"*

```sql
-- Tag-based masking for GDPR
CREATE TAG gdpr_protected;

-- Tag columns containing personal data
ALTER TABLE customers 
    MODIFY COLUMN email SET TAG gdpr_protected = 'email',
    MODIFY COLUMN phone SET TAG gdpr_protected = 'phone',
    MODIFY COLUMN address SET TAG gdpr_protected = 'address';

-- Create masking policy
CREATE MASKING POLICY gdpr_mask AS (val STRING) RETURNS STRING ->
    CASE
        WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('gdpr_protected') IS NOT NULL
            AND CURRENT_ROLE() NOT IN ('PRIVACY_OFFICER', 'ACCOUNTADMIN')
            THEN '***PROTECTED***'
        ELSE val
    END;

-- Apply to all tagged columns
ALTER TABLE customers 
    MODIFY COLUMN email SET MASKING POLICY gdpr_mask,
    MODIFY COLUMN phone SET MASKING POLICY gdpr_mask,
    MODIFY COLUMN address SET MASKING POLICY gdpr_mask;
```

---

## 7. Data Sharing & Collaboration

### Secure Data Sharing

**Concept**: Share live data with other Snowflake accounts without copying data or using ETL.

**Key insight**: Shared data is read-only for consumers, no data movement, query performance on consumer's compute.

**Provider setup**:
```sql
-- Create share
CREATE SHARE sales_data_share;

-- Grant database access
GRANT USAGE ON DATABASE sales TO SHARE sales_data_share;
GRANT USAGE ON SCHEMA sales.public TO SHARE sales_data_share;

-- Grant table access (with secure view for row filtering)
CREATE SECURE VIEW shared_sales AS
SELECT * FROM sales.public.transactions
WHERE is_shareable = TRUE;  -- Filter sensitive data

GRANT SELECT ON sales.public.shared_sales TO SHARE sales_data_share;

-- Add consumer accounts
ALTER SHARE sales_data_share 
    ADD ACCOUNTS = xyz12345, abc67890;
```

**Consumer setup**:
```sql
-- See available shares
SHOW SHARES;

-- Create database from share
CREATE DATABASE external_sales_data 
    FROM SHARE provider_account.sales_data_share;

-- Query shared data
SELECT * FROM external_sales_data.public.shared_sales;
-- Uses consumer's warehouse, provider pays no compute
```

**Real-world scenario**:
*"We sell data products to 100 customers. Each needs their own subset. How do you scale this?"*

**Solution using Secure Views + UDFs**:
```sql
-- Mapping table (provider maintains)
CREATE TABLE customer_data_access (
    consumer_account VARCHAR,
    allowed_categories ARRAY,
    allowed_regions ARRAY
);

-- Secure function to get consumer's allowed filters
CREATE SECURE FUNCTION get_consumer_filters()
RETURNS TABLE (categories ARRAY, regions ARRAY)
AS
$$
    SELECT allowed_categories, allowed_regions
    FROM customer_data_access
    WHERE consumer_account = CURRENT_ACCOUNT()
$$;

-- Shared view with dynamic filtering
CREATE SECURE VIEW shared_product_data AS
SELECT p.*
FROM products p
CROSS JOIN TABLE(get_consumer_filters()) f
WHERE ARRAY_CONTAINS(p.category::VARIANT, f.categories)
  AND ARRAY_CONTAINS(p.region::VARIANT, f.regions);

-- Grant to share
GRANT SELECT ON shared_product_data TO SHARE product_data_share;

-- Each consumer automatically sees only their entitled data
-- Single share serves all customers
```

**Cost model**:
- Provider: Storage only (customers see same physical data)
- Consumer: Compute only (runs queries on own warehouse)
- No data transfer costs within same cloud region

---

## 8. Snowflake + dbt Integration

### Why Snowflake + dbt is Powerful

**Key synergies**:
1. **Separate compute layers**: dbt runs transformations on dedicated warehouse
2. **Automatic incremental models**: dbt's merge strategies leverage Snowflake's MERGE efficiency
3. **Zero-copy cloning**: Test/dev environments without data duplication
4. **Query tags**: Track dbt run costs and performance

### dbt Configuration for Snowflake

**profiles.yml**:
```yaml
snowflake_prod:
  target: prod
  outputs:
    prod:
      type: snowflake
      account: xy12345.us-east-1
      user: dbt_user
      role: DBT_TRANSFORMER
      warehouse: DBT_WH
      database: ANALYTICS
      schema: CORE
      threads: 8  # Parallel model execution
      
      # Query tag for tracking
      query_tag: dbt_run_prod
      
      # Connection parameters
      client_session_keep_alive: true
      
    dev:
      type: snowflake
      account: xy12345.us-east-1
      user: "{{ env_var('SNOWFLAKE_USER') }}"
      warehouse: DBT_DEV_WH
      database: ANALYTICS_DEV
      schema: "{{ env_var('USER') }}_dev"
      threads: 4
```

### Incremental Models Best Practices

**Scenario**: Daily sales data, need to update only new/changed records.

```sql
-- models/sales_daily.sql
{{
    config(
        materialized='incremental',
        unique_key='sale_id',
        on_schema_change='sync_all_columns',
        
        -- Snowflake-specific optimizations
        cluster_by=['sale_date'],
        
        -- Incremental strategy
        incremental_strategy='merge',  -- Use Snowflake MERGE
        
        -- Performance: pre-hook to analyze
        pre_hook="ALTER SESSION SET USE_CACHED_RESULT = FALSE"
    )
}}

WITH source_data AS (
    SELECT
        sale_id,
        customer_id,
        sale_date,
        amount,
        updated_at
    FROM {{ source('raw', 'sales') }}
    
    {% if is_incremental() %}
        -- Only process new or updated records
        WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
    {% endif %}
)

SELECT
    sale_id,
    customer_id,
    sale_date,
    amount,
    updated_at
FROM source_data
```

**Generated SQL** (incremental run):
```sql
MERGE INTO analytics.core.sales_daily AS target
USING (
    -- New/updated records
    SELECT * FROM temp_view
) AS source
ON target.sale_id = source.sale_id
WHEN MATCHED THEN UPDATE SET
    target.customer_id = source.customer_id,
    target.sale_date = source.sale_date,
    target.amount = source.amount,
    target.updated_at = source.updated_at
WHEN NOT MATCHED THEN INSERT
    (sale_id, customer_id, sale_date, amount, updated_at)
    VALUES
    (source.sale_id, source.customer_id, source.sale_date, 
     source.amount, source.updated_at);
```

### Snapshot Strategy for Slowly Changing Dimensions

**Use case**: Track historical changes to customer records.

```sql
-- snapshots/customers_snapshot.sql
{% snapshot customers_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='updated_at',
        
        -- Snowflake optimizations
        cluster_by=['dbt_valid_from']
    )
}}

SELECT * FROM {{ source('raw', 'customers') }}

{% endsnapshot %}
```

**Result**: Type-2 SCD table with `dbt_valid_from`, `dbt_valid_to`, `dbt_scd_id`.

### Testing and Documentation

```yaml
# models/schema.yml
version: 2

models:
  - name: sales_daily
    description: "Daily sales transactions with customer information"
    
    # dbt tests
    tests:
      - dbt_utils.recency:
          datepart: day
          field: sale_date
          interval: 1  # Data should be fresh within 1 day
    
    columns:
      - name: sale_id
        description: "Unique sale identifier"
        tests:
          - unique
          - not_null
      
      - name: amount
        description: "Sale amount in USD"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1000000
      
      - name: sale_date
        description: "Date of sale"
        tests:
          - not_null
```

### Monitoring dbt Runs in Snowflake

```sql
-- Track dbt run costs
SELECT 
    query_tag,
    DATE_TRUNC('day', start_time) as run_date,
    COUNT(*) as query_count,
    SUM(execution_time)/1000/60 as total_minutes,
    SUM(bytes_scanned)/1024/1024/1024 as gb_scanned,
    warehouse_name
FROM snowflake.account_usage.query_history
WHERE query_tag LIKE '%dbt%'
    AND start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1, 2, 6
ORDER BY 2 DESC, 4 DESC;

-- Identify slow models
SELECT 
    REGEXP_SUBSTR(query_text, 'FROM\\s+(\\w+\\.\\w+\\.\\w+)', 1, 1, 'i', 1) as model_name,
    AVG(execution_time)/1000 as avg_seconds,
    MAX(execution_time)/1000 as max_seconds,
    COUNT(*) as run_count
FROM snowflake.account_usage.query_history
WHERE query_tag LIKE '%dbt%'
    AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY 2 DESC
LIMIT 20;
```

---

## 9. Cost Optimization Strategies

### Warehouse Right-Sizing

**Method**: Analyze actual usage vs capacity.

```sql
-- Identify underutilized warehouses
SELECT 
    warehouse_name,
    AVG(avg_running) as avg_concurrent_queries,
    MAX(avg_running) as peak_concurrent_queries,
    warehouse_size,
    CASE 
        WHEN MAX(avg_running) < 2 AND warehouse_size NOT IN ('XSMALL', 'SMALL')
            THEN 'Consider downsizing'
        WHEN AVG(avg_queued_load) > 5
            THEN 'Consider upsizing or multi-cluster'
        ELSE 'Right-sized'
    END as recommendation
FROM snowflake.account_usage.warehouse_load_history
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1, 3
ORDER BY 1;
```

### Storage Optimization

**Time Travel retention tuning**:
```sql
-- Audit Time Travel settings
SELECT 
    table_schema,
    table_name,
    table_type,
    retention_time,
    row_count,
    bytes / (1024*1024*1024) as size_gb,
    (bytes / (1024*1024*1024)) * (retention_time / 90) as estimated_time_travel_gb
FROM snowflake.account_usage.tables
WHERE deleted IS NULL
    AND table_type IN ('BASE TABLE', 'TRANSIENT')
ORDER BY 7 DESC;

-- Reduce retention for non-critical tables
ALTER TABLE staging_data SET DATA_RETENTION_TIME_IN_DAYS = 1;
ALTER TABLE temp_calculations SET DATA_RETENTION_TIME_IN_DAYS = 0;
```

**Zero-copy cloning for dev/test**:
```sql
-- Instead of duplicating data
CREATE DATABASE analytics_dev CLONE analytics;

-- Instant clone, no storage duplication initially
-- Only delta changes consume additional storage
-- Perfect for testing dbt changes
```

### Query Optimization ROI

**Before optimizing, quantify the problem**:
```sql
-- Most expensive queries (good candidates for optimization)
SELECT 
    query_id,
    user_name,
    warehouse_name,
    execution_time/1000/60 as minutes,
    (execution_time/1000/3600) * 
        (CASE warehouse_size
            WHEN 'XSMALL' THEN 1
            WHEN 'SMALL' THEN 2
            WHEN 'MEDIUM' THEN 4
            WHEN 'LARGE' THEN 8
            WHEN 'XLARGE' THEN 16
            ELSE 32
        END) as estimated_credits,
    LEFT(query_text, 100) as query_preview
FROM snowflake.account_usage.query_history
WHERE start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
    AND execution_status = 'SUCCESS'
ORDER BY 5 DESC
LIMIT 50;
```

**ROI calculation**:
- If query costs 10 credits, runs daily: 10 × 365 = 3,650 credits/year
- Optimization reduces to 2 credits: Save 2,920 credits/year
- At $2/credit: $5,840 annual savings
- Hours invested in optimization: 4 hours
- ROI: $5,840 / (4 hours × $150/hour) = 973%

### Automated Cost Controls

**Resource Monitors**:
```sql
-- Create account-level monitor (prevent runaway costs)
CREATE RESOURCE MONITOR account_monthly_limit WITH 
    CREDIT_QUOTA = 10000  -- Monthly credit limit
    FREQUENCY = MONTHLY
    START_TIMESTAMP = IMMEDIATELY
    TRIGGERS 
        ON 75 PERCENT DO NOTIFY  -- Alert at 75%
        ON 90 PERCENT DO SUSPEND_IMMEDIATE  -- Stop all warehouses at 90%
        ON 100 PERCENT DO SUSPEND_IMMEDIATE;

-- Apply to account
ALTER ACCOUNT SET RESOURCE_MONITOR = account_monthly_limit;

-- Per-warehouse limits
CREATE RESOURCE MONITOR etl_daily_limit WITH 
    CREDIT_QUOTA = 100
    FREQUENCY = DAILY
    START_TIMESTAMP = IMMEDIATELY
    TRIGGERS 
        ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE ETL_WH SET RESOURCE_MONITOR = etl_daily_limit;
```

---

## 10. Time Travel, Fail-Safe, and Data Recovery

### Time Travel

**Concept**: Query/restore table data from any point in the retention period.

**Use cases**:
1. Accidental DELETE/UPDATE recovery
2. Audit/compliance queries
3. Compare data at different timestamps

**Retention by table type**:
- Permanent: 0-90 days (default 1)
- Transient: 0-1 days (default 1)
- Temporary: 0-1 days (default 1)

**Querying historical data**:
```sql
-- Query table as of 1 hour ago
SELECT * FROM sales AT(OFFSET => -3600);

-- Query table as of specific timestamp
SELECT * FROM sales AT(TIMESTAMP => '2025-01-15 14:30:00'::TIMESTAMP);

-- Query table before specific statement
SELECT * FROM sales BEFORE(STATEMENT => '01a4e5f6-0000-1234-0000-0000000001');
```

**Recovery scenarios**:

**1. Accidental DELETE**:
```sql
-- Disaster strikes
DELETE FROM sales WHERE 1=1;  -- Oops, deleted everything

-- Immediate recovery
CREATE TABLE sales_recovered CLONE sales AT(OFFSET => -60);
-- Recovers data from 60 seconds ago

-- Or restore in place
CREATE OR REPLACE TABLE sales AS 
SELECT * FROM sales AT(OFFSET => -60);
```

**2. Bad UPDATE**:
```sql
-- Before bad update
SELECT COUNT(*), AVG(amount) FROM sales;
-- 1,000,000 rows, avg $150

-- Bad update
UPDATE sales SET amount = amount * 10;  -- Mistake!

-- After bad update
SELECT COUNT(*), AVG(amount) FROM sales;
-- 1,000,000 rows, avg $1,500 - Wrong!

-- Rollback
CREATE OR REPLACE TABLE sales AS
SELECT * FROM sales BEFORE(STATEMENT => '01a4e5f6-...');
-- Replace with query ID of the bad UPDATE
```

**3. Table comparison**:
```sql
-- What changed in the last 24 hours?
SELECT 
    current.sale_id,
    current.amount as current_amount,
    historical.amount as yesterday_amount,
    current.amount - historical.amount as change
FROM sales current
FULL OUTER JOIN sales AT(OFFSET => -86400) historical
    ON current.sale_id = historical.sale_id
WHERE current.amount != historical.amount
   OR current.sale_id IS NULL
   OR historical.sale_id IS NULL;
```

**Cost consideration**:
- Time Travel data stored as micro-partition deltas
- Longer retention = higher storage costs
- Set retention based on actual recovery SLA

```sql
-- Production critical: 7 days
ALTER TABLE customer_orders SET DATA_RETENTION_TIME_IN_DAYS = 7;

-- Staging/temp: 0-1 days
ALTER TABLE staging_data SET DATA_RETENTION_TIME_IN_DAYS = 1;
```

### Fail-Safe

**Concept**: 7-day recovery period after Time Travel retention expires (permanent tables only).

**Key differences from Time Travel**:
- Not user-accessible (requires Snowflake Support)
- Disaster recovery only (not for accidental deletes)
- Additional cost included in storage
- Cannot be queried or cloned

**When it matters**:
```
Day 0: Table created
Day 1-90: Time Travel available (if retention = 90)
Day 91-97: Fail-safe only (Snowflake Support required)
Day 98+: Data permanently deleted
```

**Real scenario**:
*"Developer accidentally dropped production table 3 days ago. Time Travel retention is 1 day. Is data recoverable?"*

**Answer**: "Yes, via Fail-safe. The table is still recoverable for another 4 days through Snowflake Support. I'd immediately open a high-priority support ticket with:
- Table name and database
- Approximate drop timestamp
- Business justification for recovery

Important: Fail-safe recovery is manual and may take time. This is why production tables should have longer Time Travel retention (7-14 days) to avoid depending on Fail-safe."

### Undrop

**Concept**: Restore dropped databases, schemas, and tables.

```sql
-- Drop table accidentally
DROP TABLE important_data;

-- Restore it
UNDROP TABLE important_data;

-- Works for databases and schemas too
UNDROP DATABASE production;
UNDROP SCHEMA analytics.core;
```

**Limitations**:
- Must be within Time Travel retention period
- If a new object with same name exists, must rename first
```sql
-- New table created with same name
CREATE TABLE important_data (...);

-- Can't undrop directly, rename first
ALTER TABLE important_data RENAME TO important_data_new;
UNDROP TABLE important_data;
```

---

## 11. Advanced Topics & Real-World Scenarios

### Handling Large-Scale Data Migration

**Scenario**: Migrating 100TB from Redshift to Snowflake.

**Approach**:

**Phase 1: Setup and validation**
```sql
-- Create target structure in Snowflake
CREATE DATABASE migration_target;
CREATE SCHEMA staging;

-- Create external stage pointing to S3
CREATE STAGE migration_stage
    URL = 's3://migration-bucket/'
    CREDENTIALS = (AWS_KEY_ID = '...' AWS_SECRET_KEY = '...');
```

**Phase 2: Export from Redshift**
```sql
-- In Redshift, unload to S3 (Parquet for efficiency)
UNLOAD ('SELECT * FROM large_table')
TO 's3://migration-bucket/large_table/'
IAM_ROLE 'arn:aws:iam::...'
FORMAT AS PARQUET
PARALLEL ON
MAXFILESIZE 256 MB;
```

**Phase 3: Load to Snowflake**
```sql
-- Use large warehouse for parallel loading
CREATE WAREHOUSE MIGRATION_WH WITH
    WAREHOUSE_SIZE = 'XLARGE'
    AUTO_SUSPEND = 60;

USE WAREHOUSE MIGRATION_WH;

-- Load in batches with validation
COPY INTO large_table
FROM @migration_stage/large_table/
FILE_FORMAT = (TYPE = 'PARQUET')
ON_ERROR = 'ABORT_STATEMENT'
VALIDATION_MODE = 'RETURN_ALL_ERRORS';

-- If validation passes, load for real
COPY INTO large_table
FROM @migration_stage/large_table/
FILE_FORMAT = (TYPE = 'PARQUET')
ON_ERROR = 'CONTINUE';
```

**Phase 4: Validation**
```sql
-- Compare row counts
-- Redshift: SELECT COUNT(*) FROM large_table; -- Note the count

-- Snowflake:
SELECT COUNT(*) FROM large_table;  -- Should match

-- Compare aggregates for spot-check
SELECT 
    DATE_TRUNC('month', date_column) as month,
    COUNT(*) as row_count,
    SUM(amount) as total_amount,
    AVG(amount) as avg_amount
FROM large_table
GROUP BY 1
ORDER BY 1;

-- Compare with Redshift results
```

**Phase 5: Performance comparison**
```sql
-- Run typical queries and compare
-- Example: Daily aggregation
SELECT 
    sale_date,
    region,
    SUM(amount) as total_sales
FROM sales
WHERE sale_date >= '2024-01-01'
GROUP BY 1, 2;

-- Time this in both systems
-- Expected: Snowflake 2-10x faster depending on query
```

**Lessons from real migrations**:
1. Use Parquet for 5-10x faster load than CSV
2. 100-250MB files optimal (avoid millions of tiny files)
3. Large warehouse for load, scale down for validation
4. Run parallel loads (multiple tables simultaneously)
5. Keep Redshift running during dual-testing phase
6. Use Time Travel to easily rollback if issues found

### Optimizing for Mixed Workloads

**Scenario**: Same data accessed by:
- Real-time dashboards (need <1s response)
- Nightly ETL (processes millions of rows)
- Ad-hoc analyst queries (variable complexity)
- ML model training (scans entire dataset)

**Solution architecture**:

```sql
-- 1. Separate warehouses by workload type
CREATE WAREHOUSE DASHBOARD_WH WITH
    WAREHOUSE_SIZE = 'SMALL'
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 3
    SCALING_POLICY = 'STANDARD'  -- Quick scale for user experience
    AUTO_SUSPEND = 300;

CREATE WAREHOUSE ETL_WH WITH
    WAREHOUSE_SIZE = 'XLARGE'
    AUTO_SUSPEND = 60;  -- Suspend quickly after job

CREATE WAREHOUSE ANALYST_WH WITH
    WAREHOUSE_SIZE = 'MEDIUM'
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 10
    SCALING_POLICY = 'ECONOMY'  -- Cost-optimized for ad-hoc
    AUTO_SUSPEND = 600;

CREATE WAREHOUSE ML_WH WITH
    WAREHOUSE_SIZE = 'XLARGE'
    AUTO_SUSPEND = 60;

-- 2. Optimize data layout for different access patterns

-- For dashboards: Materialized aggregates
CREATE MATERIALIZED VIEW dashboard_daily_metrics AS
SELECT 
    DATE_TRUNC('day', event_timestamp) as day,
    user_segment,
    COUNT(*) as event_count,
    COUNT(DISTINCT user_id) as unique_users,
    AVG(session_duration) as avg_session_duration
FROM events
GROUP BY 1, 2;

-- Dashboards query MV (milliseconds):
SELECT * FROM dashboard_daily_metrics
WHERE day >= CURRENT_DATE - 30;

-- For ETL: Work on partitioned staging
CREATE TRANSIENT TABLE etl_staging (
    -- columns
) CLUSTER BY (processing_date);

-- For ML: Optimized table with clustering
ALTER TABLE ml_features CLUSTER BY (feature_date);

-- 3. Use search optimization for point lookups (dashboards)
ALTER TABLE user_profiles 
    ADD SEARCH OPTIMIZATION ON EQUALITY(user_id, email);

-- Dashboards with user lookups are now much faster
SELECT * FROM user_profiles WHERE user_id = 12345;
```

### Handling JSON and Semi-Structured Data

**Scenario**: Loading and querying nested JSON events.

```sql
-- Load raw JSON
CREATE TABLE raw_events (
    event_data VARIANT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

COPY INTO raw_events (event_data)
FROM @my_stage/events/
FILE_FORMAT = (TYPE = 'JSON' STRIP_OUTER_ARRAY = TRUE);

-- Query nested structure
SELECT 
    event_data:event_id::STRING as event_id,
    event_data:timestamp::TIMESTAMP as event_timestamp,
    event_data:user.user_id::NUMBER as user_id,
    event_data:user.email::STRING as email,
    event_data:properties.page_url::STRING as page_url,
    event_data:properties.referrer::STRING as referrer
FROM raw_events;

-- Flatten arrays
SELECT 
    event_data:event_id::STRING as event_id,
    f.value:product_id::STRING as product_id,
    f.value:quantity::NUMBER as quantity,
    f.value:price::NUMBER as price
FROM raw_events,
LATERAL FLATTEN(input => event_data:cart_items) f;

-- Optimize: Create structured views for common queries
CREATE VIEW events_structured AS
SELECT 
    event_data:event_id::STRING as event_id,
    event_data:timestamp::TIMESTAMP as event_timestamp,
    event_data:user.user_id::NUMBER as user_id,
    event_data:properties.page_url::STRING as page_url
FROM raw_events;

-- Even better: Materialize for performance
CREATE MATERIALIZED VIEW events_structured_mv AS
SELECT 
    event_data:event_id::STRING as event_id,
    event_data:timestamp::TIMESTAMP as event_timestamp,
    event_data:user.user_id::NUMBER as user_id,
    event_data:properties.page_url::STRING as page_url
FROM raw_events;
```

**Performance tips**:
1. VARIANT columns are efficient but slower than native types
2. For frequently queried paths, create structured views/tables
3. Use :: casting to extract and type
4. Consider extracting complex JSON into relational structure

### Handling Slowly Changing Dimensions (SCD Type 2)

**Scenario**: Customer records change over time, need to track history.

**Manual implementation**:
```sql
CREATE TABLE customer_history (
    customer_id NUMBER,
    customer_name VARCHAR,
    address VARCHAR,
    tier VARCHAR,
    
    -- SCD Type 2 columns
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN,
    
    PRIMARY KEY (customer_id, effective_date)
);

-- Update process (when customer address changes)
-- 1. Close out old record
UPDATE customer_history
SET 
    end_date = CURRENT_DATE(),
    is_current = FALSE
WHERE customer_id = 12345
  AND is_current = TRUE;

-- 2. Insert new record
INSERT INTO customer_history
VALUES (
    12345,
    'John Smith',
    'New Address',
    'Gold',
    CURRENT_DATE(),
    '9999-12-31'::DATE,
    TRUE
);

-- Query current state
SELECT * FROM customer_history
WHERE is_current = TRUE;

-- Query as of specific date
SELECT * FROM customer_history
WHERE customer_id = 12345
  AND effective_date <= '2024-06-01'
  AND end_date > '2024-06-01';
```

**Better: Use dbt snapshot** (see dbt section) or Snowflake Streams + Tasks for automation.

### Implementing Data Quality Checks

**Approach**: Automated testing using Snowflake features.

```sql
-- Create quality check table
CREATE TABLE data_quality_checks (
    check_id NUMBER AUTOINCREMENT,
    check_name VARCHAR,
    table_name VARCHAR,
    check_query VARCHAR,
    severity VARCHAR,  -- 'ERROR', 'WARNING'
    last_run TIMESTAMP,
    last_status VARCHAR,  -- 'PASS', 'FAIL'
    last_result_count NUMBER
);

-- Insert checks
INSERT INTO data_quality_checks 
(check_name, table_name, check_query, severity)
VALUES
('Null customer IDs', 'orders', 
 'SELECT COUNT(*) FROM orders WHERE customer_id IS NULL', 
 'ERROR'),
 
('Negative amounts', 'orders',
 'SELECT COUNT(*) FROM orders WHERE amount < 0',
 'ERROR'),
 
('Future dates', 'orders',
 'SELECT COUNT(*) FROM orders WHERE order_date > CURRENT_DATE()',
 'WARNING');

-- Task to run checks (scheduled)
CREATE TASK run_quality_checks
    WAREHOUSE = QUALITY_CHECK_WH
    SCHEDULE = '60 MINUTE'
AS
DECLARE
    check_result NUMBER;
BEGIN
    FOR check IN (SELECT * FROM data_quality_checks) DO
        EXECUTE IMMEDIATE check.check_query INTO :check_result;
        
        UPDATE data_quality_checks
        SET 
            last_run = CURRENT_TIMESTAMP(),
            last_status = CASE WHEN :check_result = 0 THEN 'PASS' ELSE 'FAIL' END,
            last_result_count = :check_result
        WHERE check_id = check.check_id;
        
        -- Alert on failures (integrate with monitoring)
        IF :check_result > 0 AND check.severity = 'ERROR' THEN
            CALL send_alert(check.check_name, :check_result);
        END IF;
    END FOR;
END;
```

---

## 12. Interview Questions by Category

### Architecture & Core Concepts

**Q1: "Explain how Snowflake's architecture differs from traditional databases."**

**Strong Answer**:
"Snowflake separates compute, storage, and services into three distinct layers. The storage layer uses cloud object storage with automatic compression and micro-partitioning. The compute layer consists of independent virtual warehouses that can scale independently without contention. The services layer manages metadata, query optimization, and security.

This is fundamentally different from traditional databases where compute and storage are tightly coupled. For example, in Oracle or SQL Server, adding compute means adding storage. In Snowflake, you can pause all warehouses and pay only for storage, or run multiple warehouses against the same data simultaneously without any interference.

Compared to Redshift, which you mentioned you know, Snowflake doesn't require you to manage distribution keys or sort keys explicitly. Micro-partitioning and automatic clustering handle much of this. Also, Snowflake's true separation means multiple teams can have isolated warehouses without resource contention, whereas in Redshift, you share the cluster."

**Q2: "What are micro-partitions and why do they matter?"**

**Strong Answer**:
"Micro-partitions are Snowflake's automatic partitioning mechanism. Data is divided into immutable, compressed chunks of roughly 16MB compressed (50-500MB uncompressed). They're created automatically based on ingestion or modification order.

They matter for three reasons:
1. **Partition pruning**: Snowflake maintains min/max metadata for each partition. Queries with filters can skip entire partitions without scanning them.
2. **Immutability**: Makes Time Travel possible without complex WAL logs. Each partition is write-once.
3. **Parallel processing**: Multiple partitions can be scanned in parallel across warehouse nodes.

In practice, if you load data chronologically by date, Snowflake naturally clusters it by date. Queries filtering on date will scan only relevant partitions. For a 1TB table, you might scan only 10GB if filtering on a specific month.

This is similar to Redshift's zone maps but automatic. You don't define it; Snowflake manages it. For very large tables with poor natural clustering, you can add explicit clustering keys, but most tables don't need them."

### Performance & Optimization

**Q3: "A query is slow. Walk me through your troubleshooting process."**

**Strong Answer**:
"I follow a systematic approach:

1. **Get the Query Profile**: Find the query in Snowflake's UI or use QUERY_HISTORY. The Query Profile shows actual execution statistics, not just an explain plan.

2. **Check the basics**:
   - Execution time vs compilation time: High compilation suggests query complexity
   - Warehouse size: Was it appropriate for the workload?
   - Bytes scanned vs bytes returned: High ratio suggests inefficiency

3. **Look for specific bottlenecks**:
   - **Partition pruning**: How many partitions scanned vs total? Poor pruning means filters aren't working or table needs clustering.
   - **Bytes spilled**: Indicates warehouse too small for memory requirements. Scale up.
   - **Join types**: Cartesian products or very unbalanced joins show in profile.

4. **Validate the query logic**:
   - Are there functions on filtered columns preventing pruning? Like `WHERE YEAR(date_col) = 2024` instead of `WHERE date_col >= '2024-01-01'`
   - Are there unnecessary joins or subqueries?
   - Could result set caching help if this runs repeatedly?

5. **Consider alternatives**:
   - Would a materialized view help?
   - Is clustering key beneficial for very large tables?
   - For point lookups, would search optimization service help?

6. **Measure impact**: After changes, compare Query Profiles and validate performance improvement.

I'd also check if this is a one-time query or recurring. Different queries warrant different optimization efforts based on frequency and criticality."

**Q4: "When would you use a materialized view vs a regular view?"**

**Strong Answer**:
"Materialized views make sense when:
1. **Query is expensive**: Base query takes minutes to run
2. **Query is frequent**: Run many times per day
3. **Data changes are predictable**: Underlying data updates in batches, not constantly
4. **Trade-off favors it**: MV maintenance cost < aggregate query cost

For example, a dashboard showing daily sales aggregates:
- Without MV: 50 users × 5 queries each × 2 minutes each = 500 minutes of compute daily
- With MV: Refresh once daily (5 minutes) + user queries (milliseconds each)
- Clear win: 5 minutes vs 500 minutes

I'd avoid materialized views when:
- Base data changes constantly (high refresh cost)
- Query is cheap anyway (< 1 second)
- Storage cost is a concern (MVs duplicate data)
- Query patterns vary widely (MV benefits only specific queries)

Regular views are for:
- Abstraction and access control (hide complexity)
- Real-time data requirements
- Rarely queried data
- Simple transformations

In practice with dbt, I'd use incremental models for frequently updated data and materialized views for relatively static aggregations."

### Data Loading & Integration

**Q5: "Compare Snowpipe vs COPY INTO for data loading. When would you use each?"**

**Strong Answer**:
"COPY INTO is for scheduled batch loads, Snowpipe for continuous, event-driven loading.

**Use COPY INTO when**:
- You have scheduled ETL jobs (e.g., nightly loads)
- You want explicit control over warehouse sizing
- Files arrive in predictable batches
- You're doing initial bulk loads
- Cost optimization is critical (you control warehouse, can use larger warehouse to load faster)

**Use Snowpipe when**:
- Data arrives continuously throughout the day
- You need near-real-time loading (< 1 minute latency)
- Files land unpredictably in S3/Azure/GCS
- You want serverless, hands-off operation
- Willing to pay per-file overhead for convenience

**Example**: IoT sensor data lands in S3 every few minutes throughout the day. Snowpipe with S3 event notifications automatically loads each file within ~1 minute without managing any infrastructure.

**Cost considerations**:
- Snowpipe has per-file overhead. If you're loading 10,000 tiny files, combine them into 100-250MB files first.
- COPY INTO uses your warehouse, so you pay regular compute rates and have full control over speed/cost trade-off.

In my experience, most batch ETL uses COPY INTO, while streaming/near-real-time use cases benefit from Snowpipe. Often, organizations use both for different data sources."

**Q6: "What's the optimal file size for loading, and why?"**

**Strong Answer**:
"The sweet spot is 100-250MB compressed per file. Here's why:

**Too small** (< 10MB):
- Overhead per file dominates (parsing, metadata, validation)
- Reduces parallelism benefits
- Increases Snowpipe costs (charged per file)
- Thousands of files = thousands of metadata operations

**Too large** (> 1GB):
- Reduces parallelism (fewer files = fewer parallel loads)
- Single file errors affect more data
- Longer rollback/retry on failures
- Less efficient memory usage

**Optimal** (100-250MB):
- Maximizes parallelism (each file processed by separate thread)
- Minimizes per-file overhead
- Allows efficient memory management
- Good error isolation (failure affects only one file)

**Practical example**: Loading 10TB of data:
- 1MB files: 10,000,000 files → terrible overhead
- 100MB files: 100,000 files → excellent parallelism
- 5GB files: 2,000 files → poor parallelism

**File format also matters**: Use Parquet or ORC over CSV when possible. Parquet is columnar and compressed, typically 5-10x faster load and better compression than CSV.

In real projects, I've seen load times improve from 6 hours to 30 minutes just by going from 5MB CSVs to 200MB Parquet files."

### Security & Governance

**Q7: "How would you implement multi-tenant data isolation in Snowflake?"**

**Strong Answer**:
"I'd use row-level security with secure UDFs and row access policies. Here's the approach:

1. **Create a mapping table** storing user-to-tenant relationships:
```sql
CREATE TABLE user_tenant_mapping (
    username VARCHAR,
    tenant_id NUMBER
);
```

2. **Create a secure function** to get current user's tenants:
```sql
CREATE SECURE FUNCTION current_user_tenants()
RETURNS TABLE (tenant_id NUMBER)
AS $$
    SELECT tenant_id 
    FROM user_tenant_mapping 
    WHERE username = CURRENT_USER()
$$;
```

3. **Create row access policy**:
```sql
CREATE ROW ACCESS POLICY tenant_isolation 
AS (tenant_id NUMBER) RETURNS BOOLEAN ->
    tenant_id IN (SELECT tenant_id FROM TABLE(current_user_tenants()))
    OR CURRENT_ROLE() = 'SYSADMIN';
```

4. **Apply to tables**:
```sql
ALTER TABLE transactions 
    ADD ROW ACCESS POLICY tenant_isolation ON (tenant_id);
```

**Benefits**:
- Transparent to application code (no WHERE clauses needed)
- Centralized control (change policy once, affects all tables)
- Secure (users can't bypass with SQL tricks)
- Audit-friendly (clear mapping of user to data)

**Alternative for simpler cases**: Separate databases per tenant with Data Sharing. But row-level security is better when:
- Many tenants (hundreds to thousands)
- Shared compute pools are acceptable
- Central schema management preferred

I've implemented both approaches. Row-level security scales better for large tenant counts, while separate databases give better cost isolation and simpler management for < 50 tenants."

**Q8: "Explain Snowflake's data encryption and when you'd use customer-managed keys."**

**Strong Answer**:
"Snowflake encrypts all data automatically:
- **At rest**: AES-256 encryption in cloud storage
- **In transit**: TLS 1.2+ for all connections
- **In memory**: Encryption in warehouse memory
- **Automatic**: No configuration needed

By default, Snowflake manages keys (Tri-Secret Secure):
- Snowflake's root key
- Cloud provider's key
- Account's master key
- Three-layer key hierarchy, no single party has full access

**Customer-managed keys** (CMK) via Bring Your Own Key (BYOK) or AWS/Azure Key Vault integration:

**Use CMK when**:
- Compliance requires it (HIPAA, PCI-DSS, GDPR with specific requirements)
- Need ability to revoke Snowflake's access (e.g., offboarding)
- Audit requirements mandate external key management
- Regulatory bodies require evidence of key control

**Don't use CMK when**:
- Standard compliance is sufficient (Snowflake's default is very secure)
- Want simplest operations (CMK adds operational complexity)
- Cost-sensitive (CMK has additional fees)

**Operational considerations**:
- If you lose/revoke CMK, you lose access to all data
- Adds external dependency (key management service availability)
- Requires additional monitoring

In my experience, most organizations use Snowflake-managed encryption. Only highly regulated industries (healthcare, finance) with specific compliance mandates need CMK. The default encryption is enterprise-grade and simpler to operate."

### Cost Optimization

**Q9: "What strategies would you use to reduce Snowflake costs by 30%?"**

**Strong Answer**:
"I'd take a data-driven approach across multiple areas:

**1. Warehouse right-sizing** (usually 20-40% savings):
```sql
-- Identify underutilized warehouses
SELECT warehouse_name, AVG(avg_running), MAX(avg_running)
FROM warehouse_load_history
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1;
```
- Downsize warehouses with low concurrency
- Adjust auto-suspend timers (too short = constant restarts, too long = idle billing)
- Typical finding: Many Medium warehouses should be Small, saving 50% compute

**2. Query optimization** (10-30% savings):
```sql
-- Find expensive queries
SELECT query_text, execution_time, bytes_scanned
FROM query_history
ORDER BY execution_time DESC
LIMIT 100;
```
- Top 10 most expensive queries often account for 50%+ of compute
- Add clustering keys to multi-TB tables with poor pruning
- Create materialized views for frequent aggregations
- One optimized query saving 5 credits × 100 runs/day = 18,250 credits/year

**3. Storage optimization** (10-20% savings):
- Reduce Time Travel retention on non-critical tables
- Convert staging tables to TRANSIENT (no Fail-safe = ~50% storage savings)
- Drop unused databases/tables
```sql
-- Find tables not queried in 90 days
SELECT table_name, MAX(start_time)
FROM query_history qh
JOIN tables t ON ...
GROUP BY 1
HAVING MAX(start_time) < DATEADD(day, -90, CURRENT_TIMESTAMP());
```

**4. Resource monitors** (prevent overruns):
```sql
CREATE RESOURCE MONITOR monthly_limit 
WITH CREDIT_QUOTA = 10000
ON 90 PERCENT DO NOTIFY
ON 100 PERCENT DO SUSPEND_IMMEDIATE;
```

**5. Scheduled scaling**:
- Scale down warehouses during non-business hours
- Use tasks to automate: Medium during business hours, X-Small overnight

**6. Result set caching**:
- Educate users that identical queries are free (cached 24 hours)
- Design dashboard queries to leverage caching

**Real example**: I reduced costs 40% by:
- Downsizing 5 warehouses: -25%
- Optimizing top 10 queries: -10%
- Converting staging tables to TRANSIENT: -5%
- Total: 40% reduction without impacting performance"

**Q10: "How do you decide between scaling up vs scaling out warehouses?"**

**Strong Answer**:
"The decision depends on whether you're CPU-bound on a single query or have concurrent query queuing.

**Scale UP** (resize to larger warehouse):
- **When**: Single queries are slow, warehouse is underutilized
- **Effect**: More compute per query, faster individual queries
- **Example**: Nightly ETL job takes 4 hours on Medium. Scale to Large → finishes in ~2 hours for same total cost (4hrs × 4 credits = 16 credits vs 2hrs × 8 credits = 16 credits)

**Scale OUT** (multi-cluster):
- **When**: Queries are queuing, concurrency is the bottleneck
- **Effect**: More queries run simultaneously
- **Example**: 50 analysts, queries taking 1 min each but waiting 5 mins in queue. Multi-cluster with max 5 clusters → no queuing, better user experience

**Decision matrix**:
```
Symptom: Single query slow, low concurrency
→ Scale UP

Symptom: Queries queuing, high concurrency
→ Scale OUT

Symptom: Both issues
→ Scale UP first (more efficient per-query)
→ Then scale OUT if still queuing
```

**Monitoring**:
```sql
SELECT 
    AVG(queued_time)/1000 as avg_queue_seconds,
    AVG(execution_time)/1000 as avg_exec_seconds,
    AVG(avg_running) as avg_concurrent
FROM warehouse_load_history
WHERE warehouse_name = 'ANALYST_WH';
```

- High queue time, low execution time → Scale OUT
- Low queue time, high execution time → Scale UP

**Cost impact**: Scaling UP is typically more cost-effective for total throughput since you're using compute more efficiently. Scale OUT only when user experience (concurrency) requires it."

### dbt & Workflow Integration

**Q11: "How do you structure dbt projects for Snowflake, and what Snowflake-specific optimizations do you use?"**

**Strong Answer**:
"I use a layered approach optimized for Snowflake's architecture:

**Project structure**:
```
models/
  staging/      -- TRANSIENT tables, 1-day retention
    stg_orders.sql
  intermediate/ -- TRANSIENT, ephemeral where possible
    int_order_items.sql
  marts/        -- PERMANENT tables, 7-day retention
    dim_customers.sql
    fct_orders.sql
```

**Snowflake-specific optimizations in dbt_project.yml**:
```yaml
models:
  project_name:
    staging:
      +materialized: view
      +transient: true
      +database: ANALYTICS
      +schema: STAGING
      
    marts:
      +materialized: table
      +transient: false  # Permanent for Time Travel
      +data_retention_time_in_days: 7
      +cluster_by: ['date_column']  # For large fact tables
```

**Profile configuration for efficiency**:
```yaml
snowflake_prod:
  outputs:
    prod:
      threads: 8  # Parallel model execution
      query_tag: 'dbt_prod'  # Track dbt costs
      client_session_keep_alive: true  # Avoid reconnection overhead
```

**Key Snowflake optimizations**:

1. **Incremental models with merge**:
```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge',  -- Leverages Snowflake MERGE
    cluster_by=['order_date']
) }}
```

2. **Separate warehouses by purpose**:
- `DBT_PROD_WH` (Large) for production runs
- `DBT_DEV_WH` (X-Small) for development
- Set in profiles.yml, users can't accidentally use Large

3. **Transient for staging**:
```sql
{{ config(
    materialized='table',
    transient=true,
    data_retention_time_in_days=1
) }}
```
Saves ~50% storage costs on staging layers

4. **Zero-copy cloning for testing**:
```sql
-- In pre-hook
CREATE DATABASE IF NOT EXISTS ANALYTICS_TEST 
  CLONE ANALYTICS;
```
Test against production data copy instantly

5. **Monitoring dbt performance**:
```sql
-- Find slow dbt models
SELECT 
    REGEXP_SUBSTR(query_text, 'CREATE.*TABLE\\s+(\\w+)', 1, 1, 'i', 1) as model,
    AVG(execution_time)/1000 as avg_seconds
FROM query_history
WHERE query_tag = 'dbt_prod'
    AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY 1
ORDER BY 2 DESC;
```

This structure leverages Snowflake's strengths: instant scaling, transient tables for cost savings, clustering for large tables, and merge for efficient incrementals."

### Advanced Scenarios

**Q12: "You have 10TB of event data with poor clustering. Queries scanning the full table take 10 minutes. How do you approach this?"**

**Strong Answer**:
"I'd follow this systematic approach:

**1. Understand query patterns**:
```sql
-- What filters are used?
SELECT 
    query_text,
    COUNT(*) as frequency
FROM query_history
WHERE query_text LIKE '%events%'
    AND start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1
ORDER BY 2 DESC;
```
Typically find 80% of queries filter on 1-2 columns (e.g., event_date, user_id)

**2. Check current clustering**:
```sql
SELECT SYSTEM$CLUSTERING_INFORMATION('events', '(event_date, user_id)');
```
Result shows average_depth (lower is better), if high (>10), clustering is poor

**3. Evaluate clustering key benefit**:
- Table size: 10TB → Good candidate (>1TB threshold)
- Filter patterns: Consistent on event_date, user_id → Good fit
- Update frequency: Mostly inserts? → Low re-clustering cost

**4. Implement clustering**:
```sql
-- Add clustering key
ALTER TABLE events 
    CLUSTER BY (event_date, user_id);

-- Monitor re-clustering progress
SELECT SYSTEM$CLUSTERING_INFORMATION('events', '(event_date, user_id)');

-- Check re-clustering costs
SELECT 
    SUM(credits_used) as reclustering_credits,
    SUM(bytes_reclustered)/1024/1024/1024/1024 as tb_reclustered
FROM automatic_clustering_history
WHERE table_name = 'EVENTS'
    AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP());
```

**5. Alternative/complementary optimizations**:

If queries need specific aggregations:
```sql
-- Materialized view for common aggregation
CREATE MATERIALIZED VIEW events_daily_summary AS
SELECT 
    event_date,
    user_id,
    event_type,
    COUNT(*) as event_count,
    MAX(event_timestamp) as last_event
FROM events
GROUP BY 1, 2, 3;

-- Queries now hit summary (10GB) not raw table (10TB)
```

For point lookups on specific columns:
```sql
ALTER TABLE events 
    ADD SEARCH OPTIMIZATION ON EQUALITY(user_id, session_id);
```

**6. Measure improvement**:
- Re-run typical queries
- Check Query Profile: Partitions scanned should drop dramatically
- Expected: 10 minutes → 30 seconds for date-filtered queries

**Cost-benefit**:
- Re-clustering: ~$500-1000 one-time + ~$50-100/month maintenance
- Query improvement: 10 min → 30 sec = 95% time savings
- If queries run 100×/day: (9.5 min × 100 × 30 days) × $2/credit/hour = ~$950/month savings
- Clear ROI after month 2-3

In practice, I've seen 10-100x query performance improvements on multi-TB tables after proper clustering."

---

## Summary: Key Takeaways for Interviews

### Top 5 Architectural Concepts to Master
1. Three-layer architecture (compute/storage/services separation)
2. Micro-partitions and automatic partition pruning
3. Virtual warehouses and scaling strategies (up vs out)
4. Time Travel and Fail-safe architecture
5. Result set caching mechanism

### Top 5 Performance Optimization Techniques
1. Query Profile analysis (partitions scanned, bytes spilled)
2. Clustering keys for multi-TB tables
3. Materialized views for frequent aggregations
4. Warehouse right-sizing and auto-suspend tuning
5. Proper WHERE clause construction (avoid functions on filtered columns)

### Top 5 Cost Optimization Strategies
1. Right-size warehouses based on actual load
2. Use TRANSIENT tables for staging/temp data
3. Optimize Time Travel retention per table criticality
4. Leverage result set caching
5. Resource monitors to prevent runaway costs

### Top 5 Security Patterns
1. RBAC with functional roles (not user-based permissions)
2. Row-level security for multi-tenant isolation
3. Dynamic data masking for PII protection
4. Secure views to hide sensitive logic/data
5. Tag-based governance for automated policy application

### Red Flags to Avoid in Interviews
❌ Saying "Snowflake is expensive" without understanding cost optimization
❌ Not knowing the difference between scale up vs scale out
❌ Claiming clustering keys are always beneficial
❌ Suggesting materializing everything for performance
❌ Not understanding when Time Travel actually costs you

### Green Flags to Demonstrate
✅ Discussing trade-offs (performance vs cost, MV maintenance vs query savings)
✅ Mentioning Query Profile for debugging
✅ Understanding Snowflake's unique architecture vs traditional databases
✅ Practical examples from experience (even if from study/labs)
✅ Asking clarifying questions about scale, patterns, requirements before answering

---

## Final Study Tips

**For interviews in 1 week**:
1. Master sections 1-6 (architecture through security)
2. Be able to explain scale up vs out with examples
3. Know Query Profile debugging approach
4. Understand cost optimization strategies
5. Review scenario-based questions in section 12

**For interviews in 2+ weeks**:
- All above, plus:
- Deep dive on sections 7-11 (data sharing, dbt, advanced topics)
- Set up Snowflake trial account and practice
- Build a small dbt project against Snowflake
- Review Snowflake docs on any unclear topics

**Practice explaining concepts**:
- To a non-technical person (tests true understanding)
- Draw architecture diagrams from memory
- Walk through debugging scenarios out loud

**Remember**: Interviewers value practical experience and problem-solving approach over memorized answers. Show how you think through problems, ask clarifying questions, and consider trade-offs.

Good luck! 🚀
