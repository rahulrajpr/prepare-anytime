# Spark Optimization Techniques - Complete Guide

## 1. Understanding Spark Execution Model

### Spark Architecture Overview
```
Driver Program
    ↓
SparkContext
    ↓
Cluster Manager (YARN/Mesos/K8s/Standalone)
    ↓
Executors (on Worker Nodes)
    ↓
Tasks (execute on executor cores)
```

### Key Concepts
- **Job**: Triggered by an action (count, collect, save)
- **Stage**: Set of tasks that can run in parallel
- **Task**: Unit of work sent to one executor
- **Partition**: Logical chunk of data
- **Transformation**: Lazy operation (map, filter)
- **Action**: Triggers execution (count, collect)

---

## 2. Partitioning Optimization

### Why Partitioning Matters
- Determines parallelism
- Affects shuffle operations
- Impacts memory usage

### Optimal Partition Size
- **Recommended**: 128MB - 256MB per partition
- **Formula**: `partitions = data_size / target_partition_size`
- **Rule of thumb**: 2-3x number of cores

### Repartition vs Coalesce

#### Repartition
```python
# Increases or decreases partitions (full shuffle)
df_repartitioned = df.repartition(100)

# Repartition by column (for optimized joins/groupBy)
df_repartitioned = df.repartition(100, "user_id")

# When to use:
# - Need to increase partitions
# - Want to partition by specific column
# - Data distribution is skewed
```

#### Coalesce
```python
# Decreases partitions (avoids full shuffle)
df_coalesced = df.coalesce(10)

# When to use:
# - Only reducing number of partitions
# - After filtering that reduces data size
# - Before writing to disk (fewer output files)
```

### Example: Partition Tuning
```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("PartitionTuning").getOrCreate()

# Check current partitions
df = spark.read.parquet("large_dataset.parquet")
print(f"Current partitions: {df.rdd.getNumPartitions()}")

# Calculate optimal partitions
# If you have 10GB data, target 128MB per partition
# Optimal = 10240MB / 128MB = 80 partitions
df_optimized = df.repartition(80)

# Repartition by frequently joined/grouped column
df_by_key = df.repartition(80, "customer_id")
```

---

## 3. Caching and Persistence

### Storage Levels
```python
from pyspark import StorageLevel

# MEMORY_ONLY: Default, fastest but may spill
df.cache()  # Same as MEMORY_ONLY

# MEMORY_AND_DISK: Spills to disk if memory full
df.persist(StorageLevel.MEMORY_AND_DISK)

# MEMORY_ONLY_SER: Serialized, more memory efficient
df.persist(StorageLevel.MEMORY_ONLY_SER)

# DISK_ONLY: Slowest but guaranteed storage
df.persist(StorageLevel.DISK_ONLY)

# OFF_HEAP: Uses off-heap memory (requires configuration)
df.persist(StorageLevel.OFF_HEAP)
```

### When to Cache
```python
# DO cache when:
# 1. DataFrame is accessed multiple times
df = spark.read.parquet("large_file.parquet")
df.cache()

result1 = df.filter(col("age") > 25).count()
result2 = df.filter(col("salary") > 50000).count()
result3 = df.groupBy("department").count()

# 2. After expensive operations (join, aggregation)
expensive_df = df1.join(df2, "key").groupBy("category").agg(...)
expensive_df.cache()

# 3. Iterative algorithms (ML training)
for i in range(iterations):
    model.train(cached_data)

# DON'T cache when:
# - DataFrame used only once
# - Data is too large for memory
# - Simple transformations that are fast to recompute
```

### Cache Management
```python
# Check what's cached
spark.catalog.cacheTable("table_name")
spark.catalog.isCached("table_name")

# Unpersist when done
df.unpersist()

# Clear all cache
spark.catalog.clearCache()
```

---

## 4. Broadcast Joins

### What is Broadcast Join?
- Small table (<10MB default) is broadcasted to all executors
- Avoids shuffle for the large table
- Dramatically faster for small table joins

### Manual Broadcast
```python
from pyspark.sql.functions import broadcast

# Large table
large_df = spark.read.parquet("transactions.parquet")  # 10GB

# Small table
small_df = spark.read.parquet("products.parquet")  # 5MB

# Regular join (slow - full shuffle)
result_slow = large_df.join(small_df, "product_id")

# Broadcast join (fast - no shuffle of large table)
result_fast = large_df.join(broadcast(small_df), "product_id")

# Spark may auto-broadcast if table < spark.sql.autoBroadcastJoinThreshold
# Default: 10MB
```

