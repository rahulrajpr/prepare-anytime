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
66. When to use `posexplode()` vs `posexplode_outer()`?
67. What is the difference between `explode()` and `posexplode()` in terms of output columns?
68. How does `inline()` differ from `inline_outer()` when working with arrays of structs?
69. How do you use `array_contains()` function?
70. What does `split()` function return and what is its data type?
71. How do you use `concat()` vs `concat_ws()` (concat with separator)?
72. What is `coalesce()` function and how does it differ from `coalesce()` for repartitioning?
73. What does `nvl()` or `ifnull()` do? Are they the same?
74. Explain `when().otherwise()` construct with examples.
75. What is the difference between `withColumn()` and `select()` for adding/transforming columns?
76. Can you use `withColumn()` multiple times in a chain? What are the performance implications?
77. What does `withColumnRenamed()` do? Can you rename multiple columns at once?
78. What is `selectExpr()` and when would you use it instead of `select()`?
79. How do you drop multiple columns efficiently?
80. What does `drop()` return if you try to drop a non-existent column?

### 3.5 String Functions
81. Explain the `regexp_extract()` function and its usage for pattern matching.
82. What is the difference between `regexp_extract()` and `regexp_replace()`?
83. How do you use `like()` and `rlike()` for pattern matching?
84. What is the difference between `like()`, `ilike()`, and `rlike()`?
85. Which pattern matching function is case-insensitive?
86. What pattern type does `rlike()` use (SQL wildcards or regex)?
87. What does `substring()` function do? What are its parameters?
88. How do you use `trim()`, `ltrim()`, and `rtrim()`?
89. What is `upper()`, `lower()`, `initcap()` used for?
90. How do you use `lpad()` and `rpad()` for padding strings?
91. What does `length()` function return for null values?
92. How do you check if a string contains a substring in Spark?

### 3.6 Date & Time Functions
93. What are the key date and time functions in Spark (current_date, current_timestamp, date_add, date_sub)?
94. How do you extract year, month, day from a date column?
95. What does `datediff()` function calculate?
96. How do you use `to_date()` and `to_timestamp()` for type conversion?
97. What is the difference between `unix_timestamp()` and `from_unixtime()`?
98. How do you handle different date formats when reading data?
99. What does `date_format()` function do?
100. How do you calculate the difference between two timestamps?
101. What is `add_months()` function used for?
102. How do you get the last day of the month using `last_day()`?
103. What does `next_day()` function do?
104. How do you handle timezone conversions in Spark?

### 3.6.1 Date & Time Intervals in Spark
105. What are the two main interval families in Spark (YEAR-MONTH and DAY-TIME)?
106. When do you use YEAR-MONTH interval vs DAY-TIME interval?
107. Why can't you directly cast a day interval to a month interval?
108. What is the common approximation used when converting between interval types?
109. What is `make_interval()` function? What makes it unique?
110. What parameters can you specify in `make_interval()`?
111. When would you use `make_interval()` over other interval functions?
112. What is `make_dt_interval()` function? What is its specific purpose?
113. What units does `make_dt_interval()` handle?
114. When would you use `make_dt_interval()` instead of `make_interval()`?
115. What is `make_ym_interval()` function? What is its specific purpose?
116. How does `make_ym_interval()` handle variable month lengths correctly?
117. When would you use `make_ym_interval()` for calendar-based calculations?
118. Compare `make_interval()` vs `make_dt_interval()` vs `make_ym_interval()` - when to use each?

### 3.6.2 Date Parsing & Formatting
119. What are the two main approaches to parsing dates in Spark SQL?
120. What date format does default `DATE()` or `CAST AS DATE` reliably support?
121. What happens when you use `DATE()` on non-ISO format strings?
122. When must you use `TO_DATE(expr, format)` instead of `DATE()`?
123. What format patterns are commonly used with `TO_DATE()`?
124. Are format pattern letters case-sensitive in `TO_DATE()`? Provide examples.
125. What is the difference between 'MM' and 'MMM' in date format patterns?
126. What is the difference between 'd', 'dd', and 'D' in date format patterns?
127. How does `DATE()` handle timestamp strings with time components?
128. What does `TO_DATE()` return for unparseable strings?
129. What are best practices for handling date formats in Spark pipelines?
130. What is `to_char()` function used for?
131. How do you use `to_timestamp()` with custom formats?
132. What is the Java DateTimeFormatter pattern syntax used in Spark?

### 3.7 Aggregate Functions
133. What is the difference between `sum()`, `sumDistinct()`, and `approx_count_distinct()`?
134. When would you use `approx_count_distinct()` instead of `countDistinct()`?
135. What is the difference between `approx_count_distinct()` and `count_min_sketch()`?
136. What does `approx_count_distinct()` measure vs `count_min_sketch()`?
137. Which function gives direct results and which returns serialized binary data?
138. What does `avg()` return for null values?
139. How do you use `min()` and `max()` functions?
140. What is `stddev()` and `variance()` used for?
141. What does `corr()` function calculate (correlation)?
142. How do you use `percentile_approx()` function?
143. What is `grouping()` and `grouping_id()` used for in GROUP BY operations?
144. What is the difference between `GROUP BY` and `GROUP BY WITH ROLLUP`?
145. How does `ROLLUP` create hierarchical aggregations?
146. How does `GROUP BY WITH ROLLUP` handle NULL values differently?

### 3.8 Array Functions
147. How do you access array elements using `getItem()` or bracket notation?
148. What does `array()` function do to create arrays from columns?
149. How do you use `array_contains()` to check for element existence?
150. What does `array_distinct()` do?
151. How do you use `array_intersect()`, `array_union()`, `array_except()`?
152. What does `array_join()` do?
153. How do you sort array elements using `array_sort()`?
154. What is `array_max()`, `array_min()`, `size()` used for?
155. How do you use `flatten()` for nested arrays?
156. What does `array_repeat()` function do?
157. How do you use `slice()` to extract a portion of an array?
158. What is `array_position()` used for?
159. How do you remove elements from an array using `array_remove()`?
160. What does `shuffle()` do to array elements?
161. How do you use `zip_with()` for element-wise array operations?

### 3.8.1 Advanced Array Functions & Comparisons
162. What is the difference between `size()` and `cardinality()` functions?
163. Are `size()` and `cardinality()` functionally identical?
164. When would you use `size()` vs `cardinality()` (personal preference)?
165. What is the difference between `reverse()`, `sort_array()`, and `array_sort()`?
166. What parameters does `reverse()` accept? What does it do?
167. What parameters does `sort_array()` accept? How do you control sort order?
168. What parameters does `array_sort()` accept? What makes it unique?
169. Can you use custom sorting logic with `sort_array()`? What about `array_sort()`?
170. When would you use `sort_array()` vs `array_sort()`?
171. What does `aggregate()` function do on arrays?
172. What parameters does `aggregate()` accept (start, merge, finish)?
173. What is the difference between `aggregate()` and `reduce()` on arrays?
174. Are `aggregate()` and `reduce()` functionally identical?
175. Which name is SQL standard: `aggregate()` or `reduce()`?
176. What does `concat()` do for arrays? Can it handle multiple arrays?
177. What is the difference between `element_at()` and `try_element_at()`?
178. What happens when `element_at()` tries to access a non-existent index?
179. What does `try_element_at()` return for non-existent indices?
180. When should you use `try_element_at()` instead of `element_at()`?
181. What does `exists()` function do on arrays?
182. What does `forall()` function do on arrays?
183. What is the difference between `exists()` and `forall()`?
184. Do `exists()` and `forall()` short-circuit? What does this mean?
185. What does `filter()` function do on arrays?
186. What is the difference between `filter()` and `exists()`?
187. How is filtering arrays different from filtering DataFrames?
188. What does `transform()` function do on arrays?
189. What parameters does `transform()` lambda accept (element, index)?
190. What does `arrays_zip()` function do?
191. What does `zip_with()` function do?
192. What is the difference between `arrays_zip()` and `zip_with()`?
193. How many arrays can `arrays_zip()` handle?
194. How many arrays can `zip_with()` handle?
195. What output structure does `arrays_zip()` create?
196. Can you customize the output with `arrays_zip()`?
197. Does `zip_with()` require a lambda function?
198. How do `arrays_zip()` and `zip_with()` handle arrays of different lengths?

### 3.9 Map Functions
199. How do you create a map using `map()` function or `map_from_arrays()`?
200. How do you access map values using `getItem()` or bracket notation?
201. What does `map_keys()` and `map_values()` return?
202. How do you use `map_concat()` to merge maps?
203. What does `map_from_entries()` do?
204. How do you explode maps using `explode()` - what columns does it create?
205. What is `map_filter()` used for?
206. How do you get the size of a map using `size()`?

### 3.9.1 Map Functions Deep Dive & Comparisons
207. What is the difference between `filter()` and `map_filter()`?
208. What input types do `filter()` vs `map_filter()` accept?
209. How many lambda parameters does `map_filter()` accept?
210. What does `map_filter()` return?
211. What does `transform()` do for arrays?
212. What does `transform_keys()` do for maps?
213. What does `transform_values()` do for maps?
214. Compare `transform()` vs `transform_keys()` vs `transform_values()` - when to use each?
215. What lambda parameters does `transform()` accept?
216. What lambda parameters do `transform_keys()` and `transform_values()` accept?
217. Does `transform()` change the size of an array?
218. Does `transform_keys()` or `transform_values()` change the size of a map?
219. What changes when you use `transform_keys()` - keys or values?
220. What changes when you use `transform_values()` - keys or values?
221. Can you use `size()` and `cardinality()` on maps?
222. Does `element_at()` work on maps? How?
223. Does `try_element_at()` work on maps?

