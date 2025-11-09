# Apache Spark Interview Questions - Comprehensive Guide

## 1. Spark Architecture & Core Concepts

### 1.1 Cluster Architecture
1. What is the Spark cluster architecture? Explain the roles of driver, worker nodes, executors, and cores.
2. What is the difference between an executor, a worker node, and a thread in Spark?
3. How do these components interact during job execution?
4. What is the role of the cluster manager in Spark architecture?

### 1.2 Execution Model
5. What is a DAG (Directed Acyclic Graph) in Spark and how does Spark use it for task scheduling?
6. What is the difference between the DAG Scheduler and the Task Scheduler?
7. What is lazy evaluation in Spark? What are its advantages?
8. Explain the execution hierarchy: spark-submit → applications → jobs → stages → tasks.
9. What happens on the driver node when an action is called on a DataFrame?
10. What happens when a task completes on an executor node? How does the driver track progress?
11. Where does the data go after an action like `collect()` is executed?

### 1.3 Operations & Transformations
12. What is the difference between transformations and actions in Spark? Provide examples.
13. What are narrow dependency transformations? Provide examples.
14. What are wide dependency transformations? Provide examples.
15. Why are narrow transformations more efficient than wide transformations?

## 2. Spark Configuration & Deployment

### 2.1 SparkSession & Context
16. What is the difference between SparkSession and SparkContext?
17. How do DataFrames relate to SparkSession and RDDs to SparkContext?
18. Where is the SparkSession configuration defined?
19. What are the most important Spark configuration parameters?

### 2.2 Cluster Managers
20. What are the different cluster managers available for Spark (YARN, Kubernetes, Mesos, Standalone)?
21. Which cluster manager is preferred for production environments and why?
22. Which cluster managers are used in AWS Glue and Databricks platforms?
23. How is YARN used in Databricks, Google Dataproc, and on-premise setups like Cloudera?

### 2.3 Deployment Modes
24. What are the different deployment modes in Spark (client mode vs cluster mode)?
25. What are the implications of each mode for driver placement and resource allocation?
26. In a high-availability setup for Spark on Kubernetes, how is a driver or executor failure handled differently compared to YARN?

### 2.4 Dynamic Resource Allocation
27. What is dynamic allocation in Spark? How do you configure it?
28. What does `spark.dynamicAllocation.initialExecutors` control?
29. How do AWS Glue and Databricks implement autoscaling on top of Apache Spark?
30. How does dynamic scaling work with Kubernetes?

### 2.5 Cloud Platform Specifics
31. What is a DPU (Data Processing Unit) in AWS Glue?
32. What are AWS Spot Instances and how are they relevant for cost-effective Spark deployments?
33. What are the latest Spark versions available in Databricks, Google Dataproc, and AWS Glue?

## 3. DataFrame & Dataset API

### 3.1 Basic DataFrame Operations
34. What is the `toDF()` method and what is its purpose?
35. What does the `collect()` method do? Explain how it brings data from executor nodes to the driver.
36. What are the risks of using `collect()` on large datasets?
37. What does `dataframe.schema.simpleString()` return?
38. What does `dataframe.rdd.getNumPartitions()` return and what is its significance?

### 3.2 Schema Management
39. What are the three approaches to define schemas in Spark DataFrame Reader API?
   - a) Infer schema
   - b) Explicitly specify schema
   - c) Implicit schema from file format
40. What are the performance implications of using `inferSchema` vs explicit schema specification?
41. What are the two ways to supply an explicit schema for DataFrame Reader?
   - a) StructType/StructField approach
   - b) SQL DDL string notation
42. When would you use each schema definition approach?

### 3.3 Column Operations
43. What is the syntax difference when passing multiple columns: `.drop("col1", "col2")` vs `.dropDuplicates(["col1", "col2"])`?
44. When do you use varargs vs list for passing multiple column names?
45. What is the difference between `count(*)`, `count(1)`, and `count(col)`?
46. How do these count variations handle null values differently?
47. What does `monotonically_increasing_id()` function generate? Is it guaranteed to be sequential?
48. What are the practical use cases for `monotonically_increasing_id()`?
49. Explain the `regexp_extract()` function and its usage for pattern matching.

