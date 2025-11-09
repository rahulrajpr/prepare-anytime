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

### 3.3 Spark Data Types
43. What are the primitive data types in Spark (StringType, IntegerType, LongType, DoubleType, BooleanType, etc.)?
44. What complex data types does Spark support (ArrayType, MapType, StructType)?
45. How do you define an ArrayType column in a schema?
46. How do you define a MapType column in a schema?
47. How do you define a StructType (nested structure) in a schema?
48. What is the difference between nullable=True and nullable=False in schema definition?
49. How do you handle null values in different data types?
50. What are DateType and TimestampType? How do they differ?
51. What is DecimalType and when should you use it instead of DoubleType?
52. What is BinaryType and what are its use cases?

### 3.4 Column Operations & Functions
53. What is the syntax difference when passing multiple columns: `.drop("col1", "col2")` vs `.dropDuplicates(["col1", "col2"])`?
54. When do you use varargs vs list for passing multiple column names?
55. What is the difference between `count(*)`, `count(1)`, and `count(col)`?
56. How do these count variations handle null values differently?
57. What does `monotonically_increasing_id()` function generate? Is it guaranteed to be sequential?
58. What are the practical use cases for `monotonically_increasing_id()`?
59. What is the difference between `row_number()`, `rank()`, and `dense_rank()` window functions?
60. When would you use `lead()` and `lag()` functions?
61. What is the `first()` and `last()` aggregate function? How do they handle nulls?
62. Explain the difference between `collect_list()` and `collect_set()`.
63. What does `explode()` function do? Provide an example use case.
64. What is the difference between `explode()` and `explode_outer()`?
65. What does `posexplode()` do and how is it different from `explode()`?
66. How do you use `array_contains()` function?
67. What does `split()` function return and what is its data type?
68. How do you use `concat()` vs `concat_ws()` (concat with separator)?
69. What is `coalesce()` function and how does it differ from `coalesce()` for repartitioning?
70. What does `nvl()` or `ifnull()` do? Are they the same?
71. Explain `when().otherwise()` construct with examples.
72. What is the difference between `withColumn()` and `select()` for adding/transforming columns?
73. Can you use `withColumn()` multiple times in a chain? What are the performance implications?
74. What does `withColumnRenamed()` do? Can you rename multiple columns at once?
75. What is `selectExpr()` and when would you use it instead of `select()`?
76. How do you drop multiple columns efficiently?
77. What does `drop()` return if you try to drop a non-existent column?

### 3.5 String Functions
78. Explain the `regexp_extract()` function and its usage for pattern matching.
79. What is the difference between `regexp_extract()` and `regexp_replace()`?
80. How do you use `like()` and `rlike()` for pattern matching?
81. What does `substring()` function do? What are its parameters?
82. How do you use `trim()`, `ltrim()`, and `rtrim()`?
83. What is `upper()`, `lower()`, `initcap()` used for?
84. How do you use `lpad()` and `rpad()` for padding strings?
85. What does `length()` function return for null values?
86. How do you check if a string contains a substring in Spark?

### 3.6 Date & Time Functions
87. What are the key date and time functions in Spark (current_date, current_timestamp, date_add, date_sub)?
88. How do you extract year, month, day from a date column?
89. What does `datediff()` function calculate?
90. How do you use `to_date()` and `to_timestamp()` for type conversion?
91. What is the difference between `unix_timestamp()` and `from_unixtime()`?
92. How do you handle different date formats when reading data?
93. What does `date_format()` function do?
94. How do you calculate the difference between two timestamps?
95. What is `add_months()` function used for?
96. How do you get the last day of the month using `last_day()`?
97. What does `next_day()` function do?
98. How do you handle timezone conversions in Spark?

### 3.7 Aggregate Functions
99. What is the difference between `sum()`, `sumDistinct()`, and `approx_count_distinct()`?
100. When would you use `approx_count_distinct()` instead of `countDistinct()`?
101. What does `avg()` return for null values?
102. How do you use `min()` and `max()` functions?
103. What is `stddev()` and `variance()` used for?
104. What does `corr()` function calculate (correlation)?
105. How do you use `percentile_approx()` function?
106. What is `grouping()` and `grouping_id()` used for in GROUP BY operations?