### 3.10 Struct Functions
224. How do you access struct fields using dot notation or `getField()`?
225. What does `struct()` function do to create structs from columns?
226. How do you flatten struct columns?
227. Can you use `withColumn()` to modify a field within a struct?
228. How do you select specific fields from a nested struct?

### 3.10.1 Struct Deep Dive & Comparisons
229. What is a Struct in Apache Spark?
230. What is the purpose of using StructType in DataFrames?
231. How do structs enable representation of nested or hierarchical data?
232. What is the difference between `struct()` and `named_struct()`?
233. How do you define field names in `named_struct()`?
234. What field names does `struct()` generate by default?
235. How do you access fields in a struct created with `named_struct()`?
236. What happens to field names when using `struct()` with column names vs literals?
237. When should you use `named_struct()` over `struct()`?
238. When should you use `struct()` over `named_struct()`?
239. What does the schema look like for `named_struct('city','value','state','value')`?
240. What does the schema look like for `struct('value1', 'value2')`?
241. Can you nest structs within structs?
242. How do you access deeply nested struct fields?

### 3.11 Type Conversion & Casting
243. How do you cast columns using `cast()` function?
244. What is the difference between `cast()` and `astype()`?
245. What happens when casting fails (e.g., string "abc" to integer)?
246. How do you handle casting errors gracefully?
247. What does `try_cast()` do in Spark SQL?

### 3.11.1 Numeric Type Casting Functions
248. What is `tinyint()` function and what data type does it cast to?
249. What is `smallint()` function and when would you use it?
250. What is the difference between `int()` and `bigint()` casting?
251. When should you use `tinyint` vs `smallint` vs `int` vs `bigint`?
252. What are the value ranges for tinyint, smallint, int, and bigint?

### 3.11.2 Other Specific Casting Functions
253. What does `binary()` function do?
254. What is `boolean()` casting function used for?
255. How do you use `date()` function for type casting?
256. What does `decimal()` function do?
257. What is the difference between `double()` and `float()` casting?
258. What does `string()` function do for type conversion?
259. How do you use `timestamp()` function?

### 3.11.3 Type Conversion (to_ Functions)
260. What is `to_char()` function? What does it convert from and to?
261. What is `to_varchar()` function used for?
262. What does `to_number()` function do? When do you use it?
263. What is the difference between `to_date()` and `date()` casting?
264. What is the difference between `to_timestamp()` and `timestamp()` casting?
265. What does `to_json()` function do? What data types can it convert?
266. What is `to_binary()` function used for?
267. When would you use `to_` functions vs direct casting with `cast()`?

### 3.11.4 FLOAT vs DOUBLE vs DECIMAL
268. What is the precision difference between FLOAT, DOUBLE, and DECIMAL?
269. How much storage does each numeric type use (FLOAT, DOUBLE, DECIMAL)?
270. What types of arithmetic do FLOAT and DOUBLE use (approximate vs exact)?
271. Do FLOAT and DOUBLE have rounding errors? What about DECIMAL?
272. Which numeric type is fastest for computations?
273. When should you use FLOAT or DOUBLE for data processing?
274. When should you ALWAYS use DECIMAL instead of FLOAT/DOUBLE?
275. Why is DECIMAL the only choice for financial and monetary data?
276. What is the maximum precision supported by DECIMAL in Spark?
277. What are the performance trade-offs between DECIMAL and FLOAT/DOUBLE?
278. Provide examples where using FLOAT/DOUBLE would cause problems in financial calculations.

### 3.12 Null Handling & Data Cleaning
279. What is the difference between `dropna()` and `fillna()`?
280. How do you drop rows with nulls in specific columns using `dropna(subset=[])`?
281. What are the different threshold options in `dropna()`?
282. How do you fill nulls with different values for different columns?
283. What does `na.replace()` do?
284. How do you use `isNull()` and `isNotNull()` for filtering?
285. What is `nanvl()` used for (NaN value handling)?
286. How do you distinguish between null and NaN in Spark?
287. What is the difference between NULL and NaN in terms of meaning and data types?
288. How do NULL and NaN behave differently in comparisons?
289. What does `dropDuplicates()` do? How do you specify subset of columns?
290. Does `dropDuplicates()` preserve the order of rows?

### 3.12.1 COALESCE, NVL, and NVL2 Functions
291. What does `COALESCE()` function do?
292. How many arguments can `COALESCE()` accept?
293. What does `NVL()` function do? How is it different from `COALESCE()`?
294. How many arguments does `NVL()` accept?
295. What does `NVL2()` function do?
296. What are the three arguments in `NVL2()` and what do they represent?
297. Compare `COALESCE()` vs `NVL()` vs `NVL2()` - when to use each?
298. Is `NVL()` a SQL standard function or Oracle compatibility function?
299. Can you use `COALESCE()` with more than 2 arguments? Provide an example.
300. What does `NVL2(NULL, 'Y', 'N')` return?
301. What does `NVL(NULL, 'X')` return?
302. How would you replicate `NVL2()` behavior using `CASE WHEN`?

### 3.13 Column Expressions & SQL Functions
303. What is the difference between using column names as strings vs Column objects (col(), F.col())?
304. When must you use `col()` or `F.col()` instead of string column names?
305. What does `expr()` function allow you to do?
306. How do you reference columns from different DataFrames after a join?
307. What is the `alias()` method used for?
308. What does `name()` method return for a Column object?

### 3.14 Conditional Logic & Case Statements
309. How do you create complex conditional logic using `when().when().otherwise()`?
310. What happens if you don't provide an `otherwise()` clause?
311. How do you implement SQL CASE WHEN logic in PySpark?
312. Can you nest `when()` conditions? Provide an example?

### 3.15 JSON Functions
313. What is the difference between JSON as a file vs JSON as a column value?
314. Why does Spark convert JSON to Structs (not Maps) by default when parsing?
315. What are the performance implications of Struct vs Map for JSON data?
316. How do you parse JSON strings using `from_json()`?
317. What schema do you need to provide for `from_json()`?
318. How do you convert structs to JSON using `to_json()`?
319. What is the difference between `from_json()` and `to_json()`?
320. What does `get_json_object()` do?
321. How do you use `json_tuple()` to extract multiple fields?
322. What is the difference between `from_json()` and `json_tuple()`?
323. What is the difference between `from_json()` and `get_json_object()` in terms of efficiency?
324. When should you use `from_json()` vs `get_json_object()`?
325. What does `schema_of_json()` function do?
326. What does `json_array_length()` return?
327. What does `json_object_keys()` return?

### 3.16 Advanced Column Operations
328. What does `lit()` function do? When do you use it?
329. How do you create a column with constant values across all rows?
330. What is `input_file_name()` function used for?
331. How do you use `spark_partition_id()` to see data distribution?
332. What does `hash()` function compute?
333. What is `md5()` and `sha1()` used for?
334. How do you use `crc32()` for checksums?
335. What does `base64()` and `unbase64()` do?
336. How do you generate random values using `rand()` and `randn()`?

### 3.17 Set Operations on DataFrames
337. What is the difference between `union()` and `unionAll()`?
338. What does `unionByName()` do? How is it different from `union()`?
339. How do you use `intersect()` to find common rows?
340. What does `subtract()` (or `exceptAll()`) do?
341. Do set operations require the same schema in both DataFrames?
342. How do set operations handle duplicates?

### 3.18 Comparison & Logical Operators
343. What is the difference between `=` and `<=>` (null-safe equality)?
344. How does `=` handle NULL comparisons?
345. How does `<=>` handle NULL comparisons?
346. When should you use `<=>` instead of `=`?
347. What is the DataFrame API equivalent of `<=>`?
348. Explain the AND/OR truth table with NULL values.
349. What does `TRUE AND NULL` return?
350. What does `FALSE OR NULL` return?
351. What is short-circuit evaluation in AND/OR operations?

### 3.19 Window Functions
352. What is `rowsBetween` in window functions? Provide examples.
353. What is `rangeBetween` in window functions? How does it differ from `rowsBetween`?
354. Does data shuffling occur during window function operations? Why or why not?
355. What is the difference between `CUME_DIST()` and `PERCENT_RANK()`?
356. What does `CUME_DIST()` calculate?
357. What does `PERCENT_RANK()` calculate?
358. When would you use `CUME_DIST()` vs `PERCENT_RANK()`?
359. What is `asc_nulls_first` vs `asc_nulls_last` in ordering?
360. Where do NULLs appear with `asc_nulls_first`?
361. Where do NULLs appear with `asc_nulls_last`?