### Configure Broadcast Threshold
```python
# Increase broadcast threshold to 50MB
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", 52428800)

# Disable auto-broadcast
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", -1)
```

### When to Use Broadcast
- One table is small (<100MB)
- Join is causing shuffle bottleneck
- Small table fits in executor memory

---

## 5. Join Optimization

### Join Strategies

#### 1. Broadcast Hash Join
```python
# Best for: small table (< broadcast threshold)
small_df = spark.read.parquet("small.parquet")
large_df = spark.read.parquet("large.parquet")
result = large_df.join(broadcast(small_df), "key")
```

#### 2. Sort Merge Join
```python
# Best for: both tables are large and sorted by join key
# Automatically used when tables are large
df1.join(df2, "key")

# Pre-sort and persist for better performance
df1_sorted = df1.repartition(200, "key").sortWithinPartitions("key").cache()
df2_sorted = df2.repartition(200, "key").sortWithinPartitions("key").cache()
result = df1_sorted.join(df2_sorted, "key")
```

#### 3. Shuffle Hash Join
```python
# Configure for specific scenarios
spark.conf.set("spark.sql.join.preferSortMergeJoin", False)
```

### Join Optimization Tips

#### Partition Before Join
```python
# Repartition both DataFrames by join key
df1_partitioned = df1.repartition(200, "customer_id")
df2_partitioned = df2.repartition(200, "customer_id")
result = df1_partitioned.join(df2_partitioned, "customer_id")
```

#### Filter Before Join
```python
# Bad: Join then filter
result = df1.join(df2, "key").filter(col("date") > "2024-01-01")

# Good: Filter then join
df1_filtered = df1.filter(col("date") > "2024-01-01")
df2_filtered = df2.filter(col("date") > "2024-01-01")
result = df1_filtered.join(df2_filtered, "key")
```

#### Select Columns Before Join
```python
# Bad: Join with all columns
result = df1.join(df2, "key")

# Good: Select only needed columns
df1_selected = df1.select("key", "col1", "col2")
df2_selected = df2.select("key", "col3", "col4")
result = df1_selected.join(df2_selected, "key")
```

---

## 6. Data Skew Handling

### What is Data Skew?
- Uneven distribution of data across partitions
- Some partitions are much larger than others
- Causes: specific keys have too many records

### Detecting Skew
```python
# Check partition sizes
def check_partition_sizes(df):
    partition_counts = df.rdd.mapPartitions(lambda it: [sum(1 for _ in it)]).collect()
    print(f"Min: {min(partition_counts)}, Max: {max(partition_counts)}, Avg: {sum(partition_counts)/len(partition_counts)}")

check_partition_sizes(df)

# Check key distribution
df.groupBy("key").count().orderBy(col("count").desc()).show(20)
```

### Salting Technique
```python
from pyspark.sql.functions import rand, concat, lit

# Add salt to skewed keys
num_salts = 10

# For the skewed DataFrame
df_salted = df.withColumn("salt", (rand() * num_salts).cast("int"))
df_salted = df_salted.withColumn("salted_key", concat(col("key"), lit("_"), col("salt")))

# For the other DataFrame (if joining)
# Explode the other side
from pyspark.sql.functions import explode, array

df2_exploded = df2.withColumn("salt", explode(array([lit(i) for i in range(num_salts)])))
df2_exploded = df2_exploded.withColumn("salted_key", concat(col("key"), lit("_"), col("salt")))

# Join on salted key
result = df_salted.join(df2_exploded, "salted_key")
```

### Adaptive Query Execution (AQE)
```python
# Enable AQE (Spark 3.0+)
spark.conf.set("spark.sql.adaptive.enabled", True)
spark.conf.set("spark.sql.adaptive.skewJoin.enabled", True)
spark.conf.set("spark.sql.adaptive.coalescePartitions.enabled", True)

# AQE automatically handles skew during runtime
```

---

## 7. File Format Optimization

### Parquet vs Other Formats

| Format | Read Speed | Write Speed | Compression | Schema Evolution |
|--------|-----------|-------------|-------------|------------------|
| Parquet | Fast | Medium | Excellent | Yes |
| ORC | Fast | Medium | Excellent | Yes |
| CSV | Slow | Fast | Poor | No |
| JSON | Slow | Medium | Poor | Yes |
| Avro | Medium | Fast | Good | Yes |