### 3.8 Array Functions
107. How do you access array elements using `getItem()` or bracket notation?
108. What does `array()` function do to create arrays from columns?
109. How do you use `array_contains()` to check for element existence?
110. What does `array_distinct()` do?
111. How do you use `array_intersect()`, `array_union()`, `array_except()`?
112. What does `array_join()` do?
113. How do you sort array elements using `array_sort()`?
114. What is `array_max()`, `array_min()`, `size()` used for?
115. How do you use `flatten()` for nested arrays?
116. What does `array_repeat()` function do?
117. How do you use `slice()` to extract a portion of an array?
118. What is `array_position()` used for?
119. How do you remove elements from an array using `array_remove()`?
120. What does `shuffle()` do to array elements?
121. How do you use `zip_with()` for element-wise array operations?

### 3.9 Map Functions
122. How do you create a map using `map()` function or `map_from_arrays()`?
123. How do you access map values using `getItem()` or bracket notation?
124. What does `map_keys()` and `map_values()` return?
125. How do you use `map_concat()` to merge maps?
126. What does `map_from_entries()` do?
127. How do you explode maps using `explode()` - what columns does it create?
128. What is `map_filter()` used for?
129. How do you get the size of a map using `size()`?

### 3.10 Struct Functions
130. How do you access struct fields using dot notation or `getField()`?
131. What does `struct()` function do to create structs from columns?
132. How do you flatten struct columns?
133. Can you use `withColumn()` to modify a field within a struct?
134. How do you select specific fields from a nested struct?

### 3.11 Type Conversion & Casting
135. How do you cast columns using `cast()` function?
136. What is the difference between `cast()` and `astype()`?
137. What happens when casting fails (e.g., string "abc" to integer)?
138. How do you handle casting errors gracefully?
139. What does `try_cast()` do in Spark SQL?

### 3.12 Null Handling & Data Cleaning
140. What is the difference between `dropna()` and `fillna()`?
141. How do you drop rows with nulls in specific columns using `dropna(subset=[])`?
142. What are the different threshold options in `dropna()`?
143. How do you fill nulls with different values for different columns?
144. What does `na.replace()` do?
145. How do you use `isNull()` and `isNotNull()` for filtering?
146. What is `nanvl()` used for (NaN value handling)?
147. How do you distinguish between null and NaN in Spark?
148. What does `dropDuplicates()` do? How do you specify subset of columns?
149. Does `dropDuplicates()` preserve the order of rows?

### 3.13 Column Expressions & SQL Functions
150. What is the difference between using column names as strings vs Column objects (col(), F.col())?
151. When must you use `col()` or `F.col()` instead of string column names?
152. What does `expr()` function allow you to do?
153. How do you reference columns from different DataFrames after a join?
154. What is the `alias()` method used for?
155. What does `name()` method return for a Column object?

### 3.14 Conditional Logic & Case Statements
156. How do you create complex conditional logic using `when().when().otherwise()`?
157. What happens if you don't provide an `otherwise()` clause?
158. How do you implement SQL CASE WHEN logic in PySpark?
159. Can you nest `when()` conditions? Provide an example.

### 3.15 JSON Functions
160. How do you parse JSON strings using `from_json()`?
161. What schema do you need to provide for `from_json()`?
162. How do you convert structs to JSON using `to_json()`?
163. What does `get_json_object()` do?
164. How do you use `json_tuple()` to extract multiple fields?
165. What is the difference between `from_json()` and `json_tuple()`?

### 3.16 Advanced Column Operations
166. What does `lit()` function do? When do you use it?
167. How do you create a column with constant values across all rows?
168. What is `input_file_name()` function used for?
169. How do you use `spark_partition_id()` to see data distribution?
170. What does `hash()` function compute?
171. What is `md5()` and `sha1()` used for?
172. How do you use `crc32()` for checksums?
173. What does `base64()` and `unbase64()` do?
174. How do you generate random values using `rand()` and `randn()`?