### 3.20 DataFrame Gotchas & Common Pitfalls
362. Why does chaining multiple `withColumn()` calls have performance implications?
363. What is the better alternative to multiple `withColumn()` calls?
364. When joining two tables with the same column name (e.g., 'id'), why does `select("*")` work but `select("id")` throws an "ambiguous column" error?
365. How do you resolve column name ambiguity after joins?
366. What happens when you call an action multiple times on the same DataFrame? Is it recomputed?
367. Why should you be careful with `collect()` on large datasets?
368. What is the difference between `df.count()` and `df.select(count("*"))`?
369. Can you modify a DataFrame in place? Why or why not?
370. What happens when you try to access a column that doesn't exist?
371. Why might `df.show()` show different results than the actual data?
372. What is the behavior of `limit()` - does it guarantee which rows are returned?
373. How do column name case sensitivity work in Spark (spark.sql.caseSensitive)?

### 3.21 Performance Tips for DataFrame Operations
374. Why is it better to filter data early in your transformation pipeline?
375. What is the performance difference between `filter()` and `where()` (trick question)?
376. When should you use `repartition()` vs `coalesce()`?
377. What is the performance impact of using UDFs vs built-in functions?
378. Why is `reduceByKey()` preferred over `groupByKey()` in RDD operations?
379. How does column pruning (selecting only needed columns) improve performance?
380. What is predicate pushdown and how does it improve query performance?
381. Why should you avoid using `count()` unnecessarily in your code?

### 3.22 Performance Optimization Best Practices
382. What is the optimal partition size for Spark processing (128MB-256MB)?
383. How do you determine the right number of partitions for your data?
384. What is the formula: optimal_partitions = total_data_size / target_partition_size?
385. Why is it important to avoid small files in distributed processing?
386. What is the small file problem and its performance impact?
387. How do you consolidate small files before processing?
388. What is file compaction and when should you perform it?
389. How does data skewness affect query performance?
390. What are the symptoms of data skew in Spark UI?
391. How do you identify skewed partitions in Spark UI?
392. What is the difference between task duration for skewed vs balanced partitions?
393. What is salting technique for handling data skew?
394. How do you implement salting for skewed join keys?
395. What is broadcast salting and when do you use it?
396. How does adding random salt keys help distribute skewed data?
397. What is isolated salting vs full salting?
398. How many salt keys should you add (multiplicative factor)?
399. What is the performance cost of salting?
400. When should you avoid salting?
401. What is adaptive execution and how does it handle skew automatically?
402. How do you optimize wide transformations (joins, groupBy, repartition)?
403. What is shuffle optimization and why is it critical?
404. How does reducing shuffle improve performance?
405. What is map-side combine and how does it reduce shuffle?
406. What is the difference between `reduceByKey` and `groupByKey`?
407. Why does `reduceByKey` perform better than `groupByKey`?
408. How does `reduceByKey` reduce data transfer?
409. What is combiner logic in map-side operations?
410. When should you use `aggregateByKey` instead of `reduceByKey`?
411. How do you optimize aggregations to minimize shuffle?
412. What is partial aggregation and how does it work?
413. How does `spark.sql.shuffle.partitions` affect aggregation performance?
414. What is the relationship between parallelism and shuffle partitions?
415. How many cores should process each partition ideally (2-4 partitions per core)?
416. What happens if you have too many partitions?
417. What happens if you have too few partitions?
418. How do you balance between parallelism and overhead?
419. What is task serialization overhead?
420. What is task scheduling overhead?
421. How does task scheduling delay affect small tasks?
422. What is the minimum task duration to justify distributed processing?
423. How do you optimize very short tasks (< 100ms)?
424. What is task consolidation and when should you use it?
425. How does broadcast join eliminate shuffle?
426. When should you broadcast the smaller table?
427. What is the maximum size for broadcast (driver memory constraint)?
428. How do you calculate broadcast size vs executor memory?
429. What is the 20% rule for broadcast size?
430. How does bucketing eliminate shuffle in joins?
431. What is pre-shuffling data using bucketing?
432. How do bucketed tables avoid sort-merge join shuffle?
433. What is the cost of creating bucketed tables?
434. When is bucketing worth the upfront cost?
435. How do you verify bucketing is being used in joins?
436. What is partition pruning and how does it reduce data scanning?
437. How does partitioning by column enable pruning?
438. What is the difference between partition pruning and predicate pushdown?
439. How do you optimize for partition pruning?
440. What is dynamic partition pruning (DPP) vs static pruning?
441. How does caching improve performance for iterative algorithms?
442. When should you cache intermediate results?
443. When is caching wasteful (single-use data)?
444. How do you determine what to cache in a multi-stage job?
445. What is the cost of caching (memory usage)?
446. How do you measure cache effectiveness (cache hit ratio)?
447. What is checkpointing and when should you use it vs caching?
448. How does checkpointing break lineage?
449. What is the performance benefit of breaking long lineages?
450. When does long lineage cause performance problems?
451. How do you identify long lineage issues?
452. What is lineage recomputation overhead?
453. How does checkpointing prevent recomputation?
454. What is the cost of checkpointing (disk I/O)?
455. Where should you place checkpoint directory (HDFS, S3)?
456. How do you optimize filter ordering in chained operations?
457. What is the most selective filter and why should it come first?
458. How does filter selectivity affect downstream operations?
459. What is the benefit of filtering before expensive operations (joins, aggregations)?
460. How do you calculate filter selectivity ratio?
461. How does column selection (projection) affect performance?
462. Why should you select only required columns early?
463. What is the I/O savings from column pruning?
464. How does columnar format (Parquet) benefit from column pruning?
465. What is the memory savings from selecting fewer columns?
466. How do you optimize expensive string operations?
467. Why are string operations slower than numeric operations?
468. How does data type affect processing speed?
469. Should you convert strings to numeric types when possible?
470. What is the performance impact of wide rows (many columns)?
471. How do you optimize schemas with hundreds of columns?
472. What is the benefit of nested structures vs flat schemas?
473. How do complex types (arrays, maps, structs) affect performance?
474. When should you denormalize vs normalize data?
475. What is the performance trade-off in denormalization?
476. How does avoiding UDFs improve performance (2-10x faster)?
477. Why are built-in functions faster than UDFs?
478. What optimizations can Catalyst apply to built-in functions?
479. Why can't Catalyst optimize UDFs?
480. What is the serialization overhead in UDFs?
481. When is UDF usage unavoidable?
482. How do you minimize UDF performance impact?
483. What is Pandas UDF (vectorized UDF) and how is it faster?
484. How much faster are Pandas UDFs compared to regular UDFs (3-100x)?
485. When should you use Pandas UDF instead of regular UDF?
486. How do you optimize data serialization (Kryo vs Java)?
487. How much faster is Kryo serialization (2-10x)?
488. When does serialization become a bottleneck?
489. How does serialization affect shuffle performance?
490. How does serialization affect caching efficiency?
491. What is compression and how does it affect performance?
492. What compression codecs are available (snappy, gzip, lzo, lz4)?
493. What is the trade-off between compression ratio and speed?
494. When should you use snappy (balanced, default)?
495. When should you use gzip (maximum compression)?
496. When should you use lz4 (fastest)?
497. How does compression affect I/O vs CPU trade-off?
498. When is compression counterproductive?
499. How do you optimize file formats for your workload?
500. Why is Parquet preferred for analytics (columnar, compressed)?
501. When should you use ORC instead of Parquet?
502. When should you use Avro (schema evolution, streaming)?
503. Why should you avoid CSV and JSON in production?
504. What is the performance difference between text and binary formats (5-20x)?
505. How does file format affect predicate pushdown?
506. How does file format affect compression efficiency?
507. What is the optimal file size for Spark (128MB-1GB)?
508. How do you control output file size?
509. What is `maxRecordsPerFile` and how do you set it?
510. How many files should each partition generate ideally (1 file)?
511. What happens if partitions generate too many small files?
512. How do you consolidate files after writing?
513. What is file coalescing vs file compaction?
514. How do you use `coalesce()` to control output files?
515. What is the difference between `repartition()` and `coalesce()` for file output?
516. When should you repartition before writing?
517. What is the cost of repartition (full shuffle)?
518. How do you optimize write parallelism?
519. What is the relationship between write parallelism and output files?
520. How do you balance write speed vs file count?

### 3.22 Advanced Transformations
382. What is the difference between `map()` and `flatMap()` methods?
383. When would you use `map()` vs `flatMap()`?
384. What is the `cogroup()` operation and how does it differ from join operations?
385. How do you use `mapPartitions()` and when is it more efficient than `map()`?
386. What does `foreachPartition()` do and how is it different from `foreach()`?
387. What is `transform()` method on DataFrames used for?
388. How do you use `pivot()` to reshape data from long to wide format?
389. What does `unpivot()` or `melt()` do (wide to long format)?
390. What is `cube()` operation in GROUP BY?
391. How does `rollup()` differ from `cube()`?
392. What does `groupingSets()` allow you to do?