### Use Parquet Best Practices
```python
# Write with optimal configuration
df.write.mode("overwrite") \
    .option("compression", "snappy") \
    .partitionBy("year", "month") \
    .parquet("output_path")

# Configure for better performance
spark.conf.set("spark.sql.files.maxPartitionBytes", 134217728)  # 128MB
spark.conf.set("spark.sql.parquet.compression.codec", "snappy")
```

### Partitioning on Disk
```python
# Partition by date for time-series queries
df.write.partitionBy("year", "month", "day").parquet("data/")

# Advantages:
# - Partition pruning: Only scan relevant partitions
# - Faster queries on partitioned columns

# Don't over-partition:
# - Avoid creating too many small files
# - Target: 128MB - 1GB per file
```

---

## 8. Memory Management

### Executor Memory Configuration
```python
spark = SparkSession.builder \
    .appName("MemoryOptimized") \
    .config("spark.executor.memory", "8g") \
    .config("spark.executor.memoryOverhead", "2g") \
    .config("spark.driver.memory", "4g") \
    .config("spark.memory.fraction", "0.8") \
    .config("spark.memory.storageFraction", "0.5") \
    .getOrCreate()
```

### Memory Fractions
- **spark.memory.fraction**: Fraction of heap space for execution and storage (default: 0.6)
- **spark.memory.storageFraction**: Fraction of storage memory for caching (default: 0.5)

### Avoid Memory Issues
```python
# 1. Don't collect large DataFrames
# Bad
large_list = df.collect()  # OOM if df is large

# Good
df.write.parquet("output")  # Write to disk

# 2. Use sampling for development
sample_df = df.sample(0.01)  # 1% sample

# 3. Process in batches
for batch in range(0, 100, 10):
    batch_df = df.filter((col("id") >= batch) & (col("id") < batch + 10))
    batch_df.write.mode("append").parquet("output")
```

---

## 9. Shuffle Optimization

### What is Shuffle?
- Data movement across executors
- Expensive operation (I/O, network, serialization)
- Triggered by: join, groupBy, repartition, distinct, etc.

### Reduce Shuffle
```python
# 1. Pre-partition data
df_partitioned = df.repartition(200, "key")
df_partitioned.write.partitionBy("key").parquet("data/")

# 2. Use broadcast for small tables
result = large_df.join(broadcast(small_df), "key")

# 3. Combine operations
# Bad: Multiple shuffles
df.groupBy("a").count().join(df.groupBy("b").count())

# Good: Single operation
df.groupBy("a", "b").count()

# 4. Use reduceByKey instead of groupByKey (RDD API)
# Bad
rdd.groupByKey().mapValues(sum)

# Good
rdd.reduceByKey(lambda a, b: a + b)
```

### Configure Shuffle
```python
spark.conf.set("spark.sql.shuffle.partitions", 200)  # Default: 200
spark.conf.set("spark.shuffle.compress", True)
spark.conf.set("spark.shuffle.spill.compress", True)

# For large jobs, increase shuffle partitions
spark.conf.set("spark.sql.shuffle.partitions", 500)
```

---

## 10. Catalyst Optimizer

### Understanding Query Plans
```python
# Physical plan
df.explain()

# Extended explain (all plans)
df.explain(True)

# Example output interpretation:
# == Physical Plan ==
# *(1) Project [...]
#     +- *(1) Filter [...]
#         +- *(1) Scan parquet [...]

# Look for:
# - Exchange (shuffle operations)
# - BroadcastExchange
# - Sort operations
```

### Optimization Rules
- Predicate Pushdown: Push filters down to data source
- Column Pruning: Only read required columns
- Constant Folding: Evaluate constants at compile time

---

## 11. Advanced Optimization Techniques

### 1. Predicate Pushdown
```python
# Parquet automatically pushes filters to file scan
# This only reads rows where age > 25
df = spark.read.parquet("users.parquet")
filtered = df.filter(col("age") > 25).select("name", "age")

# Ensure filters are pushed:
# - Use simple predicates (=, >, <, IN)
# - Avoid UDFs in filter conditions
```