### 3.4 Select and Column Ambiguity
50. When joining two tables with the same column name (e.g., 'id'), why does `select("*")` work but `select("id")` throws an "ambiguous column" error?
51. How do you resolve column name ambiguity after joins?

### 3.5 Advanced Transformations
52. What is the difference between `map()` and `flatMap()` methods?
53. When would you use `map()` vs `flatMap()`?
54. What is the `cogroup()` operation and how does it differ from join operations?

## 4. Window Functions

### 4.1 Window Function Basics
55. What is `rowsBetween` in window functions? Provide examples.
56. What is `rangeBetween` in window functions? How does it differ from `rowsBetween`?
57. Does data shuffling occur during window function operations? Why or why not?

## 5. User-Defined Functions (UDFs)

### 5.1 UDF Registration & Usage
58. How do you register a UDF for use in DataFrame functions?
59. How do you register a UDF for use in SQL expressions?
60. When is a UDF available in the Spark catalog?
61. How do you list all registered functions using `spark.catalog.listFunctions()`?
62. What are the performance implications of UDFs compared to built-in functions?

## 6. Data Sources & I/O Operations

### 6.1 Reading Data
63. What is the difference between `spark.read.table()` and `spark.read.parquet()`?
64. What does the `read.option('samplingRatio', 'true')` do during schema inference?
65. What is the `option('dateFormat', 'fmt')` used for? What are common date format patterns?
66. How do you handle corrupted or malformed rows when reading CSV files?
67. How do you achieve parallelism when reading from non-partitioned data files?
68. What are the different Spark data sources and sinks available?
69. What is the findspark library and when do you use it?

### 6.2 Writing Data
70. What is the Sink API in Spark?
71. What does `maxRecordsPerFile` control when writing DataFrames?
72. How do you estimate appropriate values for `maxRecordsPerFile`?
73. What are reasonable file sizes for Spark write operations in production?
74. Why might the number of DataFrame partitions not match the number of output file partitions?
75. Can DataFrame partitions be empty? What impact does this have on output files?
76. What are .crc files in Spark output directories and what is their purpose?

### 6.3 Partitioning During Writes
77. What is the difference between `repartition(n)` and `partitionBy(col)` when writing DataFrames?
78. How does `repartition(n)` organize output at the directory level?
79. How does `partitionBy(col)` organize output at the directory level?
80. How does `partitionBy(col)` enable partition pruning in subsequent reads?
81. What is the relationship between parallelism and partition pruning when using these methods?

### 6.4 Bucketing
82. What is bucketing in Spark? How do you use `bucketBy()` when writing data?
83. How does bucketing work: bucket numbers, columns, and hash functions?
84. What is the purpose of using `sortBy()` in combination with `bucketBy()`?
85. How does bucketing with sorting optimize sort-merge joins by eliminating shuffle?

## 7. File Formats & Storage Systems

### 7.1 Storage Systems
86. What is the difference between distributed file storage systems and normal storage systems?
87. What is a Spark data lake?

### 7.2 File Format Comparison
88. What impact does the choice of data format (Parquet vs CSV vs Avro) have on Spark performance?
89. Compare Avro, Parquet, and Delta formats in terms of:
   - a) Performance
   - b) Schema evolution
   - c) ACID properties
   - d) Use cases
90. What is Apache Hudi and what data management problems does it solve?

## 8. Joins in Spark

### 8.1 Join Types
91. What is the difference between inner join, outer join, full outer join, and left outer join?
92. What are the implications of each join type on the result set?

### 8.2 Join Strategies
93. What is a shuffle sort-merge join (shuffle join)?
94. What is a broadcast join?
95. When does Spark choose shuffle sort-merge join vs broadcast join?
96. What are the trade-offs between these join strategies in terms of memory, network I/O, and performance?
97. Explain the mechanics, considerations, and advantages of broadcast joins.