### 3.23 Function Comparisons & When to Use What
393. `count()` vs `size()` - when to use each?
394. `distinct()` vs `dropDuplicates()` - are they the same?
395. `agg()` vs direct aggregation functions - when to use which approach?
396. `select()` vs `selectExpr()` vs `withColumn()` - comparison and use cases
397. `filter()` vs `where()` - is there any difference?
398. `join()` vs `crossJoin()` - when would you use crossJoin?
399. `union()` vs `unionAll()` vs `unionByName()` - key differences
400. `orderBy()` vs `sort()` - are they the same?
401. `repartition()` vs `coalesce()` - when to use which?
402. `cache()` vs `persist()` - what's the difference?
403. `collect()` vs `take()` vs `head()` - comparison
404. `first()` vs `head()` vs `take(1)` - subtle differences
405. `sample()` vs `sampleBy()` - when to use stratified sampling?
406. `approx_count_distinct()` vs `countDistinct()` - accuracy vs performance trade-off
407. `groupBy()` with `agg()` vs `groupBy()` with direct aggregation
408. Window functions vs GROUP BY - when to use which approach?

## 4. Spark Collections - Deep Dive

### 4.1 Collections Overview & Fundamentals
409. What are collections in Apache Spark?
410. What are the two main collection types in Spark (ArrayType and MapType)?
411. What is ArrayType? What kind of data does it store?
412. What is MapType? What kind of data does it store?
413. Are Structs considered collections in Spark? Why or why not?
414. What collection functions work on Arrays?
415. What collection functions work on Maps?
416. Do collection functions work on Structs?
417. What is the purpose of using collections in DataFrames?
418. How do collections enable efficient management of semi-structured data?

### 4.2 Map vs Struct - Critical Comparison
419. What is the key difference between StructType and MapType?
420. Are field names in Structs fixed or dynamic?
421. Are keys in Maps fixed or dynamic?
422. When are field names in Structs defined?
423. Can different rows in a Map column have different keys?
424. How do you access a Struct field?
425. How do you access a Map value?
426. When should you use Structs over Maps?
427. When should you use Maps over Structs?
428. Do Struct fields have a fixed order?
429. Is key order guaranteed in Maps?
430. Provide an example use case for Structs.
431. Provide an example use case for Maps.
432. What happens when you know all attributes upfront - Struct or Map?
433. What happens when keys are variable or semi-structured - Struct or Map?
434. Can you have optional fields in Structs?
435. Can you have optional keys in Maps?
436. Compare schema rigidity: Struct vs Map.

### 4.3 Array vs Map - Comparison
437. What is the key difference between ArrayType and MapType?
438. Does ArrayType maintain order?
439. Is order guaranteed in MapType?
440. What is ArrayType best used for?
441. What is MapType best used for?
442. Can array elements be of different types?
443. Can map values be of different types?
444. How do you access array elements by position?
445. How do you access map values by key?

### 4.4 Advanced Collection Operations & Nested Data
446. How do you work with nested data structures in Spark?
447. What are the performance implications of deeply nested schemas?
448. How do you flatten nested structures?
449. When should you denormalize data vs keep it normalized in Spark?
450. How do you handle schema evolution with complex types?
451. Can you have arrays of structs?
452. Can you have maps of arrays?
453. Can you have arrays of maps?
454. How do you query nested arrays of structs?
455. What is the performance impact of deeply nested collections?

### 4.5 Comprehensive Collection Functions Reference
456. Which functions return the number of elements in a collection?
457. What collections support `size()` and `cardinality()`?
458. What is the difference between `reverse()`, `sort_array()`, and `array_sort()` in terms of purpose?
459. Which sorting function allows custom comparator logic?
460. What is the SQL standard name for array reduction: `aggregate()` or `reduce()`?
461. What does `concat()` do and does it support multiple arrays?
462. What is the difference between `element_at()` and `try_element_at()` in error handling?
463. Which function checks if AT LEAST ONE element matches a condition?
464. Which function checks if ALL elements match a condition?
465. Do `exists()` and `forall()` short-circuit? What does this mean for performance?
466. What is the difference between `filter()` (for arrays) and `map_filter()` (for maps)?
467. How many lambda parameters does `map_filter()` require?
468. What does `transform()` work on - Arrays or Maps?
469. What does `transform_keys()` work on - Arrays or Maps?
470. What does `transform_values()` work on - Arrays or Maps?
471. How many arrays does `arrays_zip()` support?
472. How many arrays does `zip_with()` support?
473. What output structure does `arrays_zip()` create?
474. Does `zip_with()` require a lambda function?
475. What happens to shorter arrays when using `arrays_zip()` or `zip_with()`?
476. Which collection functions support both Arrays and Maps?
477. Which functions are functionally identical pairs (have same behavior)?
478. What is the purpose of having both `size()` and `cardinality()` if they're identical?
479. What is the purpose of having both `aggregate()` and `reduce()` if they're identical?

## 5. User-Defined Functions (UDFs)

### 5.1 UDF Registration & Usage
480. How do you register a UDF for use in DataFrame functions?
481. How do you register a UDF for use in SQL expressions?
482. When is a UDF available in the Spark catalog?
483. How do you list all registered functions using `spark.catalog.listFunctions()`?
484. What are the performance implications of UDFs compared to built-in functions?

## 6. Data Sources & I/O Operations

### 6.1 Reading Data - Basics
485. What is the difference between `spark.read.table()` and `spark.read.parquet()`?
486. What does the `read.option('samplingRatio', 'true')` do during schema inference?
487. What is the `option('dateFormat', 'fmt')` used for? What are common date format patterns?
488. How do you handle corrupted or malformed rows when reading CSV files?
489. How do you achieve parallelism when reading from non-partitioned data files?
490. What are the different Spark data sources and sinks available?
491. What is the findspark library and when do you use it?

### 6.1.1 CSV Reading Options & Gotchas
492. What does `option('header', 'true')` do when reading CSV files?
493. What is `option('inferSchema', 'true')` and what are its performance implications?
494. How do you specify custom delimiters using `option('sep', ',')`?
495. What does `option('quote', '"')` control?
496. How do you handle multi-line records using `option('multiLine', 'true')`?
497. What does `option('escape', '\\')` do?
498. What is `option('nullValue', 'NULL')` used for?
499. How does `option('mode', 'PERMISSIVE')` differ from 'DROPMALFORMED' and 'FAILFAST'?
500. What is `option('columnNameOfCorruptRecord', '_corrupt_record')` used for?
501. How do you handle files with different encodings using `option('encoding', 'UTF-8')`?
502. What does `option('ignoreLeadingWhiteSpace', 'true')` and `option('ignoreTrailingWhiteSpace', 'true')` do?
503. Why might you get different results with `inferSchema=true` on partial data?

### 6.1.2 JSON Reading Options
504. What is `option('multiLine', 'true')` important for when reading JSON?
505. How does JSON schema inference work differently from CSV?
506. What does `option('primitivesAsString', 'true')` do?
507. How do you handle JSON files with inconsistent schemas?

### 6.1.3 Parquet Reading Options
508. Does Parquet require schema inference? Why or why not?
509. What is `option('mergeSchema', 'true')` used for in Parquet?
510. How does Parquet handle predicate pushdown?
511. What are the advantages of columnar storage in Parquet for read performance?

### 6.1.4 ORC & Avro Reading
512. How does ORC compare to Parquet for read performance?
513. What is Avro's advantage for schema evolution?
514. When would you choose ORC over Parquet?

### 6.1.5 JDBC Reading Options
515. How do you read from JDBC sources?
516. What is `option('partitionColumn', 'id')` used for in JDBC reads?
517. How do you specify `lowerBound`, `upperBound`, and `numPartitions` for parallel JDBC reads?
518. What does `option('fetchsize', '1000')` control?
519. What are the performance implications of JDBC reads without proper partitioning?

### 6.2 Writing Data - Basics & Options
520. What is the Sink API in Spark?
521. What does `maxRecordsPerFile` control when writing DataFrames?
522. How do you estimate appropriate values for `maxRecordsPerFile`?
523. What are reasonable file sizes for Spark write operations in production?
524. Why might the number of DataFrame partitions not match the number of output file partitions?
525. Can DataFrame partitions be empty? What impact does this have on output files?
526. What are .crc files in Spark output directories and what is their purpose?

### 6.2.1 Write Modes
527. What are the different save modes: append, overwrite, errorIfExists, ignore?
528. What happens if you use 'overwrite' mode - does it delete the entire directory or just data files?
529. What is the difference between static and dynamic overwrite modes?
530. How do you enable dynamic partition overwrite?
531. What are the risks of using 'overwrite' mode in production?

### 6.2.2 Write Format Options - CSV
532. What options are available when writing CSV files?
533. How do you specify custom delimiters when writing CSV?
534. What does `option('header', 'true')` do when writing CSV?
535. How do you control quote characters and escape characters in CSV writes?
536. What is `option('compression', 'gzip')` used for? What compression codecs are supported?

### 6.2.3 Write Format Options - Parquet
537. What compression codecs are supported for Parquet (snappy, gzip, lzo, brotli, etc.)?
538. What is the default compression for Parquet in Spark?
539. What does `option('mergeSchema', 'true')` do when writing Parquet?
540. How do you control Parquet block size and page size?
541. What are the trade-offs between compression ratio and write/read performance?

### 6.2.4 Write Format Options - JSON
542. What does `option('compression', 'gzip')` do for JSON writes?
543. Can you write nested structures to JSON?
544. How does JSON write performance compare to Parquet?

### 6.2.5 Write Format Options - ORC & Delta
545. What are the advantages of writing to ORC format?
546. What compression options are available for ORC?
547. What are Delta Lake's advantages over Parquet for writes (ACID, time travel)?
548. How do you write to Delta format?