### 3.17 Set Operations on DataFrames
175. What is the difference between `union()` and `unionAll()`?
176. What does `unionByName()` do? How is it different from `union()`?
177. How do you use `intersect()` to find common rows?
178. What does `subtract()` (or `exceptAll()`) do?
179. Do set operations require the same schema in both DataFrames?
180. How do set operations handle duplicates?

### 3.18 DataFrame Gotchas & Common Pitfalls
181. Why does chaining multiple `withColumn()` calls have performance implications?
182. What is the better alternative to multiple `withColumn()` calls?
183. When joining two tables with the same column name (e.g., 'id'), why does `select("*")` work but `select("id")` throws an "ambiguous column" error?
184. How do you resolve column name ambiguity after joins?
185. What happens when you call an action multiple times on the same DataFrame? Is it recomputed?
186. Why should you be careful with `collect()` on large datasets?
187. What is the difference between `df.count()` and `df.select(count("*"))` ?
188. Can you modify a DataFrame in place? Why or why not?
189. What happens when you try to access a column that doesn't exist?
190. Why might `df.show()` show different results than the actual data?
191. What is the behavior of `limit()` - does it guarantee which rows are returned?
192. How do column name case sensitivity work in Spark (spark.sql.caseSensitive)?

### 3.19 Performance Tips for DataFrame Operations
193. Why is it better to filter data early in your transformation pipeline?
194. What is the performance difference between `filter()` and `where()` (trick question)?
195. When should you use `repartition()` vs `coalesce()`?
196. What is the performance impact of using UDFs vs built-in functions?
197. Why is `reduceByKey()` preferred over `groupByKey()` in RDD operations?
198. How does column pruning (selecting only needed columns) improve performance?
199. What is predicate pushdown and how does it improve query performance?
200. Why should you avoid using `count()` unnecessarily in your code?

### 3.20 Advanced Transformations
201. What is the difference between `map()` and `flatMap()` methods?
202. When would you use `map()` vs `flatMap()`?
203. What is the `cogroup()` operation and how does it differ from join operations?
204. How do you use `mapPartitions()` and when is it more efficient than `map()`?
205. What does `foreachPartition()` do and how is it different from `foreach()`?
206. What is `transform()` method on DataFrames used for?
207. How do you use `pivot()` to reshape data from long to wide format?
208. What does `unpivot()` or `melt()` do (wide to long format)?
209. What is `cube()` operation in GROUP BY?
210. How does `rollup()` differ from `cube()`?
211. What does `groupingSets()` allow you to do?

### 3.21 Function Comparisons & When to Use What
212. `count()` vs `size()` - when to use each?
213. `distinct()` vs `dropDuplicates()` - are they the same?
214. `agg()` vs direct aggregation functions - when to use which approach?
215. `select()` vs `selectExpr()` vs `withColumn()` - comparison and use cases
216. `filter()` vs `where()` - is there any difference?
217. `join()` vs `crossJoin()` - when would you use crossJoin?
218. `union()` vs `unionAll()` vs `unionByName()` - key differences
219. `orderBy()` vs `sort()` - are they the same?
220. `repartition()` vs `coalesce()` - when to use which?
221. `cache()` vs `persist()` - what's the difference?
222. `collect()` vs `take()` vs `head()` - comparison
223. `first()` vs `head()` vs `take(1)` - subtle differences
224. `sample()` vs `sampleBy()` - when to use stratified sampling?
225. `approx_count_distinct()` vs `countDistinct()` - accuracy vs performance trade-off
226. `groupBy()` with `agg()` vs `groupBy()` with direct aggregation
227. Window functions vs GROUP BY - when to use which approach?

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

### 6.1 Reading Data - Basics
256. What is the difference between `spark.read.table()` and `spark.read.parquet()`?
257. What does the `read.option('samplingRatio', 'true')` do during schema inference?
258. What is the `option('dateFormat', 'fmt')` used for? What are common date format patterns?
259. How do you handle corrupted or malformed rows when reading CSV files?
260. How do you achieve parallelism when reading from non-partitioned data files?
261. What are the different Spark data sources and sinks available?
262. What is the findspark library and when do you use it?