### 8.3 Join Optimization
98. How do you optimize Spark joins effectively?
99. What techniques can be used to improve join performance? (Repartitioning, Broadcasting, Caching, Shuffle tuning)
100. What does `spark.sql.autoBroadcastJoinThreshold` control? What is its default value?
101. How do you define what constitutes a "large" DataFrame vs "small" DataFrame for join optimization?
102. How do you check the size of a DataFrame in a Spark session?
103. How does `bucketBy()` remove shuffle from sort-merge joins?

### 8.4 Shuffle Operations in Joins
104. Explain Map Exchange and Reduce Exchange in shuffle sort-merge joins.
105. When processing large datasets with multiple joins, what optimization techniques should be considered?

## 9. Shuffle & Partitioning

### 9.1 Shuffle Fundamentals
106. What are shuffle operations in Spark?
107. Explain shuffle-sort operations in the context of GROUP BY operations.
108. Explain shuffle-sort operations in the context of JOIN operations.
109. What is `spark.sql.shuffle.partitions`? What does it control?
110. What are recommended values for `spark.sql.shuffle.partitions` for different workload sizes?
111. What is the shuffle buffer and what does shuffle buffer size control?

### 9.2 Partition Tuning
112. What is partition tuning and why is it crucial for optimizing Spark jobs?
113. How do you find the right balance between parallelism and shuffle overhead?
114. What is custom partitioning and when would you implement it?
115. What is the `reduceByKey` operation and why is it more efficient than `groupByKey`?

### 9.3 Data Skewness
116. What is data skewness in Spark?
117. What causes uneven distribution of data across partitions?
118. If shuffle read and write times are significantly uneven, what does this indicate about data distribution?
119. What are salting techniques for handling skewed datasets?
120. How does data skewness affect job performance?

### 9.4 Dynamic Partition Pruning
121. What is Dynamic Partition Pruning (DPP)?
122. How do you enable Dynamic Partition Pruning?
123. What scenarios benefit most from Dynamic Partition Pruning?

## 10. Memory Management & Performance

### 10.1 Memory Architecture
124. Explain Spark's Unified Memory Management model.
125. What is the difference between execution memory and storage memory?
126. What is executor memory fraction and which configuration controls it?
127. How does Spark manage memory across storage, execution, and overhead?
128. What is the role of garbage collection in Spark's memory management?
129. How do you tune garbage collection for Spark jobs?

### 10.2 Data Spilling
130. What is data spilling in Spark?
131. When and why does data spilling occur?
132. What are the performance implications of data spilling?

### 10.3 Caching & Persistence
133. Does caching happen on worker nodes or executors? Explain the relationship.
134. When should you cache DataFrames?
135. What storage levels are available for caching in Spark?
136. How does caching fit into multi-join query optimization strategies?

### 10.4 Serialization
137. Why is serialization important in Spark?
138. What serialization types are available (Java, Kryo)?
139. What is SerDe (Serializer/Deserializer) in Spark's context?
140. What are the performance differences between Java and Kryo serialization?

## 11. Catalyst Optimizer & Query Execution

### 11.1 Catalyst Optimizer
141. What is the Catalyst Optimizer in Spark?
142. Explain the Catalyst optimization phases: Analysis → Logical Optimization → Physical Planning → Code Generation.
143. How does Catalyst use cost-based optimization to enhance query performance?
144. What role do statistics play in cost-based query optimization?

### 11.2 Tungsten Engine
145. What is the Tungsten Engine?
146. How does Tungsten optimize execution through code generation and memory management?

### 11.3 Predicate Pushdown
147. What is predicate pushdown?
148. Can Spark push down filters to all types of data sources (internal and external)?
149. Categorize which data sources support predicate pushdown and which don't.