### 6.3 Partitioning During Writes
549. What is the difference between `repartition(n)` and `partitionBy(col)` when writing DataFrames?
550. How does `repartition(n)` organize output at the directory level?
551. How does `partitionBy(col)` organize output at the directory level?
552. How does `partitionBy(col)` enable partition pruning in subsequent reads?
553. What is the relationship between parallelism and partition pruning when using these methods?
554. Can you use both `repartition()` and `partitionBy()` together? What happens?
555. What are the downsides of over-partitioning when writing data?
556. What is the small file problem and how does it relate to partitioning?
557. How many files should each partition ideally contain?
558. What is partition explosion and how do you avoid it?

### 6.4 Bucketing
559. What is bucketing in Spark? How do you use `bucketBy()` when writing data?
560. How does bucketing work: bucket numbers, columns, and hash functions?
561. What is the purpose of using `sortBy()` in combination with `bucketBy()`?
562. How does bucketing with sorting optimize sort-merge joins by eliminating shuffle?
563. Can you use `bucketBy()` with `partitionBy()` together?
564. What are the limitations of bucketing?
565. How do you read bucketed tables to take advantage of bucketing?
566. What happens if you change the number of buckets after writing data?

## 7. File Formats & Storage Systems

### 7.1 Storage Systems
567. What is the difference between distributed file storage systems and normal storage systems?
568. What is a Spark data lake?
569. What is HDFS and how does it work with Spark?
570. What are the advantages of cloud storage (S3, ADLS, GCS) for Spark workloads?

### 7.2 File Format Deep Dive - Parquet
571. What is columnar storage? How does Parquet implement it?
572. What are the advantages of Parquet for analytics workloads?
573. How does Parquet handle nested data structures?
574. What is a row group in Parquet?
575. What is a column chunk in Parquet?
576. How does Parquet encoding and compression work?
577. What is predicate pushdown in Parquet and why is it efficient?
578. What is projection pushdown in Parquet?
579. What are the limitations of Parquet?

### 7.3 File Format Deep Dive - Avro
580. What is row-based storage? How does Avro use it?
581. What are the advantages of Avro for streaming and schema evolution?
582. How does Avro handle schema evolution (backward, forward, full compatibility)?
583. When would you choose Avro over Parquet?
584. How is Avro schema stored and transmitted?
585. What is the performance trade-off between Avro and Parquet?

### 7.4 File Format Deep Dive - ORC
586. How is ORC similar to and different from Parquet?
587. What compression techniques does ORC use?
588. How does ORC handle predicate pushdown?
589. What are ORC stripes, row groups, and indexes?
590. When would you choose ORC over Parquet?

### 7.5 File Format Deep Dive - Delta Lake
591. What is Delta Lake and how is it different from a file format?
592. What are the ACID transaction guarantees in Delta Lake?
593. How does Delta Lake implement time travel?
594. What is the Delta transaction log?
595. How does Delta Lake handle updates and deletes?
596. What is optimize and ZORDER in Delta Lake?
597. What is vacuum in Delta Lake?
598. How does Delta Lake schema enforcement work?
599. What is schema evolution in Delta Lake?
600. What are the performance benefits of Delta over Parquet?

### 7.6 File Format Deep Dive - Apache Hudi
601. What is Apache Hudi and what data management problems does it solve?
602. What are Copy-on-Write (CoW) and Merge-on-Read (MoR) tables in Hudi?
603. When would you use Hudi over Delta Lake?
604. How does Hudi handle upserts?
605. What is Hudi's timeline and commit model?

### 7.7 File Format Comparisons
606. Compare Parquet vs CSV in terms of:
   - a) Storage efficiency
   - b) Read performance
   - c) Write performance
   - d) Schema handling
   - e) Use cases
607. Compare Avro vs Parquet vs ORC for:
   - a) Analytics workloads
   - b) Streaming workloads
   - c) Schema evolution requirements
608. Compare Delta Lake vs Apache Hudi vs Apache Iceberg for:
   - a) ACID transactions
   - b) Time travel
   - c) Performance
   - d) Ecosystem support
609. When would you use JSON format despite its inefficiency?
610. What are the trade-offs between text formats (CSV, JSON) and binary formats (Parquet, Avro, ORC)?
611. How does compression affect different file formats differently?

## 8. Joins in Spark

### 8.1 Join Types
612. What is the difference between inner join, outer join, full outer join, and left outer join?
613. What are the implications of each join type on the result set?

### 8.2 Join Strategies & Types
614. What is a shuffle sort-merge join (shuffle join)?
615. What is a broadcast join (broadcast hash join)?
616. When does Spark choose shuffle sort-merge join vs broadcast join?
617. What are the trade-offs between these join strategies in terms of memory, network I/O, and performance?
618. Explain the mechanics, considerations, and advantages of broadcast joins.
619. What is a shuffle hash join? When is it used?
620. What is a cartesian join? When does it occur and why should it be avoided?
621. What is a broadcast nested loop join? When is it used?
622. Compare all join strategies: Broadcast Hash Join vs Shuffle Hash Join vs Sort-Merge Join vs Cartesian Join vs Broadcast Nested Loop Join.
623. What conditions must be met for Spark to choose a broadcast join?
624. What happens if a broadcast join fails due to memory constraints?
625. How does Spark decide between shuffle hash join and sort-merge join?
626. What is the difference between an equi-join and a non-equi-join in terms of join strategy selection?
627. When would Spark use broadcast nested loop join instead of broadcast hash join?

### 8.3 Broadcast Join Deep Dive
628. How does broadcast join work internally? Explain the three phases: broadcast, hash build, probe.
629. What data structure is used during the hash build phase of a broadcast join?
630. How is the smaller table distributed to executor nodes during broadcast?
631. What is the role of the driver in coordinating broadcast joins?
632. What does `spark.sql.autoBroadcastJoinThreshold` control? What is its default value (10MB)?
633. How do you manually force a broadcast join using broadcast hints?
634. What are the different ways to provide broadcast hints in Spark SQL and DataFrame API?
635. What happens if you broadcast a table larger than available executor memory?
636. How do you calculate the in-memory size of a DataFrame for broadcast join decisions?
637. What is the difference between the on-disk size and in-memory size of data?
638. Why might a 5MB Parquet file become 50MB in memory?
639. What compression and encoding affect the size difference between disk and memory?
640. How does `spark.sql.adaptive.autoBroadcastJoinThreshold` differ from the regular threshold?
641. Can you broadcast multiple tables in a multi-way join?
642. What are the memory implications of broadcasting in a multi-way join scenario?
643. How does broadcast join perform with skewed data on the large table side?
644. What happens if the broadcast data doesn't fit in executor memory during runtime?
645. How do you monitor broadcast join performance in Spark UI?
646. What metrics indicate successful broadcast join execution?
647. What is broadcast timeout and how do you configure it?
648. How does broadcast join improve performance compared to shuffle sort-merge join?
649. What network I/O savings does broadcast join provide?
650. In what scenarios would broadcast join actually be slower than sort-merge join?
651. How does broadcast join work with partition pruning?
652. Can broadcast join be used with all join types (inner, left, right, full outer)?
653. Which join types benefit most from broadcast strategy?

### 8.4 Join Optimization Strategies
654. How do you optimize Spark joins effectively?
655. What techniques can be used to improve join performance? (Repartitioning, Broadcasting, Caching, Shuffle tuning, Bucketing)
656. How do you define what constitutes a "large" DataFrame vs "small" DataFrame for join optimization?
657. How do you check the size of a DataFrame in a Spark session?
658. How does `bucketBy()` remove shuffle from sort-merge joins?
659. What is bucketed sort-merge join and how does it eliminate shuffle?
660. How do you verify that bucketing is being utilized in a join?
661. What is the relationship between bucketing, partitioning, and join performance?
662. When should you pre-partition both DataFrames before joining?
663. How does repartitioning by join key improve join performance?
664. What is the optimal number of partitions for join operations?
665. How do you balance between too few and too many partitions in joins?
666. What is the role of caching in multi-join queries?
667. Should you cache before or after filtering when planning joins?
668. How does filter pushdown before joins improve performance?
669. What is the impact of selecting only required columns before joining?
670. How do you optimize joins when both tables are large?
671. What is salting and how does it help with skewed joins?
672. How do you implement salting for skewed join keys?
673. What is the broadcast-replicate strategy for handling skew in joins?
674. How do you identify which join keys are causing skew?
675. What statistics should you collect before performing large joins?
676. How does `ANALYZE TABLE COMPUTE STATISTICS` help with join optimization?
677. What is the impact of data types on join performance (StringType vs IntegerType for join keys)?
678. How do null values in join keys affect join performance and strategy selection?
679. Should you filter out nulls before joining? When and why?

### 8.5 Shuffle Operations in Joins
680. Explain Map Exchange and Reduce Exchange in shuffle sort-merge joins.
681. When processing large datasets with multiple joins, what optimization techniques should be considered?
682. What is shuffle write and shuffle read in the context of joins?
683. How do you minimize shuffle during join operations?
684. What is the shuffle spill and how does it affect join performance?
685. How do you identify shuffle-heavy joins in Spark UI?
686. What metrics indicate excessive shuffling in joins?
687. What is the relationship between `spark.sql.shuffle.partitions` and join performance?
688. How does increasing shuffle partitions affect memory consumption during joins?