### 6.1.1 CSV Reading Options & Gotchas
263. What does `option('header', 'true')` do when reading CSV files?
264. What is `option('inferSchema', 'true')` and what are its performance implications?
265. How do you specify custom delimiters using `option('sep', ',')`?
266. What does `option('quote', '"')` control?
267. How do you handle multi-line records using `option('multiLine', 'true')`?
268. What does `option('escape', '\\')` do?
269. What is `option('nullValue', 'NULL')` used for?
270. How does `option('mode', 'PERMISSIVE')` differ from 'DROPMALFORMED' and 'FAILFAST'?
271. What is `option('columnNameOfCorruptRecord', '_corrupt_record')` used for?
272. How do you handle files with different encodings using `option('encoding', 'UTF-8')`?
273. What does `option('ignoreLeadingWhiteSpace', 'true')` and `option('ignoreTrailingWhiteSpace', 'true')` do?
274. Why might you get different results with `inferSchema=true` on partial data?

### 6.1.2 JSON Reading Options
275. What is `option('multiLine', 'true')` important for when reading JSON?
276. How does JSON schema inference work differently from CSV?
277. What does `option('primitivesAsString', 'true')` do?
278. How do you handle JSON files with inconsistent schemas?

### 6.1.3 Parquet Reading Options
279. Does Parquet require schema inference? Why or why not?
280. What is `option('mergeSchema', 'true')` used for in Parquet?
281. How does Parquet handle predicate pushdown?
282. What are the advantages of columnar storage in Parquet for read performance?

### 6.1.4 ORC & Avro Reading
283. How does ORC compare to Parquet for read performance?
284. What is Avro's advantage for schema evolution?
285. When would you choose ORC over Parquet?

### 6.1.5 JDBC Reading Options
286. How do you read from JDBC sources?
287. What is `option('partitionColumn', 'id')` used for in JDBC reads?
288. How do you specify `lowerBound`, `upperBound`, and `numPartitions` for parallel JDBC reads?
289. What does `option('fetchsize', '1000')` control?
290. What are the performance implications of JDBC reads without proper partitioning?

### 6.2 Writing Data - Basics & Options
291. What is the Sink API in Spark?
292. What does `maxRecordsPerFile` control when writing DataFrames?
293. How do you estimate appropriate values for `maxRecordsPerFile`?
294. What are reasonable file sizes for Spark write operations in production?
295. Why might the number of DataFrame partitions not match the number of output file partitions?
296. Can DataFrame partitions be empty? What impact does this have on output files?
297. What are .crc files in Spark output directories and what is their purpose?

### 6.2.1 Write Modes
298. What are the different save modes: append, overwrite, errorIfExists, ignore?
299. What happens if you use 'overwrite' mode - does it delete the entire directory or just data files?
300. What is the difference between static and dynamic overwrite modes?
301. How do you enable dynamic partition overwrite?
302. What are the risks of using 'overwrite' mode in production?

### 6.2.2 Write Format Options - CSV
303. What options are available when writing CSV files?
304. How do you specify custom delimiters when writing CSV?
305. What does `option('header', 'true')` do when writing CSV?
306. How do you control quote characters and escape characters in CSV writes?
307. What is `option('compression', 'gzip')` used for? What compression codecs are supported?

### 6.2.3 Write Format Options - Parquet
308. What compression codecs are supported for Parquet (snappy, gzip, lzo, brotli, etc.)?
309. What is the default compression for Parquet in Spark?
310. What does `option('mergeSchema', 'true')` do when writing Parquet?
311. How do you control Parquet block size and page size?
312. What are the trade-offs between compression ratio and write/read performance?

### 6.2.4 Write Format Options - JSON
313. What does `option('compression', 'gzip')` do for JSON writes?
314. Can you write nested structures to JSON?
315. How does JSON write performance compare to Parquet?