### 11.4 Adaptive Query Execution (AQE)
150. What is Adaptive Query Execution (AQE)?
151. What optimizations does AQE enable? (dynamic partition coalescing, join strategy switching, skew handling)
152. How do you enable and configure AQE?
153. What are the key benefits of using AQE?

## 12. RDDs (Resilient Distributed Datasets)

### 12.1 RDD Fundamentals
154. What is an RDD (Resilient Distributed Dataset)?
155. What makes RDDs resilient?
156. How are RDDs fault-tolerant?
157. What is the difference between narrow dependency and wide dependency in RDDs?

### 12.2 RDD vs DataFrame
158. Compare RDDs and DataFrames in terms of:
   - a) Optimization capabilities
   - b) Type safety
   - c) Performance
   - d) Ease of use
159. When would you prefer using RDDs over DataFrames/Datasets?

### 12.3 API Hierarchy
160. How do Spark SQL, Dataset API, DataFrame API, Catalyst Optimizer, and RDD relate to each other?
161. What is Spark Core and how does it relate to higher-level APIs?

## 13. Table Management & Metastore

### 13.1 Table Types
162. What is the difference between Spark managed tables and unmanaged (external) tables?
163. When does Spark delete underlying data for managed vs unmanaged tables?
164. What is the difference between Spark's in-memory database (per session) and Hive metastore (persistent)?

### 13.2 Warehouse Configuration
165. What does `spark.sql.warehouse.dir` specify?
166. What is `sparkSession.enableHiveSupport()` and when do you need it?
167. Why would you enable Hive support for managed tables?

### 13.3 Catalog Operations
168. What is the Spark Catalog API?
169. How do you switch databases using `spark.catalog.setCurrentDatabase()`?
170. How do you list available tables using `spark.catalog.listTables()`?

### 13.4 Tables vs Files
171. What are the advantages of using Spark SQL tables vs raw Parquet files for external tools (ODBC/JDBC, Tableau, Power BI)?
172. What are the advantages of using Spark SQL tables vs raw Parquet files for internal Spark API usage?

## 14. Monitoring & Troubleshooting

### 14.1 Spark UI
173. How do you explore and navigate the Spark UI for performance analysis?
174. Is Spark UI only available during active Spark sessions?
175. How can you preserve execution history and logs using log4j?

### 14.2 Metrics & Accumulators
176. What are accumulators in Spark?
177. How are accumulators used for distributed counting and metrics collection?
178. What metrics indicate performance bottlenecks (skew, spilling, GC time)?

## 15. Advanced Topics

### 15.1 Streaming & Real-Time Processing
179. How does Spark handle time-series data processing?
180. What is Spark Streaming?
181. What capabilities does Spark provide for real-time analytics?

### 15.2 Machine Learning
182. What machine learning libraries are available in Spark (MLlib)?
183. What are the key components of Spark MLlib?

### 15.3 Graph Processing
184. What is GraphX?
185. What graph processing capabilities does GraphX provide?

### 15.4 Performance Optimization Scenarios
186. When processing a multi-terabyte dataset, what strategies should be considered to optimize data read and write operations?
187. Should you cache frequently accessed data in memory for large datasets?
188. How does Spark optimize read/write operations to HDFS compared to Hadoop MapReduce?

## 16. Big Data Fundamentals

### 16.1 Core Concepts
189. What are the 3 Vs of Big Data (Volume, Velocity, Variety)? Explain each with examples.
190. What is a data lake architecture?

## 17. Platform-Specific Topics

### 17.1 AWS Glue
191. How do AWS Glue Dynamic Frames differ from standard Spark DataFrames?
192. What are the unique features of Glue Dynamic Frames?

### 17.2 Development Tools
193. What is the role of Zeppelin notebooks in the Spark ecosystem?
194. How are Zeppelin notebooks different from Databricks notebooks?

## 18. Additional Topics

### 18.1 Miscellaneous
195. What is the relationship between Spark SQL engine, Catalyst optimizer, and Tungsten engine?
196. How do DataFrame API and RDD API differ in their relationship to SparkSession vs SparkContext?