### 8.6 Adaptive Query Execution (AQE) for Joins
689. How does AQE improve join performance?
690. What is dynamic join strategy switching in AQE?
691. How does AQE convert sort-merge join to broadcast join at runtime?
692. What triggers AQE to switch join strategies during execution?
693. What is `spark.sql.adaptive.autoBroadcastJoinThreshold` and how is it different from static threshold?
694. How does AQE handle skewed joins automatically?
695. What is skew join optimization in AQE?
696. How does AQE detect skewed partitions during joins?
697. What is `spark.sql.adaptive.skewJoin.enabled` configuration?
698. What is `spark.sql.adaptive.skewJoin.skewedPartitionFactor`?
699. What is `spark.sql.adaptive.skewJoin.skewedPartitionThresholdInBytes`?
700. How does AQE split skewed partitions during joins?
701. What is the performance impact of AQE's skew join optimization?
702. How do you verify that AQE optimized your join in Spark UI?
703. What is dynamic coalescing of shuffle partitions and how does it help joins?
704. How does AQE reduce the number of reducers after shuffle in joins?
705. What is `spark.sql.adaptive.coalescePartitions.enabled`?
706. What is `spark.sql.adaptive.coalescePartitions.minPartitionSize`?
707. What is `spark.sql.adaptive.advisoryPartitionSizeInBytes`?
708. Can AQE optimizations be combined (e.g., coalescing + skew handling + join strategy switch)?
709. What are the prerequisites for AQE to work effectively with joins?
710. Does AQE work with all join types and strategies?
711. What is the overhead of enabling AQE for joins?
712. When might AQE make join performance worse?

### 8.7 Dynamic Partition Pruning (DPP) for Joins
713. What is Dynamic Partition Pruning (DPP) and how does it optimize joins?
714. How does DPP differ from static partition pruning?
715. When is DPP triggered during join execution?
716. What is the typical scenario where DPP provides significant benefit?
717. Explain the star schema query optimization using DPP.
718. How does DPP work in a fact table - dimension table join?
719. What conditions must be met for DPP to be applied?
720. What is `spark.sql.optimizer.dynamicPartitionPruning.enabled`?
721. What is `spark.sql.optimizer.dynamicPartitionPruning.useStats`?
722. What is `spark.sql.optimizer.dynamicPartitionPruning.fallbackFilterRatio`?
723. What is `spark.sql.optimizer.dynamicPartitionPruning.reuseBroadcastOnly`?
724. How does DPP interact with broadcast joins?
725. Can DPP work without broadcast joins? How?
726. What is the subquery that DPP creates during optimization?
727. How do you verify DPP is working in the query plan?
728. What does "DynamicFileSourceFilter" indicate in the physical plan?
729. How much performance improvement can DPP provide?
730. What are the limitations of DPP?
731. Does DPP work with bucketed tables?
732. Does DPP work with non-partitioned tables?
733. How does DPP handle multi-level partitioning?
734. What is the relationship between DPP and predicate pushdown?
735. Can DPP be combined with AQE optimizations?
736. How does DPP affect shuffle in joins?
737. What statistics are needed for DPP to work effectively?
738. When should you disable DPP?
739. How does DPP work with complex join conditions?
740. What is the difference between DPP and bloom filter join optimization?

## 9. Shuffle & Partitioning

### 9.1 Shuffle Fundamentals
627. What are shuffle operations in Spark?
628. Explain shuffle-sort operations in the context of GROUP BY operations.
629. Explain shuffle-sort operations in the context of JOIN operations.
630. What is `spark.sql.shuffle.partitions`? What does it control?
631. What are recommended values for `spark.sql.shuffle.partitions` for different workload sizes?
632. What is the shuffle buffer and what does shuffle buffer size control?

### 9.2 Partition Tuning
633. What is partition tuning and why is it crucial for optimizing Spark jobs?
634. How do you find the right balance between parallelism and shuffle overhead?
635. What is custom partitioning and when would you implement it?
636. What is the `reduceByKey` operation and why is it more efficient than `groupByKey`?

### 9.3 Data Skewness
637. What is data skewness in Spark?
638. What causes uneven distribution of data across partitions?
639. If shuffle read and write times are significantly uneven, what does this indicate about data distribution?
640. What are salting techniques for handling skewed datasets?
641. How does data skewness affect job performance?

### 9.4 Dynamic Partition Pruning
642. What is Dynamic Partition Pruning (DPP)?
643. How do you enable Dynamic Partition Pruning?
644. What scenarios benefit most from Dynamic Partition Pruning?

## 10. Memory Management & Performance

### 10.1 Memory Architecture & Configuration
741. Explain Spark's Unified Memory Management model.
742. What is the difference between execution memory and storage memory?
743. How does unified memory management allow dynamic borrowing between execution and storage?
744. What is `spark.memory.fraction` and what is its default value (0.6)?
745. What does `spark.memory.storageFraction` control and what is its default (0.5)?
746. How much memory is available for execution vs storage by default in Spark?
747. What is executor memory overhead and what is it used for?
748. What is `spark.executor.memoryOverhead` and how is it calculated?
749. What is the formula for total executor memory allocation?
750. What is `spark.executor.memory` and how do you set it?
751. What is `spark.driver.memory` and when should you increase it?
752. What is the difference between on-heap and off-heap memory?
753. What is `spark.memory.offHeap.enabled` and when should you enable it?
754. What is `spark.memory.offHeap.size` and how do you configure it?
755. What are the benefits of using off-heap memory in Spark?
756. What is the user memory region in Spark's memory model?
757. What is reserved memory in Spark and what is it used for?
758. How is executor memory divided: Reserved + User + Unified Memory?
759. What percentage of memory is reserved in Spark (300MB typically)?
760. What is the minimum executor memory required by Spark?
761. How do you calculate optimal executor memory for your workload?
762. What is the relationship between executor cores and executor memory?
763. Why shouldn't you allocate too much memory to a single executor?
764. What is the recommended executor memory size (8-40GB range)?
765. How does memory management differ between Spark 1.5 and earlier versions?
766. What was static memory management in older Spark versions?
767. What problems did unified memory management solve?

### 10.2 Garbage Collection & JVM Tuning
768. What is the role of garbage collection in Spark's memory management?
769. How do you tune garbage collection for Spark jobs?
770. What is the difference between Young Generation and Old Generation in JVM?
771. What is Full GC and why is it problematic in Spark?
772. What is Minor GC and how does it affect Spark performance?
773. What is `spark.executor.extraJavaOptions` used for?
774. How do you enable GC logging in Spark?
775. What are the recommended GC settings for Spark applications?
776. What is G1GC (Garbage First Garbage Collector)?
777. Why is G1GC recommended for Spark over traditional GC algorithms?
778. What is CMS (Concurrent Mark Sweep) GC?
779. How do you configure G1GC for Spark executors?
780. What is `-XX:+UseG1GC` flag?
781. What is `-XX:MaxGCPauseMillis` and what value should you set?
782. What is `-XX:InitiatingHeapOccupancyPercent` for G1GC?
783. What is the relationship between GC pauses and Spark task execution?
784. How do you identify GC issues in Spark UI?
785. What percentage of task time spent in GC is concerning (>10%)?
786. What is GC overhead and how does it affect throughput?
787. How does data serialization reduce GC pressure?
788. What is the impact of caching on GC activity?
789. How do you reduce object creation to minimize GC?
790. What is object pooling and when should you use it in Spark?

### 10.3 Data Spilling & Disk I/O
791. What is data spilling in Spark?
792. When and why does data spilling occur?
793. What are the performance implications of data spilling?
794. What is shuffle spill and how is it different from storage spill?
795. What triggers spill to disk during shuffle operations?
796. What triggers spill to disk during caching operations?
797. How do you identify spilling in Spark UI?
798. What metrics indicate spilling: "Spill (Memory)", "Spill (Disk)"?
799. What is `spark.executor.memory` vs `spark.memory.fraction` in context of spilling?
800. How does increasing executor memory reduce spilling?
801. How does increasing `spark.sql.shuffle.partitions` affect spilling?
802. What is the trade-off between partitions and spilling?
803. What is `spark.shuffle.spill.compress` and should it be enabled?
804. What is `spark.shuffle.spill.batchSize` and how does it affect performance?
805. How does data serialization format affect spilling?
806. Does Kryo serialization reduce spilling compared to Java serialization?
807. What is the impact of spilling on network I/O?
808. What is the impact of spilling on disk I/O?
809. How do you configure local disk directories for spilling?
810. What is `spark.local.dir` and why should it point to fast disks (SSDs)?
811. How does disk speed affect spill performance?
812. What happens if spill directories run out of space?
813. How do you prevent spilling in memory-intensive operations?
814. What operations are most likely to cause spilling?
815. How does caching affect spilling behavior?