### 6.2.5 Write Format Options - ORC & Delta
316. What are the advantages of writing to ORC format?
317. What compression options are available for ORC?
318. What are Delta Lake's advantages over Parquet for writes (ACID, time travel)?
319. How do you write to Delta format?

### 6.3 Partitioning During Writes
320. What is the difference between `repartition(n)` and `partitionBy(col)` when writing DataFrames?
321. How does `repartition(n)` organize output at the directory level?
322. How does `partitionBy(col)` organize output at the directory level?
323. How does `partitionBy(col)` enable partition pruning in subsequent reads?
324. What is the relationship between parallelism and partition pruning when using these methods?
325. Can you use both `repartition()` and `partitionBy()` together? What happens?
326. What are the downsides of over-partitioning when writing data?
327. What is the small file problem and how does it relate to partitioning?
328. How many files should each partition ideally contain?
329. What is partition explosion and how do you avoid it?

### 6.4 Bucketing
330. What is bucketing in Spark? How do you use `bucketBy()` when writing data?
331. How does bucketing work: bucket numbers, columns, and hash functions?
332. What is the purpose of using `sortBy()` in combination with `bucketBy()`?
333. How does bucketing with sorting optimize sort-merge joins by eliminating shuffle?
334. Can you use `bucketBy()` with `partitionBy()` together?
335. What are the limitations of bucketing?
336. How do you read bucketed tables to take advantage of bucketing?
337. What happens if you change the number of buckets after writing data?

## 7. File Formats & Storage Systems

### 7.1 Storage Systems
338. What is the difference between distributed file storage systems and normal storage systems?
339. What is a Spark data lake?
340. What is HDFS and how does it work with Spark?
341. What are the advantages of cloud storage (S3, ADLS, GCS) for Spark workloads?

### 7.2 File Format Deep Dive - Parquet
342. What is columnar storage? How does Parquet implement it?
343. What are the advantages of Parquet for analytics workloads?
344. How does Parquet handle nested data structures?
345. What is a row group in Parquet?
346. What is a column chunk in Parquet?
347. How does Parquet encoding and compression work?
348. What is predicate pushdown in Parquet and why is it efficient?
349. What is projection pushdown in Parquet?
350. What are the limitations of Parquet?

### 7.3 File Format Deep Dive - Avro
351. What is row-based storage? How does Avro use it?
352. What are the advantages of Avro for streaming and schema evolution?
353. How does Avro handle schema evolution (backward, forward, full compatibility)?
354. When would you choose Avro over Parquet?
355. How is Avro schema stored and transmitted?
356. What is the performance trade-off between Avro and Parquet?

### 7.4 File Format Deep Dive - ORC
357. How is ORC similar to and different from Parquet?
358. What compression techniques does ORC use?
359. How does ORC handle predicate pushdown?
360. What are ORC stripes, row groups, and indexes?
361. When would you choose ORC over Parquet?

### 7.5 File Format Deep Dive - Delta Lake
362. What is Delta Lake and how is it different from a file format?
363. What are the ACID transaction guarantees in Delta Lake?
364. How does Delta Lake implement time travel?
365. What is the Delta transaction log?
366. How does Delta Lake handle updates and deletes?
367. What is optimize and ZORDER in Delta Lake?
368. What is vacuum in Delta Lake?
369. How does Delta Lake schema enforcement work?
370. What is schema evolution in Delta Lake?
371. What are the performance benefits of Delta over Parquet?

### 7.6 File Format Deep Dive - Apache Hudi
372. What is Apache Hudi and what data management problems does it solve?
373. What are Copy-on-Write (CoW) and Merge-on-Read (MoR) tables in Hudi?
374. When would you use Hudi over Delta Lake?
375. How does Hudi handle upserts?
376. What is Hudi's timeline and commit model?

### 7.7 File Format Comparisons
377. Compare Parquet vs CSV in terms of:
   - a) Storage efficiency
   - b) Read performance
   - c) Write performance
   - d) Schema handling
   - e) Use cases
378. Compare Avro vs Parquet vs ORC for:
   - a) Analytics workloads
   - b) Streaming workloads
   - c) Schema evolution requirements