### 2. Column Pruning
```python
# Bad: Read all columns
df = spark.read.parquet("data.parquet")
result = df.select("col1", "col2")

# Good: Parquet only reads selected columns automatically
# But for CSV, explicitly select early
df = spark.read.csv("data.csv").select("col1", "col2")
```

### 3. Bucketing
```python
# Write with bucketing
df.write.bucketBy(100, "user_id") \
    .sortBy("user_id") \
    .saveAsTable("bucketed_table")

# Join bucketed tables (no shuffle needed)
bucketed_df1 = spark.table("bucketed_table1")
bucketed_df2 = spark.table("bucketed_table2")
result = bucketed_df1.join(bucketed_df2, "user_id")
```

### 4. Z-Ordering (Delta Lake)
```python
# For Delta Lake tables
from delta.tables import DeltaTable

# Optimize with Z-Order
DeltaTable.forPath(spark, "path/to/delta_table") \
    .optimize() \
    .executeZOrderBy("customer_id", "date")
```

---

## 12. Monitoring and Debugging

### Spark UI
- **Jobs Tab**: View job progress and stages
- **Stages Tab**: Task-level metrics, skew detection
- **Storage Tab**: Cached DataFrames and memory usage
- **Executors Tab**: Executor metrics, GC time
- **SQL Tab**: Query plans and metrics

### Key Metrics to Monitor
```python
# 1. Task Duration
# Look for: Slow tasks indicating skew

# 2. Shuffle Read/Write
# Minimize these values

# 3. GC Time
# High GC time indicates memory pressure

# 4. Input/Output Metrics
# Ensure efficient I/O

# Enable event logging
spark.conf.set("spark.eventLog.enabled", True)
spark.conf.set("spark.eventLog.dir", "/tmp/spark-events")
```

---

## 13. Configuration Best Practices

### General Configurations
```python
spark = SparkSession.builder \
    .appName("OptimizedApp") \
    .config("spark.executor.instances", 10) \
    .config("spark.executor.cores", 4) \
    .config("spark.executor.memory", "8g") \
    .config("spark.executor.memoryOverhead", "2g") \
    .config("spark.driver.memory", "4g") \
    .config("spark.driver.maxResultSize", "2g") \
    .config("spark.sql.shuffle.partitions", 200) \
    .config("spark.default.parallelism", 200) \
    .config("spark.sql.adaptive.enabled", True) \
    .config("spark.sql.adaptive.coalescePartitions.enabled", True) \
    .config("spark.serializer", "org.apache.spark.serializer.KryoSerializer") \
    .getOrCreate()
```

### Serialization
```python
# Use Kryo for better performance
spark.conf.set("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
spark.conf.set("spark.kryo.registrationRequired", False)
```

---

## 14. Common Optimization Patterns

### Pattern 1: ETL Pipeline
```python
# Read with optimal partitions
df = spark.read.parquet("input/") \
    .repartition(200, "partition_key")

# Filter early
df_filtered = df.filter(col("date") >= "2024-01-01")

# Select needed columns
df_selected = df_filtered.select("col1", "col2", "col3")

# Cache if used multiple times
df_selected.cache()

# Perform transformations
df_transformed = df_selected.withColumn("new_col", ...)

# Coalesce before write
df_transformed.coalesce(50) \
    .write.mode("overwrite") \
    .partitionBy("date") \
    .parquet("output/")
```

### Pattern 2: Large Join
```python
# Prepare both DataFrames
df1 = spark.read.parquet("large1/") \
    .filter(col("active") == True) \
    .select("key", "col1", "col2") \
    .repartition(200, "key")

df2 = spark.read.parquet("large2/") \
    .filter(col("valid") == True) \
    .select("key", "col3", "col4") \
    .repartition(200, "key")

# Cache if reused
df1.cache()
df2.cache()

# Perform join
result = df1.join(df2, "key")
```

---

## Optimization Checklist

✓ Use appropriate file formats (Parquet/ORC)
✓ Partition data appropriately
✓ Cache/persist frequently accessed DataFrames
✓ Use broadcast joins for small tables
✓ Filter and select early
✓ Avoid data skew with salting
✓ Tune shuffle partitions
✓ Use adaptive query execution
✓ Monitor Spark UI for bottlenecks
✓ Avoid collecting large datasets to driver
✓ Use Kryo serialization
✓ Pre-partition before joins
✓ Coalesce before writing
✓ Use bucketing for repeated joins