### 10.4 Caching & Persistence Strategies
816. Does caching happen on worker nodes or executors? Explain the relationship.
817. When should you cache DataFrames?
818. What storage levels are available for caching in Spark?
819. What is MEMORY_ONLY storage level?
820. What is MEMORY_AND_DISK storage level?
821. What is MEMORY_ONLY_SER (serialized)?
822. What is MEMORY_AND_DISK_SER?
823. What is DISK_ONLY storage level?
824. What is OFF_HEAP storage level?
825. What storage levels support replication (_2 suffix)?
826. When should you use MEMORY_ONLY vs MEMORY_AND_DISK?
827. What are the trade-offs between deserialized vs serialized caching?
828. When should you use serialized caching?
829. How much memory does serialized caching save?
830. What is the CPU overhead of serialized caching?
831. What is the difference between `cache()` and `persist()`?
832. Can you specify storage level with `cache()`?
833. What is the default storage level for `cache()`?
834. How do you unpersist cached data?
835. What happens to cached data when executors fail?
836. How does caching work with replication factor?
837. How does caching fit into multi-join query optimization strategies?
838. Should you cache intermediate results in a DAG?
839. When is caching counterproductive?
840. How do you monitor cache usage in Spark UI?
841. What is cache hit ratio and why is it important?
842. What is LRU (Least Recently Used) eviction in caching?
843. What happens when cache memory is full?
844. How do you size cache memory appropriately?
845. What is `spark.storage.memoryFraction` in older Spark versions?
846. How does caching interact with shuffle operations?
847. Should you cache before or after wide transformations?
848. How does checkpoint differ from caching?
849. When should you use checkpoint instead of cache?
850. What is the relationship between persistence and lineage?

### 10.5 Serialization & Performance
851. Why is serialization important in Spark?
852. What serialization types are available (Java, Kryo)?
853. What is SerDe (Serializer/Deserializer) in Spark's context?
854. What are the performance differences between Java and Kryo serialization?
855. How much faster is Kryo compared to Java serialization (2-10x)?
856. How do you enable Kryo serialization?
857. What is `spark.serializer` configuration?
858. What is `spark.kryo.registrationRequired`?
859. What is `spark.kryo.classesToRegister`?
860. Why should you register classes with Kryo?
861. What happens if you don't register classes with Kryo?
862. What is the cost of class registration in Kryo?
863. How does serialization affect shuffle performance?
864. How does serialization affect caching efficiency?
865. How does serialization affect network transfer?
866. What data types benefit most from Kryo serialization?
867. When is Java serialization preferred over Kryo?
868. What is broadcast serialization and how does it work?
869. How does serialization affect broadcast join performance?
870. What is task serialization and when does it occur?
871. What causes "Task not serializable" errors?
872. How do you fix task serialization issues?
873. What objects must be serializable in Spark?
874. How do you make custom classes serializable?

## 11. Catalyst Optimizer & Query Execution

### 11.1 Catalyst Optimizer Deep Dive
875. What is the Catalyst Optimizer in Spark?
876. Explain the Catalyst optimization phases: Analysis → Logical Optimization → Physical Planning → Code Generation.
877. What happens during the Analysis phase of Catalyst?
878. What is the unresolved logical plan?
879. What is the resolved logical plan?
880. How does Catalyst resolve column names and table references?
881. What is the Catalog in Spark and how does it help Catalyst?
882. What happens during the Logical Optimization phase?
883. What rule-based optimizations does Catalyst apply?
884. What is predicate pushdown in Catalyst?
885. What is column pruning in Catalyst?
886. What is constant folding in Catalyst?
887. What is null propagation in Catalyst?
888. What is boolean expression simplification?
889. What is filter combining/merging in Catalyst?
890. What is projection collapsing in Catalyst?
891. What happens during the Physical Planning phase?
892. How does Catalyst generate multiple physical plans?
893. What is cost-based optimization (CBO) in Catalyst?
894. How does Catalyst use cost-based optimization to enhance query performance?
895. What role do statistics play in cost-based query optimization?
896. What statistics does Spark collect for CBO?
897. How do you collect table statistics using `ANALYZE TABLE`?
898. What is the difference between table statistics and column statistics?
899. What is `ANALYZE TABLE ... COMPUTE STATISTICS`?
900. What is `ANALYZE TABLE ... COMPUTE STATISTICS FOR COLUMNS`?
901. What statistics are collected: row count, data size, column histograms?
902. How do statistics affect join strategy selection?
903. How do statistics affect join order selection?
904. What is the cost model used by Catalyst?
905. How does Catalyst estimate the cost of different physical plans?
906. What is the cost of a full table scan vs index scan vs broadcast?
907. What happens during the Code Generation phase (Whole-Stage Code Generation)?
908. What is Tungsten's role in code generation?
909. How does whole-stage code generation improve performance?
910. What is the benefit of generating Java bytecode at runtime?
911. What operations support whole-stage code generation?
912. What is the hand-written code generation approach?
913. How do you view the generated code for a query?
914. What is `explain(extended=True)` and what does it show?
915. What is `explain(mode='formatted')` and its output?
916. What is `explain(mode='cost')` and what does it reveal?
917. How do you read the physical plan output?
918. What does the `*` symbol mean in physical plans (whole-stage codegen)?
919. What optimization rules can you see in the logical plan?

### 11.2 Tungsten Engine Deep Dive
920. What is the Tungsten Engine?
921. How does Tungsten optimize execution through code generation and memory management?
922. What are the three main components of Tungsten?
923. What is Tungsten's memory management component?
924. What is Tungsten's cache-aware computation?
925. What is Tungsten's code generation (whole-stage codegen)?
926. How does Tungsten reduce CPU overhead?
927. What is the Unsafe API in Tungsten?
928. How does Tungsten use off-heap memory?
929. What is binary data format in Tungsten?
930. How does Tungsten eliminate virtual function calls?
931. How does Tungsten reduce object creation overhead?
932. What is the performance improvement from Tungsten (2-10x)?
933. What operations benefit most from Tungsten optimizations?
934. How do you verify Tungsten is being used in your queries?

### 11.3 Predicate Pushdown Deep Dive
935. What is predicate pushdown?
936. How does predicate pushdown reduce data processing?
937. Can Spark push down filters to all types of data sources (internal and external)?
938. Categorize which data sources support predicate pushdown and which don't.
939. Does Parquet support predicate pushdown? How?
940. Does ORC support predicate pushdown? How?
941. Does Avro support predicate pushdown?
942. Does CSV support predicate pushdown?
943. Does JSON support predicate pushdown?
944. Do JDBC sources support predicate pushdown?
945. How does JDBC predicate pushdown work?
946. What filters can be pushed down to JDBC sources?
947. What is the benefit of pushing filters to the database in JDBC reads?
948. Does Hive support predicate pushdown?
949. Does Delta Lake support predicate pushdown?
950. How does partition pruning relate to predicate pushdown?
951. What is the difference between predicate pushdown and partition pruning?
952. How do you verify predicate pushdown is working?
953. What does the physical plan show for pushed filters?
954. What is `PushedFilters` in the physical plan?
955. Why might some filters not be pushed down?
956. What types of predicates cannot be pushed down?
957. How does predicate pushdown work with complex expressions?
958. Can predicates with UDFs be pushed down?
959. How does projection pushdown complement predicate pushdown?
960. What is projection pushdown (column pruning at source)?

### 11.4 Adaptive Query Execution (AQE) Deep Dive
961. What is Adaptive Query Execution (AQE)?
962. When was AQE introduced in Spark (3.0)?
963. What is the main difference between static optimization and adaptive optimization?
964. What optimizations does AQE enable?
965. How do you enable AQE?
966. What is `spark.sql.adaptive.enabled` (default true in Spark 3.2+)?
967. What are the three main features of AQE?

### 11.4.1 AQE: Dynamic Coalescing of Shuffle Partitions
968. What is dynamically coalescing shuffle partitions?
969. What problem does partition coalescing solve?
970. What is `spark.sql.adaptive.coalescePartitions.enabled`?
971. What is `spark.sql.adaptive.coalescePartitions.minPartitionSize` (default 1MB)?
972. What is `spark.sql.adaptive.advisoryPartitionSizeInBytes` (default 64MB)?
973. How does AQE determine the target partition size?
974. What is `spark.sql.adaptive.coalescePartitions.initialPartitionNum`?
975. How does AQE coalesce small partitions after shuffle?
976. What is the algorithm for partition coalescing?
977. When does partition coalescing happen in the query execution?
978. What is the benefit of coalescing partitions (reduced tasks, less overhead)?
979. How much can AQE reduce the number of tasks in shuffle stages?
980. How do you verify partition coalescing in Spark UI?
981. What does "AQE coalesced" indicate in the SQL tab?

### 11.4.2 AQE: Dynamic Join Strategy Switching  
982. What is dynamically switching join strategies?
983. When does AQE switch from sort-merge join to broadcast join?
984. What triggers join strategy conversion at runtime?
985. What is `spark.sql.adaptive.autoBroadcastJoinThreshold` (default 10MB)?
986. How is adaptive threshold different from static `spark.sql.autoBroadcastJoinThreshold`?
987. How does AQE measure actual data size after shuffle?
988. What happens if shuffle output is smaller than expected?
989. Can AQE convert both sides of a join if they're small enough?
990. What is the performance benefit of runtime join strategy switching?
991. How do you verify join strategy switching in Spark UI?
992. What does "broadcast join after adaptive planning" indicate?