379. Compare Delta Lake vs Apache Hudi vs Apache Iceberg for:
   - a) ACID transactions
   - b) Time travel
   - c) Performance
   - d) Ecosystem support
380. When would you use JSON format despite its inefficiency?
381. What are the trade-offs between text formats (CSV, JSON) and binary formats (Parquet, Avro, ORC)?
382. How does compression affect different file formats differently?

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

## 18. Additional Important Topics

### 18.1 Broadcast Variables & Accumulators
383. What are broadcast variables in Spark?
384. When should you use broadcast variables?
385. How do you create and use a broadcast variable?
386. What are the limitations and size restrictions of broadcast variables?
387. What are accumulators in Spark?
388. How are accumulators used for distributed counting and metrics collection?
389. What is the difference between accumulators and regular variables?
390. Can you read accumulator values inside transformations? Why or why not?
391. What happens to accumulator values if a task fails and retries?

### 18.2 Spark Data Types - Collections & Complex Types
392. How do you work with nested data structures in Spark?
393. What are the performance implications of deeply nested schemas?
394. How do you flatten nested structures?
395. When should you denormalize data vs keep it normalized in Spark?
396. How do you handle schema evolution with complex types?

### 18.3 Common Gotchas & Best Practices
397. What is the "out of memory" error and common causes in Spark?
398. Why do you get "Task not serializable" errors? How do you fix them?
399. What causes "Stage X has Y failed attempts" and how do you debug it?
400. What is data skew and what are the symptoms in Spark UI?
401. How do you identify and fix shuffle spill to disk issues?
402. What are best practices for naming columns to avoid conflicts?
403. How do you handle special characters in column names?
404. What is the impact of data types on performance (e.g., StringType vs IntegerType)?
405. Why should you avoid using `count()` multiple times on the same DataFrame?
406. What happens when you mix transformation logic with actions improperly?

### 18.4 DataFrame vs SQL - When to Use What
407. When should you use DataFrame API vs Spark SQL?
408. Can you mix DataFrame API and SQL in the same application?
409. How do you register a DataFrame as a temporary view?
410. What is the difference between `createTempView()` and `createGlobalTempView()`?
411. How does performance compare between DataFrame API and SQL?
412. Are there operations easier to express in SQL vs DataFrame API?

### 18.5 Data Sampling & Debugging
413. How do you use `sample()` for testing on subset of data?
414. What does `sample(withReplacement, fraction, seed)` mean?
415. What is stratified sampling using `sampleBy()`?
416. How do you use `limit()` for quick data inspection?
417. What does `show(n, truncate)` do? What are the parameters?
418. How do you use `printSchema()` for debugging?
419. What does `explain()` show? How do you read the physical plan?
420. What does `explain(extended=True)` reveal?

### 18.6 Type Safety & Datasets (Scala/Java)
421. What is the difference between DataFrame and Dataset in Spark?
422. What are the advantages of type safety in Datasets?
423. When would you use Dataset over DataFrame?
424. What is the performance cost of Datasets vs DataFrames?
425. How does the encoder work in Datasets?

### 18.7 Miscellaneous Important Questions
426. What is the relationship between Spark SQL engine, Catalyst optimizer, and Tungsten engine?
427. How do DataFrame API and RDD API differ in their relationship to SparkSession vs SparkContext?
428. What is the difference between client libraries (PySpark, Spark Scala, Spark Java, SparkR)?
429. How does PySpark communicate with JVM (Py4J)?
430. What are the performance implications of using PySpark vs Scala Spark?
431. When would you drop down to RDD API from DataFrame API?
432. How do you convert between RDD and DataFrame?
433. What is the cost of `collect()` in terms of network and memory?
434. How do you handle timezone-aware timestamp operations?
435. What is the difference between `current_timestamp()` and `now()`?
436. How do you generate surrogate keys in distributed systems?
437. What is `uuid()` function used for?
438. How do you handle slowly changing dimensions (SCD) in Spark?
439. What are best practices for handling PII (Personally Identifiable Information) in Spark?
440. How do you implement data quality checks in Spark pipelines?