### 11.4.3 AQE: Skew Join Optimization
993. What is skew join optimization in AQE?
994. How does AQE detect skewed partitions?
995. What is `spark.sql.adaptive.skewJoin.enabled` (default true)?
996. What is `spark.sql.adaptive.skewJoin.skewedPartitionFactor` (default 5)?
997. What is `spark.sql.adaptive.skewJoin.skewedPartitionThresholdInBytes` (default 256MB)?
998. How does the skew detection algorithm work?
999. What makes a partition "skewed" in AQE's definition?
1000. How does AQE handle skewed partitions?
1001. What is the partition splitting strategy in skew join?
1002. How many sub-partitions does AQE create from skewed partitions?
1003. What is `spark.sql.adaptive.skewJoin.skewedPartitionMaxSplits`?
1004. How does AQE replicate the non-skewed side in skew join?
1005. What is the broadcast-replicate approach for skew handling?
1006. How does skew join optimization improve performance?
1007. What is the overhead of skew join optimization?
1008. How do you verify skew join optimization in Spark UI?
1009. What does "optimized skewed join" indicate in the plan?
1010. Can AQE handle multiple skewed partitions?
1011. Does AQE work with all join types for skew handling?
1012. What join types benefit from skew optimization (inner, left, right)?

### 11.4.4 AQE: Additional Features & Configuration
1013. What is `spark.sql.adaptive.localShuffleReader.enabled`?
1014. How does local shuffle reader optimization work?
1015. What is the benefit of converting shuffle read to local read?
1016. What is `spark.sql.adaptive.optimizeSkewedJoin.enabled`?
1017. What is `spark.sql.adaptive.nonEmptyPartitionRatioForBroadcastJoin`?
1018. How does AQE interact with DPP (Dynamic Partition Pruning)?
1019. Can AQE and DPP be used together?
1020. What is the execution order: DPP then AQE or AQE then DPP?
1021. What are the prerequisites for AQE to work effectively?
1022. Does AQE work with all query types?
1023. What queries benefit most from AQE?
1024. When might AQE make performance worse?
1025. What is the overhead of enabling AQE?
1026. How does AQE affect query planning time?
1027. How do you debug AQE optimizations?
1028. How do you see AQE decisions in Spark UI?
1029. What does the "Adaptive Spark Plan" section show?
1030. How do you compare original plan vs adaptive plan?
1031. What metrics indicate successful AQE optimizations?

## 12. RDDs (Resilient Distributed Datasets)

### 12.1 RDD Fundamentals
675. What is an RDD (Resilient Distributed Dataset)?
676. What makes RDDs resilient?
677. How are RDDs fault-tolerant?
678. What is the difference between narrow dependency and wide dependency in RDDs?

### 12.2 RDD vs DataFrame
679. Compare RDDs and DataFrames in terms of:
   - a) Optimization capabilities
   - b) Type safety
   - c) Performance
   - d) Ease of use
680. When would you prefer using RDDs over DataFrames/Datasets?

### 12.3 API Hierarchy
681. How do Spark SQL, Dataset API, DataFrame API, Catalyst Optimizer, and RDD relate to each other?
682. What is Spark Core and how does it relate to higher-level APIs?

## 13. Table Management & Metastore

### 13.1 Table Types
683. What is the difference between Spark managed tables and unmanaged (external) tables?
684. When does Spark delete underlying data for managed vs unmanaged tables?
685. What is the difference between Spark's in-memory database (per session) and Hive metastore (persistent)?

### 13.2 Warehouse Configuration
686. What does `spark.sql.warehouse.dir` specify?
687. What is `sparkSession.enableHiveSupport()` and when do you need it?
688. Why would you enable Hive support for managed tables?

### 13.3 Catalog Operations
689. What is the Spark Catalog API?
690. How do you switch databases using `spark.catalog.setCurrentDatabase()`?
691. How do you list available tables using `spark.catalog.listTables()`?

### 13.4 Tables vs Files
692. What are the advantages of using Spark SQL tables vs raw Parquet files for external tools (ODBC/JDBC, Tableau, Power BI)?
693. What are the advantages of using Spark SQL tables vs raw Parquet files for internal Spark API usage?

## 14. Monitoring & Troubleshooting

### 14.1 Spark UI
694. How do you explore and navigate the Spark UI for performance analysis?
695. Is Spark UI only available during active Spark sessions?
696. How can you preserve execution history and logs using log4j?

### 14.2 Metrics & Accumulators
697. What are accumulators in Spark?
698. How are accumulators used for distributed counting and metrics collection?
699. What metrics indicate performance bottlenecks (skew, spilling, GC time)?

### 14.3 Common Errors & Debugging
700. What is the "out of memory" error and common causes in Spark?
701. Why do you get "Task not serializable" errors? How do you fix them?
702. What causes "Stage X has Y failed attempts" and how do you debug it?
703. What is data skew and what are the symptoms in Spark UI?
704. How do you identify and fix shuffle spill to disk issues?
705. What are best practices for naming columns to avoid conflicts?
706. How do you handle special characters in column names?
707. What is the impact of data types on performance (e.g., StringType vs IntegerType)?
708. Why should you avoid using `count()` multiple times on the same DataFrame?
709. What happens when you mix transformation logic with actions improperly?

## 15. Advanced Topics

### 15.1 Broadcast Variables & Accumulators
710. What are broadcast variables in Spark?
711. When should you use broadcast variables?
712. How do you create and use a broadcast variable?
713. What are the limitations and size restrictions of broadcast variables?
714. What are accumulators in Spark?
715. How are accumulators used for distributed counting and metrics collection?
716. What is the difference between accumulators and regular variables?
717. Can you read accumulator values inside transformations? Why or why not?
718. What happens to accumulator values if a task fails and retries?

### 15.2 Streaming & Real-Time Processing
719. How does Spark handle time-series data processing?
720. What is Spark Streaming?
721. What capabilities does Spark provide for real-time analytics?

### 15.3 Machine Learning
722. What machine learning libraries are available in Spark (MLlib)?
723. What are the key components of Spark MLlib?

### 15.4 Graph Processing
724. What is GraphX?
725. What graph processing capabilities does GraphX provide?

### 15.5 Performance Optimization Scenarios
726. When processing a multi-terabyte dataset, what strategies should be considered to optimize data read and write operations?
727. Should you cache frequently accessed data in memory for large datasets?
728. How does Spark optimize read/write operations to HDFS compared to Hadoop MapReduce?

## 16. Big Data Fundamentals

### 16.1 Core Concepts
729. What are the 3 Vs of Big Data (Volume, Velocity, Variety)? Explain each with examples.
730. What is a data lake architecture?

## 17. Platform-Specific Topics

### 17.1 AWS Glue
731. How do AWS Glue Dynamic Frames differ from standard Spark DataFrames?
732. What are the unique features of Glue Dynamic Frames?

### 17.2 Development Tools
733. What is the role of Zeppelin notebooks in the Spark ecosystem?
734. How are Zeppelin notebooks different from Databricks notebooks?

## 18. Miscellaneous Important Topics

### 18.1 DataFrame vs SQL - When to Use What
735. When should you use DataFrame API vs Spark SQL?
736. Can you mix DataFrame API and SQL in the same application?
737. How do you register a DataFrame as a temporary view?
738. What is the difference between `createTempView()` and `createGlobalTempView()`?
739. How does performance compare between DataFrame API and SQL?
740. Are there operations easier to express in SQL vs DataFrame API?

### 18.2 Data Sampling & Debugging
741. How do you use `sample()` for testing on subset of data?
742. What does `sample(withReplacement, fraction, seed)` mean?
743. What is stratified sampling using `sampleBy()`?
744. How do you use `limit()` for quick data inspection?
745. What does `show(n, truncate)` do? What are the parameters?
746. How do you use `printSchema()` for debugging?
747. What does `explain()` show? How do you read the physical plan?
748. What does `explain(extended=True)` reveal?

### 18.3 Type Safety & Datasets (Scala/Java)
749. What is the difference between DataFrame and Dataset in Spark?
750. What are the advantages of type safety in Datasets?
751. When would you use Dataset over DataFrame?
752. What is the performance cost of Datasets vs DataFrames?
753. How does the encoder work in Datasets?

### 18.4 Miscellaneous Important Questions
754. What is the relationship between Spark SQL engine, Catalyst optimizer, and Tungsten engine?
755. How do DataFrame API and RDD API differ in their relationship to SparkSession vs SparkContext?
756. What is the difference between client libraries (PySpark, Spark Scala, Spark Java, SparkR)?
757. How does PySpark communicate with JVM (Py4J)?
758. What are the performance implications of using PySpark vs Scala Spark?
759. When would you drop down to RDD API from DataFrame API?
760. How do you convert between RDD and DataFrame?
761. What is the cost of `collect()` in terms of network and memory?
762. How do you handle timezone-aware timestamp operations?
763. What is the difference between `current_timestamp()` and `now()`?
764. How do you generate surrogate keys in distributed systems?
765. What is `uuid()` function used for?
766. How do you handle slowly changing dimensions (SCD) in Spark?
767. What are best practices for handling PII (Personally Identifiable Information) in Spark?
768. How do you implement data quality checks in Spark pipelines?
