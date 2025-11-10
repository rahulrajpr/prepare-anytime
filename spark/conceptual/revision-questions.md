## 6. Data Sources & I/O Operations

### 6.1 Reading Data - Basics
831. What is the difference between `spark.read.table()` and `spark.read.parquet()`?
832. What does the `read.option('samplingRatio', 'true')` do during schema inference?
833. What is the `option('dateFormat', 'fmt')` used for? What are common date format patterns?
834. How do you handle corrupted or malformed rows when reading CSV files?
835. How do you achieve parallelism when reading from non-partitioned data files?
836. What are the different Spark data sources and sinks available?
837. What is the findspark library and when do you use it?

### 6.1.0 Pandas vs Spark File Reading - Core Differences
838. What is the fundamental difference between Pandas and Spark file reading?
839. What processing model does Pandas use - single-machine or distributed?
840. What processing model does Spark use - single-machine or distributed?
841. Can Pandas read files directly from HTTP/HTTPS URLs?
842. Can Spark read files directly from HTTP/HTTPS URLs?
843. Why doesn't Spark support reading from HTTP/HTTPS URLs directly?
844. What would happen if each Spark executor downloaded from HTTP independently?
845. What problem does independent HTTP downloading cause for data consistency?
846. Does HTTP URL reading violate distributed computing principles? Why?
847. What file systems does Spark support for distributed reading?
848. Can Spark read from local file systems? What is the requirement?
849. Can Spark read from HDFS (Hadoop Distributed File System)?
850. Can Spark read from AWS S3?
851. Can Spark read from Google Cloud Storage?
852. Can Spark read from Azure Blob Storage?
853. What are the three workarounds for reading HTTP URLs in Spark?
854. How do you use the "download then read" workaround for HTTP URLs?
855. How do you use the "Pandas bridge" workaround for HTTP URLs?
856. How do you use the "manual download" workaround for HTTP URLs?
857. Why does Spark require distributed storage where all executors can access the same data?
858. What is the key principle: coordinated access for parallel processing?
859. Do all worker nodes need access to the file in Spark?
860. Does Pandas require worker access to files?
861. What is the core requirement for Spark file reading: any accessible path or distributed storage?

### 6.1.1 CSV Reading Options & Gotchas
862. What does `option('header', 'true')` do when reading CSV files?
863. What is `option('inferSchema', 'true')` and what are its performance implications?
864. How do you specify custom delimiters using `option('sep', ',')`?
865. What does `option('quote', '"')` control?
866. How do you handle multi-line records using `option('multiLine', 'true')`?
867. What does `option('escape', '\\')` do?
868. What is `option('nullValue', 'NULL')` used for?
869. How does `option('mode', 'PERMISSIVE')` differ from 'DROPMALFORMED' and 'FAILFAST'?
870. What is `option('columnNameOfCorruptRecord', '_corrupt_record')` used for?
871. How do you handle files with different encodings using `option('encoding', 'UTF-8')`?
872. What does `option('ignoreLeadingWhiteSpace', 'true')` and `option('ignoreTrailingWhiteSpace', 'true')` do?
873. Why might you get different results with `inferSchema=true` on partial data?

### 6.1.2 JSON Reading Options
874. What is `option('multiLine', 'true')` important for when reading JSON?
875. How does JSON schema inference work differently from CSV?
876. What does `option('primitivesAsString', 'true')` do?
877. How do you handle JSON files with inconsistent schemas?

### 6.1.3 Parquet Reading Options
878. Does Parquet require schema inference? Why or why not?
879. What is `option('mergeSchema', 'true')` used for in Parquet?
880. How does Parquet handle predicate pushdown?
881. What are the advantages of columnar storage in Parquet for read performance?

### 6.1.4 ORC & Avro Reading
882. How does ORC compare to Parquet for read performance?
883. What is Avro's advantage for schema evolution?
884. When would you choose ORC over Parquet?

### 6.1.5 JDBC Reading Options
885. How do you read from JDBC sources?
886. What is `option('partitionColumn', 'id')` used for in JDBC reads?
887. How do you specify `lowerBound`, `upperBound`, and `numPartitions` for parallel JDBC reads?
888. What does `option('fetchsize', '1000')` control?
889. What are the performance implications of JDBC reads without proper partitioning?

### 6.2 Writing Data - Basics & Options
890. What is the Sink API in Spark?
891. What does `maxRecordsPerFile` control when writing DataFrames?
892. How do you estimate appropriate values for `maxRecordsPerFile`?
893. What are reasonable file sizes for Spark write operations in production?
894. Why might the number of DataFrame partitions not match the number of output file partitions?
895. Can DataFrame partitions be empty? What impact does this have on output files?
896. What are .crc files in Spark output directories and what is their purpose?

### 6.2.0 DataFrameWriter vs DataFrameWriterV2 - Architectural Evolution

#### 6.2.0.1 Core Architecture
897. What is DataFrameWriter (V1) built on?
898. What is DataFrameWriterV2 (V2) built on?
899. What is the DataSource V1 API?
900. What is the DataSource V2 API?
901. What type of architecture does V1 have - monolithic or pluggable?
902. What type of architecture does V2 have - monolithic or pluggable?
903. Is V1 tightly coupled or loosely coupled with Spark's SQL engine?
904. What was V1 originally designed for - cloud storage or HDFS/relational databases?
905. What was V2 designed for - legacy systems or cloud-native environments?

#### 6.2.0.2 Design Philosophy
906. What is V1's design approach - "one size fits all" or "extensible framework"?
907. What is V2's design approach - "one size fits all" or "extensible framework"?
908. Does V1 have a fixed or customizable write execution pattern?
909. Does V2 have a fixed or customizable write execution pattern?
910. Are batch and streaming treated as separate or unified in V1?
911. Are batch and streaming treated as separate or unified in V2?
912. What type of commit protocols does V1 use - file-system oriented or transaction-aware?
913. What type of commit protocols does V2 use - file-system oriented or transaction-aware?

#### 6.2.0.3 V1 Technical Limitations
914. Does V1 support atomic commits on cloud object stores?
915. Does V1 have transaction boundaries for partial failures?
916. What are the corruption risks in V1 during job failures?
917. Are V1 recovery mechanisms limited or extensive?
918. Is V1's execution model a black box or transparent?
919. Is it easy or difficult to implement custom data sources in V1?
920. Does V1 have limited or extensive push-down capability?
921. Are V1 interface contracts rigid or flexible?
922. Does V1 have fine-grained or coarse-grained overwrite behavior?
923. How well does V1 integrate with catalog systems?
924. Does V1 have limited or extensive schema evolution support?
925. Are V1's data distribution controls basic or advanced?

#### 6.2.0.4 V2 Architectural Solutions
926. Does V2 support pluggable commit protocols?
927. Does V2 support ACID transaction guarantees?
928. Does V2 provide atomic operation guarantees?
929. Does V2 have recovery and rollback capabilities?
930. Does V2 have clean interfaces for custom implementations?
931. Does V2 have an operation push-down framework?
932. Can you customize write optimization in V2?
933. Does V2 provide unified batch and streaming APIs?
934. Does V2 have fine-grained data distribution controls?
935. Does V2 support advanced partitioning strategies?
936. Does V2 have integrated catalog management?
937. Does V2 support native schema evolution?

#### 6.2.0.5 Key Differentiators
938. What execution model does V1 use - fixed pipeline or customizable pipeline?
939. What execution model does V2 use - fixed pipeline or customizable pipeline?
940. Does V1 support planning-time optimizations or only runtime optimizations?
941. Does V2 support both planning-time and runtime optimizations?
942. Is V1 connector development simple or complex?
943. Is V2 connector development simple or complex?
944. Does V1 require deep Spark internals knowledge for connector development?
945. Does V2 have well-defined interfaces for connector development?
946. Was V1 adapted to cloud storage or designed for it?
947. Was V2 adapted to cloud storage or designed for it from inception?
948. Does V1 have basic or native integration with modern table formats (Iceberg, Delta, Hudi)?
949. Does V2 have basic or native integration with modern table formats?

#### 6.2.0.6 Evolution Context
950. What does V1 represent - Spark's origins or Spark's maturity?
951. What does V2 represent - Spark's origins or Spark's maturity?
952. Was V1 born from academic/early internet scale or cloud-native reality?
953. What was V1's primary focus - HDFS/traditional databases or diverse ecosystems?
954. What was V1's processing primacy - batch or streaming?
955. What was V1's deployment model - single data center or global scale?
956. Is V2 designed for cloud-native, hybrid cloud, or single data center?
957. Does V2 unify streaming and batch or treat them separately?
958. Is V2 designed for single deployment or global scale deployment?
959. Does V2 focus on single ecosystem or diverse data ecosystem integration?

#### 6.2.0.7 Practical Implications
960. Is V1 sufficient for basic ETL and analytics?
961. Is V2 necessary for production-grade, reliable pipelines?
962. Should platform developers focus on V1 for innovation or maintenance?
963. Should platform developers focus on V2 for innovation or ecosystem expansion?
964. Should organizations use V1 for new projects or legacy maintenance?
965. Should organizations use V2 as a future-proof foundation?

#### 6.2.0.8 Strategic Direction
966. Is V1 in active development or maintenance mode?
967. Is V2 in active development or maintenance mode?
968. Does V1 receive new feature development?
969. Does V2 receive new feature development?
970. What is V1's status - critical bug fixes only or new features?
971. What is V2's status - maintenance or active development focus?
972. Is V1 on a gradual deprecation path?
973. Is V2 the focus for ecosystem expansion?
974. Is V2 the priority for performance optimization?

#### 6.2.0.9 Summary & Conclusion
975. Does the V1 to V2 transition represent an API version increment or architectural shift?
976. What did V1 address - initial scale challenges or modern reliability requirements?
977. What does V2 address - initial scale or reliability/extensibility/operational requirements?
978. Is V2 designed for cloud-native environments?
979. Does V2 maintain backward compatibility for existing workloads?
980. Is V2 fundamental for Spark to remain relevant in evolving data ecosystems?

### 6.2.1 Write Modes - Comprehensive Analysis
981. What are the four available write modes in PySpark?
982. What does 'overwrite' mode do?
983. What does 'append' mode do?
984. What does 'ignore' mode do?
985. What does 'error' or 'errorifexists' mode do?
986. What is the default write mode in Spark?

#### 6.2.1.1 Write Modes - Behavior Analysis
987. What happens with 'overwrite' mode when target exists?
988. What happens with 'overwrite' mode when target doesn't exist?
989. What happens with 'append' mode when target exists?
990. What happens with 'append' mode when target doesn't exist?
991. What happens with 'ignore' mode when target exists?
992. What happens with 'ignore' mode when target doesn't exist?
993. What happens with 'errorifexists' mode when target exists?
994. What happens with 'errorifexists' mode when target doesn't exist?

#### 6.2.1.2 Write Modes - Use Cases
995. What are common use cases for 'overwrite' mode?
996. What are common use cases for 'append' mode?
997. What are common use cases for 'ignore' mode?
998. What are common use cases for 'errorifexists' mode?
999. When would you use 'overwrite' for full refreshes?
1000. When would you use 'append' for incremental loads?
1001. When would you use 'ignore' for safe initialization?
1002. When would you use 'errorifexists' for safety default?

#### 6.2.1.3 Write Modes - Risk & Performance
1003. What is the risk level of 'overwrite' mode - high, medium, or low?
1004. What is the risk level of 'append' mode - high, medium, or low?
1005. What is the risk level of 'ignore' mode - high, medium, or low?
1006. What is the risk level of 'errorifexists' mode - high, medium, or low?
1007. Which write mode is safest for data protection?
1008. Which write mode is riskiest for accidental data loss?
1009. What is the performance characteristic of 'ignore' when skipping?
1010. What is the performance characteristic of 'overwrite' for large datasets?
1011. What is the performance characteristic of 'append' mode?

#### 6.2.1.4 Write Modes - Best Practices
1012. What write mode should you use in development for testing?
1013. What write mode should you use in production for incremental loads?
1014. What write mode should you use in production for safety?
1015. What write mode should you use for initialization/first-time setup?
1016. What write mode prevents accidental overwrites?

### 6.3 Partitioning During Writes

#### 6.3.1 partitionBy vs bucketBy vs sortBy - Core Concepts
1017. What is `partitionBy()` - physical or logical separation?
1018. What is `bucketBy()` - physical or logical separation?
1019. What is `sortBy()` - separation or ordering?
1020. What does `partitionBy()` create on storage - folders or files?
1021. What does `bucketBy()` create on storage - folders or files?
1022. What does `sortBy()` create on storage - folders, files, or nothing?
1023. Can you SEE `partitionBy()` separation in file explorer?
1024. Can you SEE `bucketBy()` separation in file explorer?
1025. Can you SEE `sortBy()` separation in file explorer?
1026. What is the structure created by `partitionBy()` - example with country?
1027. What is the structure created by `bucketBy()` - example with user_id?
1028. What is the structure created by `sortBy()` - example with timestamp?

#### 6.3.2 Analogies for Understanding
1029. What is the analogy for `partitionBy()` - library with separate rooms?
1030. What is the analogy for `bucketBy()` - single room with numbered shelves?
1031. What is the analogy for `sortBy()` - books arranged alphabetically?

#### 6.3.3 Availability Matrix - Format Support
1032. Does CSV support `partitionBy()`?
1033. Does CSV support `bucketBy()`?
1034. Does CSV support `sortBy()`?
1035. Does JSON support `partitionBy()`?
1036. Does JSON support `bucketBy()`?
1037. Does JSON support `sortBy()`?
1038. Does Parquet/ORC support `partitionBy()`?
1039. Does Parquet/ORC support `bucketBy()`?
1040. Does Parquet/ORC support `sortBy()`?
1041. Does JDBC support `partitionBy()`?
1042. Does JDBC support `bucketBy()`?
1043. Does JDBC support `sortBy()`?
1044. Does `saveAsTable` support `partitionBy()`?
1045. Does `saveAsTable` support `bucketBy()`?
1046. Does `saveAsTable` support `sortBy()`?
1047. Which write method is the ONLY one that supports `bucketBy()`?
1048. Which write method is the ONLY one that supports `sortBy()`?
1049. Which write method supports all three: `partitionBy()`, `bucketBy()`, and `sortBy()`?

#### 6.3.4 Detailed Comparison
1050. What separation level does `partitionBy()` operate at - directory, file, or row?
1051. What separation level does `bucketBy()` operate at - directory, file, or row?
1052. What separation level does `sortBy()` operate at - directory, file, or row?
1053. Is `partitionBy()` visible in the file system?
1054. Is `bucketBy()` visible in the file system?
1055. Is `sortBy()` visible in the file system?
1056. How do you access data with `partitionBy()` - direct folder navigation?
1057. How do you access data with `bucketBy()` - hash calculation?
1058. How do you access data with `sortBy()` - sequential scanning?
1059. What is the optimal use case for `partitionBy()` - low or high cardinality?
1060. What is the optimal use case for `bucketBy()` - low or high cardinality?
1061. What is the optimal use case for `sortBy()` - specific access pattern?
1062. What performance benefit does `partitionBy()` provide?
1063. What performance benefit does `bucketBy()` provide?
1064. What performance benefit does `sortBy()` provide?
1065. How does `partitionBy()` impact file organization - multiple folders?
1066. How does `bucketBy()` impact file organization - fixed files in one folder?
1067. How does `sortBy()` impact file organization - same files, sorted internally?

#### 6.3.5 When to Use Each Method
1068. When should you use `partitionBy()` - clear categories like country/year?
1069. When should you use `partitionBy()` - frequent filtering by categories?
1070. When should you use `partitionBy()` - data lifecycle management?
1071. What formats work with `partitionBy()` - files or tables or both?
1072. When should you use `bucketBy()` - high-cardinality columns?
1073. When should you use `bucketBy()` - frequently joined tables?
1074. When should you use `bucketBy()` - need even data distribution?
1075. What formats work with `bucketBy()` - files or tables?
1076. When should you use `sortBy()` - range queries (BETWEEN, >, <)?
1077. When should you use `sortBy()` - natural ordering (timestamps)?
1078. When should you use `sortBy()` - better compression?
1079. What formats work with `sortBy()` - files or ta# Apache Spark Interview Questions - Comprehensive Guide (Expanded Edition)

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

### 3.1.1 Action Methods - Return Type Comparison
39. What does `first()` return and what is its return type?
40. What does `head()` return by default? How does `head(n)` differ?
41. What does `take(n)` return and what is its return type?
42. What does `collect()` return and why is it dangerous?
43. What is the difference between `first()` and `head()` in terms of return type?
44. Is `first()` equivalent to `head(1)[0]`? Explain.
45. What is the difference between `take(3)` and `head(3)` in terms of return type?
46. When would you use `take()` vs `collect()`?

### 3.1.2 Sorting Methods - Performance Comparison
47. What is the difference between `sort()` and `orderBy()`?
48. Are `sort()` and `orderBy()` aliases or different methods?
49. What is `sortWithinPartitions()` and how does it differ from `sort()`?
50. What is the scope of sorting for `sort()` vs `sortWithinPartitions()`?
51. Does `sortWithinPartitions()` trigger a shuffle? Why or why not?
52. When would you use `sortWithinPartitions()` instead of `sort()`?
53. What are the performance implications: `sort()` vs `sortWithinPartitions()`?
54. What is the network I/O cost of `sort()` vs `sortWithinPartitions()`?

### 3.2 Schema Management
55. What are the three approaches to define schemas in Spark DataFrame Reader API?
   - a) Infer schema
   - b) Explicitly specify schema
   - c) Implicit schema from file format
56. What are the performance implications of using `inferSchema` vs explicit schema specification?
57. What are the two ways to supply an explicit schema for DataFrame Reader?
   - a) StructType/StructField approach
   - b) SQL DDL string notation
58. When would you use each schema definition approach?

### 3.3 Spark Data Types
59. What are the primitive data types in Spark (StringType, IntegerType, LongType, DoubleType, BooleanType, etc.)?
60. What complex data types does Spark support (ArrayType, MapType, StructType)?
61. How do you define an ArrayType column in a schema?
62. How do you define a MapType column in a schema?
63. How do you define a StructType (nested structure) in a schema?
64. What is the difference between nullable=True and nullable=False in schema definition?
65. How do you handle null values in different data types?
66. What are DateType and TimestampType? How do they differ?
67. What is DecimalType and when should you use it instead of DoubleType?
68. What is BinaryType and what are its use cases?

### 3.4 Column Operations & Functions
69. What is the syntax difference when passing multiple columns: `.drop("col1", "col2")` vs `.dropDuplicates(["col1", "col2"])`?
70. When do you use varargs vs list for passing multiple column names?
71. What is the difference between `count(*)`, `count(1)`, and `count(col)`?
72. How do these count variations handle null values differently?
73. What does `monotonically_increasing_id()` function generate? Is it guaranteed to be sequential?
74. What are the practical use cases for `monotonically_increasing_id()`?
75. What is the difference between `row_number()`, `rank()`, and `dense_rank()` window functions?
76. When would you use `lead()` and `lag()` functions?
77. What is the `first()` and `last()` aggregate function? How do they handle nulls?
78. Explain the difference between `collect_list()` and `collect_set()`.
79. What does `explode()` function do? Provide an example use case.
80. What is the difference between `explode()` and `explode_outer()`?
81. What does `posexplode()` do and how is it different from `explode()`?
82. When to use `posexplode()` vs `posexplode_outer()`?
83. What is the difference between `explode()` and `posexplode()` in terms of output columns?
84. How does `inline()` differ from `inline_outer()` when working with arrays of structs?
85. How do you use `array_contains()` function?
86. What does `split()` function return and what is its data type?
87. How do you use `concat()` vs `concat_ws()` (concat with separator)?
88. What is `coalesce()` function and how does it differ from `coalesce()` for repartitioning?
89. What does `nvl()` or `ifnull()` do? Are they the same?
90. Explain `when().otherwise()` construct with examples.
91. What is the difference between `withColumn()` and `select()` for adding/transforming columns?
92. Can you use `withColumn()` multiple times in a chain? What are the performance implications?
93. What does `withColumnRenamed()` do? Can you rename multiple columns at once?
94. What is `selectExpr()` and when would you use it instead of `select()`?
95. How do you drop multiple columns efficiently?
96. What does `drop()` return if you try to drop a non-existent column?

### 3.5 String Functions
97. Explain the `regexp_extract()` function and its usage for pattern matching.
98. What is the difference between `regexp_extract()` and `regexp_replace()`?
99. How do you use `like()` and `rlike()` for pattern matching?
100. What is the difference between `like()`, `ilike()`, and `rlike()`?
101. Which pattern matching function is case-insensitive?
102. What pattern type does `rlike()` use (SQL wildcards or regex)?
103. What does `substring()` function do? What are its parameters?
104. How do you use `trim()`, `ltrim()`, and `rtrim()`?
105. What is `upper()`, `lower()`, `initcap()` used for?
106. How do you use `lpad()` and `rpad()` for padding strings?
107. What does `length()` function return for null values?
108. How do you check if a string contains a substring in Spark?

### 3.6 Date & Time Functions
109. What are the key date and time functions in Spark (current_date, current_timestamp, date_add, date_sub)?
110. How do you extract year, month, day from a date column?
111. What does `datediff()` function calculate?
112. How do you use `to_date()` and `to_timestamp()` for type conversion?
113. What is the difference between `unix_timestamp()` and `from_unixtime()`?
114. How do you handle different date formats when reading data?
115. What does `date_format()` function do?
116. How do you calculate the difference between two timestamps?
117. What is `add_months()` function used for?
118. How do you get the last day of the month using `last_day()`?
119. What does `next_day()` function do?
120. How do you handle timezone conversions in Spark?

### 3.6.1 Date & Time Intervals in Spark
121. What are the two main interval families in Spark (YEAR-MONTH and DAY-TIME)?
122. When do you use YEAR-MONTH interval vs DAY-TIME interval?
123. Why can't you directly cast a day interval to a month interval?
124. What is the common approximation used when converting between interval types?
125. What is `make_interval()` function? What makes it unique?
126. What parameters can you specify in `make_interval()`?
127. When would you use `make_interval()` over other interval functions?
128. What is `make_dt_interval()` function? What is its specific purpose?
129. What units does `make_dt_interval()` handle?
130. When would you use `make_dt_interval()` instead of `make_interval()`?
131. What is `make_ym_interval()` function? What is its specific purpose?
132. How does `make_ym_interval()` handle variable month lengths correctly?
133. When would you use `make_ym_interval()` for calendar-based calculations?
134. Compare `make_interval()` vs `make_dt_interval()` vs `make_ym_interval()` - when to use each?

### 3.6.2 Date Parsing & Formatting
135. What are the two main approaches to parsing dates in Spark SQL?
136. What date format does default `DATE()` or `CAST AS DATE` reliably support?
137. What happens when you use `DATE()` on non-ISO format strings?
138. When must you use `TO_DATE(expr, format)` instead of `DATE()`?
139. What format patterns are commonly used with `TO_DATE()`?
140. Are format pattern letters case-sensitive in `TO_DATE()`? Provide examples.
141. What is the difference between 'MM' and 'MMM' in date format patterns?
142. What is the difference between 'd', 'dd', and 'D' in date format patterns?
143. How does `DATE()` handle timestamp strings with time components?
144. What does `TO_DATE()` return for unparseable strings?
145. What are best practices for handling date formats in Spark pipelines?
146. What is `to_char()` function used for?
147. How do you use `to_timestamp()` with custom formats?
148. What is the Java DateTimeFormatter pattern syntax used in Spark?

### 3.7 Aggregate Functions
149. What is the difference between `sum()`, `sumDistinct()`, and `approx_count_distinct()`?
150. When would you use `approx_count_distinct()` instead of `countDistinct()`?
151. What is the difference between `approx_count_distinct()` and `count_min_sketch()`?
152. What does `approx_count_distinct()` measure vs `count_min_sketch()`?
153. Which function gives direct results and which returns serialized binary data?
154. What does `avg()` return for null values?
155. How do you use `min()` and `max()` functions?
156. What is `stddev()` and `variance()` used for?
157. What does `corr()` function calculate (correlation)?
158. How do you use `percentile_approx()` function?
159. What is `grouping()` and `grouping_id()` used for in GROUP BY operations?
160. What does `grouping(col)` return when a column is aggregated?
161. What does `grouping(col)` return when a column is present in the grouping level?
162. What does `grouping_id()` return and how is it calculated?
163. What is a bitmask in the context of `grouping_id()`?
164. When should you use `grouping(col)` vs `grouping_id()`?
165. What is the difference between `GROUP BY` and `GROUP BY WITH ROLLUP`?
166. How does `ROLLUP` create hierarchical aggregations?
167. How does `GROUP BY WITH ROLLUP` handle NULL values differently?

### 3.7.1 Aggregation After GroupBy - Critical Distinction
168. Can you use `select()` after `groupBy()`? Why or why not?
169. What object type does `groupBy()` return?
170. What methods are available on a GroupedData object?
171. What is the difference between DataFrame methods and GroupedData methods?
172. Can you use `agg()` on a regular DataFrame (without groupBy)?
173. Are `agg()` and `select()` interchangeable on a regular DataFrame?
174. What is the only way to perform aggregations after `groupBy()`?
175. Why does `df.groupBy("col").select(sum("value"))` fail?
176. What is the correct syntax for aggregation after groupBy?

### 3.7.2 ROLLUP and CUBE - Advanced Grouping
177. What is the basic purpose of `rollup()` vs `groupBy()`?
178. How many aggregation levels does `rollup()` create?
179. What is the formula for number of result rows in `rollup()`?
180. What is the basic purpose of `cube()` vs `rollup()`?
181. How many combinations does `cube()` create?
182. What is the formula for number of combinations in `cube()` (2^n)?
183. Which is faster: `groupBy()`, `rollup()`, or `cube()`?
184. When would you use `rollup()` over `groupBy()`?
185. When would you use `cube()` over `rollup()`?
186. How do NULL values indicate aggregation levels in `rollup()` and `cube()`?
187. What is the difference between hierarchical relationships in `rollup()` vs `cube()`?
188. What are typical use cases for `rollup()` (financial reports, organizational hierarchies)?
189. What are typical use cases for `cube()` (business intelligence, cross-analysis)?
190. How does `grouping_id()` help identify aggregation levels in `rollup()` and `cube()`?

### 3.7.3 SQL Database Support for ROLLUP and CUBE
191. Which major SQL databases support `ROLLUP`?
192. Which major SQL databases support `CUBE`?
193. Does MySQL fully support `ROLLUP` and `CUBE`?
194. What is the MySQL syntax for `ROLLUP` (WITH ROLLUP)?
195. Does SQLite support `ROLLUP` or `CUBE`?
196. What is the standard SQL syntax for `ROLLUP` and `CUBE`?
197. Do SQL Server, PostgreSQL, and Oracle support both `ROLLUP` and `CUBE`?
198. Does Spark SQL support `ROLLUP` and `CUBE` in both SQL and DataFrame API?
199. Do Trino and Databricks support `ROLLUP` and `CUBE`?
200. What additional grouping features does Spark SQL support (GROUPING SETS)?

### 3.8 Array Functions
201. How do you access array elements using `getItem()` or bracket notation?
202. What does `array()` function do to create arrays from columns?
203. How do you use `array_contains()` to check for element existence?
204. What does `array_distinct()` do?
205. How do you use `array_intersect()`, `array_union()`, `array_except()`?
206. What does `array_join()` do?
207. How do you sort array elements using `array_sort()`?
208. What is `array_max()`, `array_min()`, `size()` used for?
209. How do you use `flatten()` for nested arrays?
210. What does `array_repeat()` function do?
211. How do you use `slice()` to extract a portion of an array?
212. What is `array_position()` used for?
213. How do you remove elements from an array using `array_remove()`?
214. What does `shuffle()` do to array elements?
215. How do you use `zip_with()` for element-wise array operations?

### 3.8.1 Advanced Array Functions & Comparisons
216. What is the difference between `size()` and `cardinality()` functions?
217. Are `size()` and `cardinality()` functionally identical?
218. When would you use `size()` vs `cardinality()` (personal preference)?
219. What is the difference between `reverse()`, `sort_array()`, and `array_sort()`?
220. What parameters does `reverse()` accept? What does it do?
221. What parameters does `sort_array()` accept? How do you control sort order?
222. What parameters does `array_sort()` accept? What makes it unique?
223. Can you use custom sorting logic with `sort_array()`? What about `array_sort()`?
224. When would you use `sort_array()` vs `array_sort()`?
225. What does `aggregate()` function do on arrays?
226. What parameters does `aggregate()` accept (start, merge, finish)?
227. What is the difference between `aggregate()` and `reduce()` on arrays?
228. Are `aggregate()` and `reduce()` functionally identical?
229. Which name is SQL standard: `aggregate()` or `reduce()`?
230. What does `concat()` do for arrays? Can it handle multiple arrays?
231. What is the difference between `element_at()` and `try_element_at()`?
232. What happens when `element_at()` tries to access a non-existent index?
233. What does `try_element_at()` return for non-existent indices?
234. When should you use `try_element_at()` instead of `element_at()`?
235. What does `exists()` function do on arrays?
236. What does `forall()` function do on arrays?
237. What is the difference between `exists()` and `forall()`?
238. Do `exists()` and `forall()` short-circuit? What does this mean?
239. What does `filter()` function do on arrays?
240. What is the difference between `filter()` and `exists()`?
241. How is filtering arrays different from filtering DataFrames?
242. What does `transform()` function do on arrays?
243. What parameters does `transform()` lambda accept (element, index)?
244. What does `arrays_zip()` function do?
245. What does `zip_with()` function do?
246. What is the difference between `arrays_zip()` and `zip_with()`?
247. How many arrays can `arrays_zip()` handle?
248. How many arrays can `zip_with()` handle?
249. What output structure does `arrays_zip()` create?
250. Can you customize the output with `arrays_zip()`?
251. Does `zip_with()` require a lambda function?
252. How do `arrays_zip()` and `zip_with()` handle arrays of different lengths?

### 3.9 Map Functions
253. How do you create a map using `map()` function or `map_from_arrays()`?
254. How do you access map values using `getItem()` or bracket notation?
255. What does `map_keys()` and `map_values()` return?
256. How do you use `map_concat()` to merge maps?
257. What does `map_from_entries()` do?
258. How do you explode maps using `explode()` - what columns does it create?
259. What is `map_filter()` used for?
260. How do you get the size of a map using `size()`?

### 3.9.1 Map Functions Deep Dive & Comparisons
261. What is the difference between `filter()` and `map_filter()`?
262. What input types do `filter()` vs `map_filter()` accept?
263. How many lambda parameters does `map_filter()` accept?
264. What does `map_filter()` return?
265. What does `transform()` do for arrays?
266. What does `transform_keys()` do for maps?
267. What does `transform_values()` do for maps?
268. Compare `transform()` vs `transform_keys()` vs `transform_values()` - when to use each?
269. What lambda parameters does `transform()` accept?
270. What lambda parameters do `transform_keys()` and `transform_values()` accept?
271. Does `transform()` change the size of an array?
272. Does `transform_keys()` or `transform_values()` change the size of a map?
273. What changes when you use `transform_keys()` - keys or values?
274. What changes when you use `transform_values()` - keys or values?
275. Can you use `size()` and `cardinality()` on maps?
276. Does `element_at()` work on maps? How?
277. Does `try_element_at()` work on maps?

### 3.10 Struct Functions
278. How do you access struct fields using dot notation or `getField()`?
279. What does `struct()` function do to create structs from columns?
280. How do you flatten struct columns?
281. Can you use `withColumn()` to modify a field within a struct?
282. How do you select specific fields from a nested struct?

### 3.10.1 Struct Deep Dive & Comparisons
283. What is a Struct in Apache Spark?
284. What is the purpose of using StructType in DataFrames?
285. How do structs enable representation of nested or hierarchical data?
286. What is the difference between `struct()` and `named_struct()`?
287. How do you define field names in `named_struct()`?
288. What field names does `struct()` generate by default?
289. How do you access fields in a struct created with `named_struct()`?
290. What happens to field names when using `struct()` with column names vs literals?
291. When should you use `named_struct()` over `struct()`?
292. When should you use `struct()` over `named_struct()`?
293. What does the schema look like for `named_struct('city','value','state','value')`?
294. What does the schema look like for `struct('value1', 'value2')`?
295. Can you nest structs within structs?
296. How do you access deeply nested struct fields?

### 3.11 Type Conversion & Casting
297. How do you cast columns using `cast()` function?
298. What is the difference between `cast()` and `astype()`?
299. What happens when casting fails (e.g., string "abc" to integer)?
300. How do you handle casting errors gracefully?
301. What does `try_cast()` do in Spark SQL?

### 3.11.1 Numeric Type Casting Functions
302. What is `tinyint()` function and what data type does it cast to?
303. What is `smallint()` function and when would you use it?
304. What is the difference between `int()` and `bigint()` casting?
305. When should you use `tinyint` vs `smallint` vs `int` vs `bigint`?
306. What are the value ranges for tinyint, smallint, int, and bigint?

### 3.11.2 Other Specific Casting Functions
307. What does `binary()` function do?
308. What is `boolean()` casting function used for?
309. How do you use `date()` function for type casting?
310. What does `decimal()` function do?
311. What is the difference between `double()` and `float()` casting?
312. What does `string()` function do for type conversion?
313. How do you use `timestamp()` function?

### 3.11.3 Type Conversion (to_ Functions)
314. What is `to_char()` function? What does it convert from and to?
315. What is `to_varchar()` function used for?
316. What does `to_number()` function do? When do you use it?
317. What is the difference between `to_date()` and `date()` casting?
318. What is the difference between `to_timestamp()` and `timestamp()` casting?
319. What does `to_json()` function do? What data types can it convert?
320. What is `to_binary()` function used for?
321. When would you use `to_` functions vs direct casting with `cast()`?

### 3.11.4 FLOAT vs DOUBLE vs DECIMAL
322. What is the precision difference between FLOAT, DOUBLE, and DECIMAL?
323. How much storage does each numeric type use (FLOAT, DOUBLE, DECIMAL)?
324. What types of arithmetic do FLOAT and DOUBLE use (approximate vs exact)?
325. Do FLOAT and DOUBLE have rounding errors? What about DECIMAL?
326. Which numeric type is fastest for computations?
327. When should you use FLOAT or DOUBLE for data processing?
328. When should you ALWAYS use DECIMAL instead of FLOAT/DOUBLE?
329. Why is DECIMAL the only choice for financial and monetary data?
330. What is the maximum precision supported by DECIMAL in Spark?
331. What are the performance trade-offs between DECIMAL and FLOAT/DOUBLE?
332. Provide examples where using FLOAT/DOUBLE would cause problems in financial calculations.

### 3.12 Null Handling & Data Cleaning
333. What is the difference between `dropna()` and `fillna()`?
334. How do you drop rows with nulls in specific columns using `dropna(subset=[])`?
335. What are the different threshold options in `dropna()`?
336. How do you fill nulls with different values for different columns?
337. What does `na.replace()` do?
338. What is the critical difference between `na.replace()` and `na.fill()`?
339. Is `na.replace()` used for handling missing data or replacing existing values?
340. Can you use `na.replace()` to replace NULL values? Why or why not?
341. How do you use `isNull()` and `isNotNull()` for filtering?
342. What is `nanvl()` used for (NaN value handling)?
343. How do you distinguish between null and NaN in Spark?
344. What is the difference between NULL and NaN in terms of meaning and data types?
345. How do NULL and NaN behave differently in comparisons?
346. What does `dropDuplicates()` do? How do you specify subset of columns?
347. Does `dropDuplicates()` preserve the order of rows?

### 3.12.1 COALESCE, NVL, and NVL2 Functions
348. What does `COALESCE()` function do?
349. How many arguments can `COALESCE()` accept?
350. What does `NVL()` function do? How is it different from `COALESCE()`?
351. How many arguments does `NVL()` accept?
352. What does `NVL2()` function do?
353. What are the three arguments in `NVL2()` and what do they represent?
354. Compare `COALESCE()` vs `NVL()` vs `NVL2()` - when to use each?
355. Is `NVL()` a SQL standard function or Oracle compatibility function?
356. Can you use `COALESCE()` with more than 2 arguments? Provide an example.
357. What does `NVL2(NULL, 'Y', 'N')` return?
358. What does `NVL(NULL, 'X')` return?
359. How would you replicate `NVL2()` behavior using `CASE WHEN`?

### 3.13 Column Expressions & SQL Functions
360. What is the difference between using column names as strings vs Column objects (col(), F.col())?
361. When must you use `col()` or `F.col()` instead of string column names?
362. What does `expr()` function allow you to do?
363. How do you reference columns from different DataFrames after a join?
364. What is the `alias()` method used for?
365. What does `name()` method return for a Column object?

### 3.14 Conditional Logic & Case Statements
366. How do you create complex conditional logic using `when().when().otherwise()`?
367. What happens if you don't provide an `otherwise()` clause?
368. How do you implement SQL CASE WHEN logic in PySpark?
369. Can you nest `when()` conditions? Provide an example?

### 3.15 JSON Functions
370. What is the difference between JSON as a file vs JSON as a column value?
371. Why does Spark convert JSON to Structs (not Maps) by default when parsing?
372. What are the performance implications of Struct vs Map for JSON data?
373. How do you parse JSON strings using `from_json()`?
374. What schema do you need to provide for `from_json()`?
375. How do you convert structs to JSON using `to_json()`?
376. What is the difference between `from_json()` and `to_json()`?
377. What does `get_json_object()` do?
378. How do you use `json_tuple()` to extract multiple fields?
379. What is the difference between `from_json()` and `json_tuple()`?
380. What is the difference between `from_json()` and `get_json_object()` in terms of efficiency?
381. When should you use `from_json()` vs `get_json_object()`?
382. What does `schema_of_json()` function do?
383. What does `json_array_length()` return?
384. What does `json_object_keys()` return?

### 3.16 Advanced Column Operations
385. What does `lit()` function do? When do you use it?
386. How do you create a column with constant values across all rows?
387. What is `input_file_name()` function used for?
388. How do you use `spark_partition_id()` to see data distribution?
389. What does `hash()` function compute?
390. What is `md5()` and `sha1()` used for?
391. How do you use `crc32()` for checksums?
392. What does `base64()` and `unbase64()` do?
393. How do you generate random values using `rand()` and `randn()`?

### 3.17 Set Operations on DataFrames
394. What is the difference between `union()` and `unionAll()`?
395. What is the critical inconsistency between DataFrame API and Spark SQL for union operations?
396. In DataFrame API, do `union()` and `unionAll()` keep or remove duplicates?
397. In Spark SQL, does `UNION` keep or remove duplicates?
398. In Spark SQL, does `UNION ALL` keep or remove duplicates?
399. Why is this inconsistency important to remember?
400. What does `unionByName()` do? How is it different from `union()`?
401. What does `unionByName()` do when schemas differ between DataFrames?
402. What is the `allowMissingColumns` parameter in `unionByName()`?
403. What does `unionByName(allowMissingColumns=True)` enable?
404. When would you use `union()` vs `unionByName()`?
405. What is "strict mode" vs "flexible mode" vs "forgiving mode" for unions?
406. How do you use `intersect()` to find common rows?
407. What is the difference between `intersect()` and `intersectAll()`?
408. Does `intersect()` show unique or all common records?
409. Does `intersectAll()` show unique or all common records?
410. How does `intersectAll()` handle duplicate counts?
411. What does `intersect()` answer vs `intersectAll()`?
412. When would you use `intersect()` vs `intersectAll()`?
413. What does `subtract()` (or `exceptAll()`) do?
414. Do set operations require the same schema in both DataFrames?
415. How do set operations handle duplicates?

### 3.18 Comparison & Logical Operators
416. What is the difference between `=` and `<=>` (null-safe equality)?
417. How does `=` handle NULL comparisons?
418. How does `<=>` handle NULL comparisons?
419. When should you use `<=>` instead of `=`?
420. What is the DataFrame API equivalent of `<=>`?
421. Explain the AND/OR truth table with NULL values.
422. What does `TRUE AND NULL` return?
423. What does `FALSE OR NULL` return?
424. What is short-circuit evaluation in AND/OR operations?

### 3.19 Window Functions
425. What is `rowsBetween` in window functions? Provide examples.
426. What is `rangeBetween` in window functions? How does it differ from `rowsBetween`?
427. Does data shuffling occur during window function operations? Why or why not?
428. What is the difference between `CUME_DIST()` and `PERCENT_RANK()`?
429. What does `CUME_DIST()` calculate?
430. What does `PERCENT_RANK()` calculate?
431. When would you use `CUME_DIST()` vs `PERCENT_RANK()`?
432. What is `asc_nulls_first` vs `asc_nulls_last` in ordering?
433. Where do NULLs appear with `asc_nulls_first`?
434. Where do NULLs appear with `asc_nulls_last`?

### 3.20 DataFrame Gotchas & Common Pitfalls
435. Why does chaining multiple `withColumn()` calls have performance implications?
436. What is the better alternative to multiple `withColumn()` calls?
437. When joining two tables with the same column name (e.g., 'id'), why does `select("*")` work but `select("id")` throws an "ambiguous column" error?
438. How do you resolve column name ambiguity after joins?
439. What happens when you call an action multiple times on the same DataFrame? Is it recomputed?
440. Why should you be careful with `collect()` on large datasets?
441. What is the difference between `df.count()` and `df.select(count("*"))`?
442. Can you modify a DataFrame in place? Why or why not?
443. What happens when you try to access a column that doesn't exist?
444. Why might `df.show()` show different results than the actual data?
445. What is the behavior of `limit()` - does it guarantee which rows are returned?
446. How do column name case sensitivity work in Spark (spark.sql.caseSensitive)?

### 3.21 Performance Tips for DataFrame Operations
447. Why is it better to filter data early in your transformation pipeline?
448. What is the performance difference between `filter()` and `where()` (trick question)?
449. When should you use `repartition()` vs `coalesce()`?
450. What is the performance impact of using UDFs vs built-in functions?
451. Why is `reduceByKey()` preferred over `groupByKey()` in RDD operations?
452. How does column pruning (selecting only needed columns) improve performance?
453. What is predicate pushdown and how does it improve query performance?
454. Why should you avoid using `count()` unnecessarily in your code?

### 3.22 Performance Optimization Best Practices
455. What is the optimal partition size for Spark processing (128MB-256MB)?
456. How do you determine the right number of partitions for your data?
457. What is the formula: optimal_partitions = total_data_size / target_partition_size?
458. Why is it important to avoid small files in distributed processing?
459. What is the small file problem and its performance impact?
460. How do you consolidate small files before processing?
461. What is file compaction and when should you perform it?
462. How does data skewness affect query performance?
463. What are the symptoms of data skew in Spark UI?
464. How do you identify skewed partitions in Spark UI?
465. What is the difference between task duration for skewed vs balanced partitions?
466. What is salting technique for handling data skew?
467. How do you implement salting for skewed join keys?
468. What is broadcast salting and when do you use it?
469. How does adding random salt keys help distribute skewed data?
470. What is isolated salting vs full salting?
471. How many salt keys should you add (multiplicative factor)?
472. What is the performance cost of salting?
473. When should you avoid salting?
474. What is adaptive execution and how does it handle skew automatically?
475. How do you optimize wide transformations (joins, groupBy, repartition)?
476. What is shuffle optimization and why is it critical?
477. How does reducing shuffle improve performance?
478. What is map-side combine and how does it reduce shuffle?
479. What is the difference between `reduceByKey` and `groupByKey`?
480. Why does `reduceByKey` perform better than `groupByKey`?
481. How does `reduceByKey` reduce data transfer?
482. What is combiner logic in map-side operations?
483. When should you use `aggregateByKey` instead of `reduceByKey`?
484. How do you optimize aggregations to minimize shuffle?
485. What is partial aggregation and how does it work?
486. How does `spark.sql.shuffle.partitions` affect aggregation performance?
487. What is the relationship between parallelism and shuffle partitions?
488. How many cores should process each partition ideally (2-4 partitions per core)?
489. What happens if you have too many partitions?
490. What happens if you have too few partitions?
491. How do you balance between parallelism and overhead?
492. What is task serialization overhead?
493. What is task scheduling overhead?
494. How does task scheduling delay affect small tasks?
495. What is the minimum task duration to justify distributed processing?
496. How do you optimize very short tasks (< 100ms)?
497. What is task consolidation and when should you use it?
498. How does broadcast join eliminate shuffle?
499. When should you broadcast the smaller table?
500. What is the maximum size for broadcast (driver memory constraint)?
501. How do you calculate broadcast size vs executor memory?
502. What is the 20% rule for broadcast size?
503. How does bucketing eliminate shuffle in joins?
504. What is pre-shuffling data using bucketing?
505. How do bucketed tables avoid sort-merge join shuffle?
506. What is the cost of creating bucketed tables?
507. When is bucketing worth the upfront cost?
508. How do you verify bucketing is being used in joins?
509. What is partition pruning and how does it reduce data scanning?
510. How does partitioning by column enable pruning?
511. What is the difference between partition pruning and predicate pushdown?
512. How do you optimize for partition pruning?
513. What is dynamic partition pruning (DPP) vs static pruning?
514. How does caching improve performance for iterative algorithms?
515. When should you cache intermediate results?
516. When is caching wasteful (single-use data)?
517. How do you determine what to cache in a multi-stage job?
518. What is the cost of caching (memory usage)?
519. How do you measure cache effectiveness (cache hit ratio)?
520. What is checkpointing and when should you use it vs caching?
521. How does checkpointing break lineage?
522. What is the performance benefit of breaking long lineages?
523. When does long lineage cause performance problems?
524. How do you identify long lineage issues?
525. What is lineage recomputation overhead?
526. How does checkpointing prevent recomputation?
527. What is the cost of checkpointing (disk I/O)?
528. Where should you place checkpoint directory (HDFS, S3)?
529. How do you optimize filter ordering in chained operations?
530. What is the most selective filter and why should it come first?
531. How does filter selectivity affect downstream operations?
532. What is the benefit of filtering before expensive operations (joins, aggregations)?
533. How do you calculate filter selectivity ratio?
534. How does column selection (projection) affect performance?
535. Why should you select only required columns early?
536. What is the I/O savings from column pruning?
537. How does columnar format (Parquet) benefit from column pruning?
538. What is the memory savings from selecting fewer columns?
539. How do you optimize expensive string operations?
540. Why are string operations slower than numeric operations?
541. How does data type affect processing speed?
542. Should you convert strings to numeric types when possible?
543. What is the performance impact of wide rows (many columns)?
544. How do you optimize schemas with hundreds of columns?
545. What is the benefit of nested structures vs flat schemas?
546. How do complex types (arrays, maps, structs) affect performance?
547. When should you denormalize vs normalize data?
548. What is the performance trade-off in denormalization?
549. How does avoiding UDFs improve performance (2-10x faster)?
550. Why are built-in functions faster than UDFs?
551. What optimizations can Catalyst apply to built-in functions?
552. Why can't Catalyst optimize UDFs?
553. What is the serialization overhead in UDFs?
554. When is UDF usage unavoidable?
555. How do you minimize UDF performance impact?
556. What is Pandas UDF (vectorized UDF) and how is it faster?
557. How much faster are Pandas UDFs compared to regular UDFs (3-100x)?
558. When should you use Pandas UDF instead of regular UDF?
559. How do you optimize data serialization (Kryo vs Java)?
560. How much faster is Kryo serialization (2-10x)?
561. When does serialization become a bottleneck?
562. How does serialization affect shuffle performance?
563. How does serialization affect caching efficiency?
564. What is compression and how does it affect performance?
565. What compression codecs are available (snappy, gzip, lzo, lz4)?
566. What is the trade-off between compression ratio and speed?
567. When should you use snappy (balanced, default)?
568. When should you use gzip (maximum compression)?
569. When should you use lz4 (fastest)?
570. How does compression affect I/O vs CPU trade-off?
571. When is compression counterproductive?
572. How do you optimize file formats for your workload?
573. Why is Parquet preferred for analytics (columnar, compressed)?
574. When should you use ORC instead of Parquet?
575. When should you use Avro (schema evolution, streaming)?
576. Why should you avoid CSV and JSON in production?
577. What is the performance difference between text and binary formats (5-20x)?
578. How does file format affect predicate pushdown?
579. How does file format affect compression efficiency?
580. What is the optimal file size for Spark (128MB-1GB)?
581. How do you control output file size?
582. What is `maxRecordsPerFile` and how do you set it?
583. How many files should each partition generate ideally (1 file)?
584. What happens if partitions generate too many small files?
585. How do you consolidate files after writing?
586. What is file coalescing vs file compaction?
587. How do you use `coalesce()` to control output files?
588. What is the difference between `repartition()` and `coalesce()` for file output?
589. When should you repartition before writing?
590. What is the cost of repartition (full shuffle)?
591. How do you optimize write parallelism?
592. What is the relationship between write parallelism and output files?
593. How do you balance write speed vs file count?

### 3.23 Advanced Transformations
594. What is the difference between `map()` and `flatMap()` methods?
595. When would you use `map()` vs `flatMap()`?
596. What is the `cogroup()` operation and how does it differ from join operations?
597. How do you use `mapPartitions()` and when is it more efficient than `map()`?
598. What does `foreachPartition()` do and how is it different from `foreach()`?
599. What is `transform()` method on DataFrames used for?
600. How do you use `pivot()` to reshape data from long to wide format?
601. What does `unpivot()` or `melt()` do (wide to long format)?
602. What is `cube()` operation in GROUP BY?
603. How does `rollup()` differ from `cube()`?
604. What does `groupingSets()` allow you to do?

### 3.24 Function Comparisons & When to Use What
605. `count()` vs `size()` - when to use each?
606. `distinct()` vs `dropDuplicates()` - are they the same?
607. `agg()` vs direct aggregation functions - when to use which approach?
608. `select()` vs `selectExpr()` vs `withColumn()` - comparison and use cases
609. `filter()` vs `where()` - is there any difference?
610. `join()` vs `crossJoin()` - when would you use crossJoin?
611. `union()` vs `unionAll()` vs `unionByName()` - key differences
612. `orderBy()` vs `sort()` - are they the same?
613. `repartition()` vs `coalesce()` - when to use which?
614. `cache()` vs `persist()` - what's the difference?
615. `collect()` vs `take()` vs `head()` - comparison
616. `first()` vs `head()` vs `take(1)` - subtle differences
617. `sample()` vs `sampleBy()` - when to use stratified sampling?
618. `approx_count_distinct()` vs `countDistinct()` - accuracy vs performance trade-off
619. `groupBy()` with `agg()` vs `groupBy()` with direct aggregation
620. Window functions vs GROUP BY - when to use which approach?

### 3.25 Sampling Methods - Comprehensive Comparison
621. What is simple random sampling in Spark?
622. What is stratified random sampling in Spark?
623. What does `sample(withReplacement, fraction, seed)` do?
624. What does `sampleBy(col, fractions, seed)` do?
625. What does `randomSplit(weights, seed)` do?
626. How does `sample()` control sampling - dataset level or group level?
627. How does `sampleBy()` control sampling - dataset level or group level?
628. What does `sampleBy()` return - single or multiple DataFrames?
629. What does `randomSplit()` return - single or multiple DataFrames?
630. Does `sample()` maintain group proportionality?
631. Does `sampleBy()` maintain group proportionality?
632. When would you use `sample()` for quick random subsets?
633. When would you use `sampleBy()` for representative samples by category?
634. When would you use `randomSplit()` for train/validation/test splits?
635. Provide an example of using `sampleBy()` with department-wise sampling.

### 3.26 Repartitioning Methods - Complete Analysis
636. What does `repartition(N)` do conceptually?
637. What does `repartition("col")` do conceptually?
638. What does `repartition(N, "col")` do conceptually?
639. How does `repartition(N)` distribute data - randomly or by hash?
640. How does `repartition("col")` distribute data - randomly or by hash?
641. What is the default number of partitions for `repartition("col")`?
642. How does `repartition(N, "col")` control partition count?
643. Does `repartition(N)` guarantee data locality?
644. Does `repartition("col")` place same column values in same partition?
645. What is the data skew risk for `repartition(N)`?
646. What is the data skew risk for `repartition("col")`?
647. When does `repartition("col")` enable partition pruning?
648. When does `repartition(N, "col")` enable partition pruning?
649. When would you use `repartition(N)` for general load balancing?
650. When would you use `repartition("col")` before filtering on that column?
651. When would you use `repartition(N, "col")` before writing partitioned data?
652. What is the difference between `repartition()` and `repartitionByRange()`?
653. What partitioning method does `repartition()` use?
654. What partitioning method does `repartitionByRange()` use?
655. Does `repartitionByRange()` order values within range boundaries?
656. When would you use `repartitionByRange()` over `repartition()`?

### 3.27 Repartition vs Coalesce - Critical Decision Guide
657. What is the core difference between `repartition()` and `coalesce()`?
658. Does `repartition()` perform a full shuffle?
659. Does `coalesce()` perform a full shuffle?
660. Can `repartition()` increase partition count?
661. Can `coalesce()` increase partition count?
662. Which method guarantees perfect data balance - `repartition()` or `coalesce()`?
663. When is `repartition()` essential (not optional) for preventing data skew?
664. When is `repartition()` essential for memory management and OOM prevention?
665. When is `repartition()` essential for optimizing cluster utilization?
666. When is `repartition()` essential for performance-critical operations?
667. When should you use `coalesce()` after filter operations?
668. When should you use `coalesce()` for writing to storage?
669. What is the execution speed difference between `repartition()` and `coalesce()`?
670. What is the network I/O cost of `repartition()` vs `coalesce()`?
671. What is the data balance quality of `repartition()` vs `coalesce()`?
672. What is the job reliability of `repartition()` vs `coalesce()`?
673. When does `coalesce()` risk data skew or OOM errors?
674. Should you choose `coalesce()` for speed or `repartition()` for reliability?
675. What are critical decision points for using `repartition()`?
676. What are critical decision points for using `coalesce()`?

### 3.28 Caching and Persistence - Deep Dive
677. What is `cache()` method in Spark?
678. What storage level does `cache()` use by default?
679. Is `cache()` lazy or eager evaluation?
680. When does cached data actually get stored - at cache() call or first action?
681. What happens to cached data when memory is full?
682. What is LRU eviction in caching?
683. When should you use `cache()` for multiple actions on same DataFrame?
684. When should you use `cache()` for iterative algorithms?
685. When should you avoid `cache()` for single-use DataFrames?
686. When should you avoid `cache()` in memory-constrained environments?
687. What is the difference between `cache()` and `persist()` in terms of flexibility?
688. Can you customize storage level with `cache()`?
689. Can you customize storage level with `persist()`?
690. What are the available storage levels in Spark?
691. What is MEMORY_ONLY storage level?
692. What is MEMORY_AND_DISK storage level?
693. What is MEMORY_ONLY_SER storage level?
694. What is MEMORY_AND_DISK_SER storage level?
695. What is DISK_ONLY storage level?
696. What is OFF_HEAP storage level?
697. What storage levels support replication (_2 suffix)?
698. How do you unpersist cached data?
699. Is there a separate `uncache()` method?
700. Does `unpersist()` work for both `cache()` and `persist()`?

### 3.29 Checkpoint - Reliability and Fault Tolerance
701. What is `checkpoint()` in Spark?
702. What is the main purpose of checkpointing?
703. Where does `checkpoint()` save data?
704. Does `checkpoint()` break the lineage graph?
705. What is the difference between `checkpoint()` and `localCheckpoint()`?
706. Where does `checkpoint()` save data - reliable storage or local?
707. Where does `localCheckpoint()` save data - reliable storage or local?
708. Does data survive driver/executor failures with `checkpoint()`?
709. Does data survive driver/executor failures with `localCheckpoint()`?
710. When should you use `checkpoint()` for long transformation chains?
711. When should you use `checkpoint()` for iterative algorithms?
712. When should you avoid `checkpoint()` for simple, fast transformations?
713. When should you avoid `checkpoint()` when storage is limited?
714. What is the performance cost of checkpointing?
715. Where should you configure the checkpoint directory?

### 3.30 Pandas Integration
716. What does `toPandas()` do in Spark?
717. Where does data move when you call `toPandas()`?
718. What are the memory implications of `toPandas()`?
719. When should you use `toPandas()` for visualization?
720. When should you use `toPandas()` for small results after aggregation?
721. When should you avoid `toPandas()` for large datasets?
722. When should you avoid `toPandas()` in production pipelines?
723. What is the risk of out-of-memory errors with `toPandas()`?
724. What is `pandas_api()` in Spark?
725. Where does data stay with `pandas_api()` - local or distributed?
726. What is the difference between `toPandas()` and `pandas_api()` in terms of data location?
727. What is the difference between `toPandas()` and `pandas_api()` in terms of processing?
728. What is the maximum data size for `toPandas()` - RAM limited or terabytes?
729. What is the maximum data size for `pandas_api()` - RAM limited or terabytes?
730. Does `toPandas()` have full pandas compatibility?
731. Does `pandas_api()` have full pandas compatibility?
732. When should you use `toPandas()` for Python ML libraries?
733. When should you use `pandas_api()` for big data processing?
734. What is the strategic usage pattern: Process in Spark → Convert to Pandas → Use Python ecosystem?

### 3.31 Temporary Views and SQL Integration
735. What is a temporary view in Spark?
736. How do you create a temporary view?
737. What is the scope of a temporary view - session or application?
738. How long does a temporary view last?
739. What is a global temporary view in Spark?
740. How do you create a global temporary view?
741. What is the scope of a global temporary view - session or application?
742. How do you reference a temporary view in SQL?
743. How do you reference a global temporary view in SQL?
744. What is the SQL syntax for accessing a global temporary view (global_temp.view_name)?
745. When should you use temporary views for single-session work?
746. When should you use global temporary views for cross-session sharing?
747. Can multiple sessions access a temporary view?
748. Can multiple sessions access a global temporary view?

### 3.32 Miscellaneous DataFrame Operations
749. What does `freqItems()` function do in Spark?
750. What is the default threshold for `freqItems()`?
751. What does support = 0.01 mean in `freqItems()`?
752. What values are included when threshold is 1%?
753. What values are excluded when threshold is 1%?
754. When would you use `freqItems()` for pattern mining?

## 4. Spark Collections - Deep Dive

### 4.1 Collections Overview & Fundamentals
755. What are collections in Apache Spark?
756. What are the two main collection types in Spark (ArrayType and MapType)?
757. What is ArrayType? What kind of data does it store?
758. What is MapType? What kind of data does it store?
759. Are Structs considered collections in Spark? Why or why not?
760. What collection functions work on Arrays?
761. What collection functions work on Maps?
762. Do collection functions work on Structs?
763. What is the purpose of using collections in DataFrames?
764. How do collections enable efficient management of semi-structured data?

### 4.2 Map vs Struct - Critical Comparison
765. What is the key difference between StructType and MapType?
766. Are field names in Structs fixed or dynamic?
767. Are keys in Maps fixed or dynamic?
768. When are field names in Structs defined?
769. Can different rows in a Map column have different keys?
770. How do you access a Struct field?
771. How do you access a Map value?
772. When should you use Structs over Maps?
773. When should you use Maps over Structs?
774. Do Struct fields have a fixed order?
775. Is key order guaranteed in Maps?
776. Provide an example use case for Structs.
777. Provide an example use case for Maps.
778. What happens when you know all attributes upfront - Struct or Map?
779. What happens when keys are variable or semi-structured - Struct or Map?
780. Can you have optional fields in Structs?
781. Can you have optional keys in Maps?
782. Compare schema rigidity: Struct vs Map.

### 4.3 Array vs Map - Comparison
783. What is the key difference between ArrayType and MapType?
784. Does ArrayType maintain order?
785. Is order guaranteed in MapType?
786. What is ArrayType best used for?
787. What is MapType best used for?
788. Can array elements be of different types?
789. Can map values be of different types?
790. How do you access array elements by position?
791. How do you access map values by key?

### 4.4 Advanced Collection Operations & Nested Data
792. How do you work with nested data structures in Spark?
793. What are the performance implications of deeply nested schemas?
794. How do you flatten nested structures?
795. When should you denormalize data vs keep it normalized in Spark?
796. How do you handle schema evolution with complex types?
797. Can you have arrays of structs?
798. Can you have maps of arrays?
799. Can you have arrays of maps?
800. How do you query nested arrays of structs?
801. What is the performance impact of deeply nested collections?

### 4.5 Comprehensive Collection Functions Reference
802. Which functions return the number of elements in a collection?
803. What collections support `size()` and `cardinality()`?
804. What is the difference between `reverse()`, `sort_array()`, and `array_sort()` in terms of purpose?
805. Which sorting function allows custom comparator logic?
806. What is the SQL standard name for array reduction: `aggregate()` or `reduce()`?
807. What does `concat()` do and does it support multiple arrays?
808. What is the difference between `element_at()` and `try_element_at()` in error handling?
809. Which function checks if AT LEAST ONE element matches a condition?
810. Which function checks if ALL elements match a condition?
811. Do `exists()` and `forall()` short-circuit? What does this mean for performance?
812. What is the difference between `filter()` (for arrays) and `map_filter()` (for maps)?
813. How many lambda parameters does `map_filter()` require?
814. What does `transform()` work on - Arrays or Maps?
815. What does `transform_keys()` work on - Arrays or Maps?
816. What does `transform_values()` work on - Arrays or Maps?
817. How many arrays does `arrays_zip()` support?
818. How many arrays does `zip_with()` support?
819. What output structure does `arrays_zip()` create?
820. Does `zip_with()` require a lambda function?
821. What happens to shorter arrays when using `arrays_zip()` or `zip_with()`?
822. Which collection functions support both Arrays and Maps?
823. Which functions are functionally identical pairs (have same behavior)?
824. What is the purpose of having both `size()` and `cardinality()` if they're identical?
825. What is the purpose of having both `aggregate()` and `reduce()` if they're identical?

## 5. User-Defined Functions (UDFs)

### 5.1 UDF Registration & Usage
826. How do you register a UDF for use in DataFrame functions?
827. How do you register a UDF for use in SQL expressions?
828. When is a UDF available in the Spark catalog?
829. How do you list all registered functions using `spark.catalog.listFunctions()`?
830. What are the performance implications of UDFs compared to built-in functions?

## 6. Data Sources & I/O Operations

### 6.1 Reading Data - Basics
831. What is the difference between `spark.read.table()` and `spark.read.parquet()`?
832. What does the `read.option('samplingRatio', 'true')` do during schema inference?
833. What is the `option('dateFormat', 'fmt')` used for? What are common date format patterns?
834. How do you handle corrupted or malformed rows when reading CSV files?
835. How do you achieve parallelism when reading from non-partitioned data files?
836. What are the different Spark data sources and sinks available?
837. What is the findspark library and when do you use it?

### 6.1.1 CSV Reading Options & Gotchas
838. What does `option('header', 'true')` do when reading CSV files?
839. What is `option('inferSchema', 'true')` and what are its performance implications?
840. How do you specify custom delimiters using `option('sep', ',')`?
841. What does `option('quote', '"')` control?
842. How do you handle multi-line records using `option('multiLine', 'true')`?
843. What does `option('escape', '\\')` do?
844. What is `option('nullValue', 'NULL')` used for?
845. How does `option('mode', 'PERMISSIVE')` differ from 'DROPMALFORMED' and 'FAILFAST'?
846. What is `option('columnNameOfCorruptRecord', '_corrupt_record')` used for?
847. How do you handle files with different encodings using `option('encoding', 'UTF-8')`?
848. What does `option('ignoreLeadingWhiteSpace', 'true')` and `option('ignoreTrailingWhiteSpace', 'true')` do?
849. Why might you get different results with `inferSchema=true` on partial data?

### 6.1.2 JSON Reading Options
850. What is `option('multiLine', 'true')` important for when reading JSON?
851. How does JSON schema inference work differently from CSV?
852. What does `option('primitivesAsString', 'true')` do?
853. How do you handle JSON files with inconsistent schemas?

### 6.1.3 Parquet Reading Options
854. Does Parquet require schema inference? Why or why not?
855. What is `option('mergeSchema', 'true')` used for in Parquet?
856. How does Parquet handle predicate pushdown?
857. What are the advantages of columnar storage in Parquet for read performance?

### 6.1.4 ORC & Avro Reading
858. How does ORC compare to Parquet for read performance?
859. What is Avro's advantage for schema evolution?
860. When would you choose ORC over Parquet?

### 6.1.5 JDBC Reading Options
861. How do you read from JDBC sources?
862. What is `option('partitionColumn', 'id')` used for in JDBC reads?
863. How do you specify `lowerBound`, `upperBound`, and `numPartitions` for parallel JDBC reads?
864. What does `option('fetchsize', '1000')` control?
865. What are the performance implications of JDBC reads without proper partitioning?

### 6.2 Writing Data - Basics & Options
866. What is the Sink API in Spark?
867. What does `maxRecordsPerFile` control when writing DataFrames?
868. How do you estimate appropriate values for `maxRecordsPerFile`?
869. What are reasonable file sizes for Spark write operations in production?
870. Why might the number of DataFrame partitions not match the number of output file partitions?
871. Can DataFrame partitions be empty? What impact does this have on output files?
872. What are .crc files in Spark output directories and what is their purpose?

### 6.2.1 Write Modes
873. What are the different save modes: append, overwrite, errorIfExists, ignore?
874. What happens if you use 'overwrite' mode - does it delete the entire directory or just data files?
875. What is the difference between static and dynamic overwrite modes?
876. How do you enable dynamic partition overwrite?
877. What are the risks of using 'overwrite' mode in production?

### 6.2.2 Write Format Options - CSV
878. What options are available when writing CSV files?
879. How do you specify custom delimiters when writing CSV?
880. What does `option('header', 'true')` do when writing CSV?
881. How do you control quote characters and escape characters in CSV writes?
882. What is `option('compression', 'gzip')` used for? What compression codecs are supported?

### 6.2.3 Write Format Options - Parquet
883. What compression codecs are supported for Parquet (snappy, gzip, lzo, brotli, etc.)?
884. What is the default compression for Parquet in Spark?
885. What does `option('mergeSchema', 'true')` do when writing Parquet?
886. How do you control Parquet block size and page size?
887. What are the trade-offs between compression ratio and write/read performance?

### 6.2.4 Write Format Options - JSON
888. What does `option('compression', 'gzip')` do for JSON writes?
889. Can you write nested structures to JSON?
890. How does JSON write performance compare to Parquet?

### 6.2.5 Write Format Options - ORC & Delta
891. What are the advantages of writing to ORC format?
892. What compression options are available for ORC?
893. What are Delta Lake's advantages over Parquet for writes (ACID, time travel)?
894. How do you write to Delta format?

### 6.3 Partitioning During Writes
895. What is the difference between `repartition(n)` and `partitionBy(col)` when writing DataFrames?
896. How does `repartition(n)` organize output at the directory level?
897. How does `partitionBy(col)` organize output at the directory level?
898. How does `partitionBy(col)` enable partition pruning in subsequent reads?
899. What is the relationship between parallelism and partition pruning when using these methods?
900. Can you use both `repartition()` and `partitionBy()` together? What happens?
901. What are the downsides of over-partitioning when writing data?
902. What is the small file problem and how does it relate to partitioning?
903. How many files should each partition ideally contain?
904. What is partition explosion and how do you avoid it?

### 6.4 Bucketing
905. What is bucketing in Spark? How do you use `bucketBy()` when writing data?
906. How does bucketing work: bucket numbers, columns, and hash functions?
907. What is the purpose of using `sortBy()` in combination with `bucketBy()`?
908. How does bucketing with sorting optimize sort-merge joins by eliminating shuffle?
909. Can you use `bucketBy()` with `partitionBy()` together?
910. What are the limitations of bucketing?
911. How do you read bucketed tables to take advantage of bucketing?
912. What happens if you change the number of buckets after writing data?

## 7. File Formats & Storage Systems

### 7.1 Storage Systems
913. What is the difference between distributed file storage systems and normal storage systems?
914. What is a Spark data lake?
915. What is HDFS and how does it work with Spark?
916. What are the advantages of cloud storage (S3, ADLS, GCS) for Spark workloads?

### 7.2 File Format Deep Dive - Parquet
917. What is columnar storage? How does Parquet implement it?
918. What are the advantages of Parquet for analytics workloads?
919. How does Parquet handle nested data structures?
920. What is a row group in Parquet?
921. What is a column chunk in Parquet?
922. How does Parquet encoding and compression work?
923. What is predicate pushdown in Parquet and why is it efficient?
924. What is projection pushdown in Parquet?
925. What are the limitations of Parquet?

### 7.3 File Format Deep Dive - Avro
926. What is row-based storage? How does Avro use it?
927. What are the advantages of Avro for streaming and schema evolution?
928. How does Avro handle schema evolution (backward, forward, full compatibility)?
929. When would you choose Avro over Parquet?
930. How is Avro schema stored and transmitted?
931. What is the performance trade-off between Avro and Parquet?

### 7.4 File Format Deep Dive - ORC
932. How is ORC similar to and different from Parquet?
933. What compression techniques does ORC use?
934. How does ORC handle predicate pushdown?
935. What are ORC stripes, row groups, and indexes?
936. When would you choose ORC over Parquet?

### 7.5 File Format Deep Dive - Delta Lake
937. What is Delta Lake and how is it different from a file format?
938. What are the ACID transaction guarantees in Delta Lake?
939. How does Delta Lake implement time travel?
940. What is the Delta transaction log?
941. How does Delta Lake handle updates and deletes?
942. What is optimize and ZORDER in Delta Lake?
943. What is vacuum in Delta Lake?
944. How does Delta Lake schema enforcement work?
945. What is schema evolution in Delta Lake?
946. What are the performance benefits of Delta over Parquet?

### 7.6 File Format Deep Dive - Apache Hudi
947. What is Apache Hudi and what data management problems does it solve?
948. What are Copy-on-Write (CoW) and Merge-on-Read (MoR) tables in Hudi?
949. When would you use Hudi over Delta Lake?
950. How does Hudi handle upserts?
951. What is Hudi's timeline and commit model?

### 7.7 File Format Comparisons
952. Compare Parquet vs CSV in terms of:
   - a) Storage efficiency
   - b) Read performance
   - c) Write performance
   - d) Schema handling
   - e) Use cases
953. Compare Avro vs Parquet vs ORC for:
   - a) Analytics workloads
   - b) Streaming workloads
   - c) Schema evolution requirements
954. Compare Delta Lake vs Apache Hudi vs Apache Iceberg for:
   - a) ACID transactions
   - b) Time travel
   - c) Performance
   - d) Ecosystem support
955. When would you use JSON format despite its inefficiency?
956. What are the trade-offs between text formats (CSV, JSON) and binary formats (Parquet, Avro, ORC)?
957. How does compression affect different file formats differently?

## 8. Joins in Spark

### 8.1 Join Types
958. What is the difference between inner join, outer join, full outer join, and left outer join?
959. What are the implications of each join type on the result set?

### 8.2 Join Strategies & Types
960. What is a shuffle sort-merge join (shuffle join)?
961. What is a broadcast join (broadcast hash join)?
962. When does Spark choose shuffle sort-merge join vs broadcast join?
963. What are the trade-offs between these join strategies in terms of memory, network I/O, and performance?
964. Explain the mechanics, considerations, and advantages of broadcast joins.
965. What is a shuffle hash join? When is it used?
966. What is a cartesian join? When does it occur and why should it be avoided?
967. What is a broadcast nested loop join? When is it used?
968. Compare all join strategies: Broadcast Hash Join vs Shuffle Hash Join vs Sort-Merge Join vs Cartesian Join vs Broadcast Nested Loop Join.
969. What conditions must be met for Spark to choose a broadcast join?
970. What happens if a broadcast join fails due to memory constraints?
971. How does Spark decide between shuffle hash join and sort-merge join?
972. What is the difference between an equi-join and a non-equi-join in terms of join strategy selection?
973. When would Spark use broadcast nested loop join instead of broadcast hash join?

### 8.3 Broadcast Join Deep Dive
974. How does broadcast join work internally? Explain the three phases: broadcast, hash build, probe.
975. What data structure is used during the hash build phase of a broadcast join?
976. How is the smaller table distributed to executor nodes during broadcast?
977. What is the role of the driver in coordinating broadcast joins?
978. What does `spark.sql.autoBroadcastJoinThreshold` control? What is its default value (10MB)?
979. How do you manually force a broadcast join using broadcast hints?
980. What are the different ways to provide broadcast hints in Spark SQL and DataFrame API?
981. What happens if you broadcast a table larger than available executor memory?
982. How do you calculate the in-memory size of a DataFrame for broadcast join decisions?
983. What is the difference between the on-disk size and in-memory size of data?
984. Why might a 5MB Parquet file become 50MB in memory?
985. What compression and encoding affect the size difference between disk and memory?
986. How does `spark.sql.adaptive.autoBroadcastJoinThreshold` differ from the regular threshold?
987. Can you broadcast multiple tables in a multi-way join?
988. What are the memory implications of broadcasting in a multi-way join scenario?
989. How does broadcast join perform with skewed data on the large table side?
990. What happens if the broadcast data doesn't fit in executor memory during runtime?
991. How do you monitor broadcast join performance in Spark UI?
992. What metrics indicate successful broadcast join execution?
993. What is broadcast timeout and how do you configure it?
994. How does broadcast join improve performance compared to shuffle sort-merge join?
995. What network I/O savings does broadcast join provide?
996. In what scenarios would broadcast join actually be slower than sort-merge join?
997. How does broadcast join work with partition pruning?
998. Can broadcast join be used with all join types (inner, left, right, full outer)?
999. Which join types benefit most from broadcast strategy?

### 8.4 Join Optimization Strategies
1000. How do you optimize Spark joins effectively?
1001. What techniques can be used to improve join performance? (Repartitioning, Broadcasting, Caching, Shuffle tuning, Bucketing)
1002. How do you define what constitutes a "large" DataFrame vs "small" DataFrame for join optimization?
1003. How do you check the size of a DataFrame in a Spark session?
1004. How does `bucketBy()` remove shuffle from sort-merge joins?
1005. What is bucketed sort-merge join and how does it eliminate shuffle?
1006. How do you verify that bucketing is being utilized in a join?
1007. What is the relationship between bucketing, partitioning, and join performance?
1008. When should you pre-partition both DataFrames before joining?
1009. How does repartitioning by join key improve join performance?
1010. What is the optimal number of partitions for join operations?
1011. How do you balance between too few and too many partitions in joins?
1012. What is the role of caching in multi-join queries?
1013. Should you cache before or after filtering when planning joins?
1014. How does filter pushdown before joins improve performance?
1015. What is the impact of selecting only required columns before joining?
1016. How do you optimize joins when both tables are large?
1017. What is salting and how does it help with skewed joins?
1018. How do you implement salting for skewed join keys?
1019. What is the broadcast-replicate strategy for handling skew in joins?
1020. How do you identify which join keys are causing skew?
1021. What statistics should you collect before performing large joins?
1022. How does `ANALYZE TABLE COMPUTE STATISTICS` help with join optimization?
1023. What is the impact of data types on join performance (StringType vs IntegerType for join keys)?
1024. How do null values in join keys affect join performance and strategy selection?
1025. Should you filter out nulls before joining? When and why?

### 8.5 Shuffle Operations in Joins
1026. Explain Map Exchange and Reduce Exchange in shuffle sort-merge joins.
1027. When processing large datasets with multiple joins, what optimization techniques should be considered?
1028. What is shuffle write and shuffle read in the context of joins?
1029. How do you minimize shuffle during join operations?
1030. What is the shuffle spill and how does it affect join performance?
1031. How do you identify shuffle-heavy joins in Spark UI?
1032. What metrics indicate excessive shuffling in joins?
1033. What is the relationship between `spark.sql.shuffle.partitions` and join performance?
1034. How does increasing shuffle partitions affect memory consumption during joins?

### 8.6 Adaptive Query Execution (AQE) for Joins
1035. How does AQE improve join performance?
1036. What is dynamic join strategy switching in AQE?
1037. How does AQE convert sort-merge join to broadcast join at runtime?
1038. What triggers AQE to switch join strategies during execution?
1039. What is `spark.sql.adaptive.autoBroadcastJoinThreshold` and how is it different from static threshold?
1040. How does AQE handle skewed joins automatically?
1041. What is skew join optimization in AQE?
1042. How does AQE detect skewed partitions during joins?
1043. What is `spark.sql.adaptive.skewJoin.enabled` configuration?
1044. What is `spark.sql.adaptive.skewJoin.skewedPartitionFactor`?
1045. What is `spark.sql.adaptive.skewJoin.skewedPartitionThresholdInBytes`?
1046. How does AQE split skewed partitions during joins?
1047. What is the performance impact of AQE's skew join optimization?
1048. How do you verify that AQE optimized your join in Spark UI?
1049. What is dynamic coalescing of shuffle partitions and how does it help joins?
1050. How does AQE reduce the number of reducers after shuffle in joins?
1051. What is `spark.sql.adaptive.coalescePartitions.enabled`?
1052. What is `spark.sql.adaptive.coalescePartitions.minPartitionSize`?
1053. What is `spark.sql.adaptive.advisoryPartitionSizeInBytes`?
1054. Can AQE optimizations be combined (e.g., coalescing + skew handling + join strategy switch)?
1055. What are the prerequisites for AQE to work effectively with joins?
1056. Does AQE work with all join types and strategies?
1057. What is the overhead of enabling AQE for joins?
1058. When might AQE make join performance worse?

### 8.7 Dynamic Partition Pruning (DPP) for Joins
1059. What is Dynamic Partition Pruning (DPP) and how does it optimize joins?
1060. How does DPP differ from static partition pruning?
1061. When is DPP triggered during join execution?
1062. What is the typical scenario where DPP provides significant benefit?
1063. Explain the star schema query optimization using DPP.
1064. How does DPP work in a fact table - dimension table join?
1065. What conditions must be met for DPP to be applied?
1066. What is `spark.sql.optimizer.dynamicPartitionPruning.enabled`?
1067. What is `spark.sql.optimizer.dynamicPartitionPruning.useStats`?
1068. What is `spark.sql.optimizer.dynamicPartitionPruning.fallbackFilterRatio`?
1069. What is `spark.sql.optimizer.dynamicPartitionPruning.reuseBroadcastOnly`?
1070. How does DPP interact with broadcast joins?
1071. Can DPP work without broadcast joins? How?
1072. What is the subquery that DPP creates during optimization?
1073. How do you verify DPP is working in the query plan?
1074. What does "DynamicFileSourceFilter" indicate in the physical plan?
1075. How much performance improvement can DPP provide?
1076. What are the limitations of DPP?
1077. Does DPP work with bucketed tables?
1078. Does DPP work with non-partitioned tables?
1079. How does DPP handle multi-level partitioning?
1080. What is the relationship between DPP and predicate pushdown?
1081. Can DPP be combined with AQE optimizations?
1082. How does DPP affect shuffle in joins?
1083. What statistics are needed for DPP to work effectively?
1084. When should you disable DPP?
1085. How does DPP work with complex join conditions?
1086. What is the difference between DPP and bloom filter join optimization?

## 9. Shuffle & Partitioning

### 9.1 Shuffle Fundamentals
1087. What are shuffle operations in Spark?
1088. Explain shuffle-sort operations in the context of GROUP BY operations.
1089. Explain shuffle-sort operations in the context of JOIN operations.
1090. What is `spark.sql.shuffle.partitions`? What does it control?
1091. What are recommended values for `spark.sql.shuffle.partitions` for different workload sizes?
1092. What is the shuffle buffer and what does shuffle buffer size control?

### 9.2 Partition Tuning
1093. What is partition tuning and why is it crucial for optimizing Spark jobs?
1094. How do you find the right balance between parallelism and shuffle overhead?
1095. What is custom partitioning and when would you implement it?
1096. What is the `reduceByKey` operation and why is it more efficient than `groupByKey`?

### 9.3 Data Skewness
1097. What is data skewness in Spark?
1098. What causes uneven distribution of data across partitions?
1099. If shuffle read and write times are significantly uneven, what does this indicate about data distribution?
1100. What are salting techniques for handling skewed datasets?
1101. How does data skewness affect job performance?

### 9.4 Dynamic Partition Pruning
1102. What is Dynamic Partition Pruning (DPP)?
1103. How do you enable Dynamic Partition Pruning?
1104. What scenarios benefit most from Dynamic Partition Pruning?

## 10. Memory Management & Performance

### 10.1 Memory Architecture & Configuration
1105. Explain Spark's Unified Memory Management model.
1106. What is the difference between execution memory and storage memory?
1107. How does unified memory management allow dynamic borrowing between execution and storage?
1108. What is `spark.memory.fraction` and what is its default value (0.6)?
1109. What does `spark.memory.storageFraction` control and what is its default (0.5)?
1110. How much memory is available for execution vs storage by default in Spark?
1111. What is executor memory overhead and what is it used for?
1112. What is `spark.executor.memoryOverhead` and how is it calculated?
1113. What is the formula for total executor memory allocation?
1114. What is `spark.executor.memory` and how do you set it?
1115. What is `spark.driver.memory` and when should you increase it?
1116. What is the difference between on-heap and off-heap memory?
1117. What is `spark.memory.offHeap.enabled` and when should you enable it?
1118. What is `spark.memory.offHeap.size` and how do you configure it?
1119. What are the benefits of using off-heap memory in Spark?
1120. What is the user memory region in Spark's memory model?
1121. What is reserved memory in Spark and what is it used for?
1122. How is executor memory divided: Reserved + User + Unified Memory?
1123. What percentage of memory is reserved in Spark (300MB typically)?
1124. What is the minimum executor memory required by Spark?
1125. How do you calculate optimal executor memory for your workload?
1126. What is the relationship between executor cores and executor memory?
1127. Why shouldn't you allocate too much memory to a single executor?
1128. What is the recommended executor memory size (8-40GB range)?
1129. How does memory management differ between Spark 1.5 and earlier versions?
1130. What was static memory management in older Spark versions?
1131. What problems did unified memory management solve?

### 10.2 Garbage Collection & JVM Tuning
1132. What is the role of garbage collection in Spark's memory management?
1133. How do you tune garbage collection for Spark jobs?
1134. What is the difference between Young Generation and Old Generation in JVM?
1135. What is Full GC and why is it problematic in Spark?
1136. What is Minor GC and how does it affect Spark performance?
1137. What is `spark.executor.extraJavaOptions` used for?
1138. How do you enable GC logging in Spark?
1139. What are the recommended GC settings for Spark applications?
1140. What is G1GC (Garbage First Garbage Collector)?
1141. Why is G1GC recommended for Spark over traditional GC algorithms?
1142. What is CMS (Concurrent Mark Sweep) GC?
1143. How do you configure G1GC for Spark executors?
1144. What is `-XX:+UseG1GC` flag?
1145. What is `-XX:MaxGCPauseMillis` and what value should you set?
1146. What is `-XX:InitiatingHeapOccupancyPercent` for G1GC?
1147. What is the relationship between GC pauses and Spark task execution?
1148. How do you identify GC issues in Spark UI?
1149. What percentage of task time spent in GC is concerning (>10%)?
1150. What is GC overhead and how does it affect throughput?
1151. How does data serialization reduce GC pressure?
1152. What is the impact of caching on GC activity?
1153. How do you reduce object creation to minimize GC?
1154. What is object pooling and when should you use it in Spark?

### 10.3 Data Spilling & Disk I/O
1155. What is data spilling in Spark?
1156. When and why does data spilling occur?
1157. What are the performance implications of data spilling?
1158. What is shuffle spill and how is it different from storage spill?
1159. What triggers spill to disk during shuffle operations?
1160. What triggers spill to disk during caching operations?
1161. How do you identify spilling in Spark UI?
1162. What metrics indicate spilling: "Spill (Memory)", "Spill (Disk)"?
1163. What is `spark.executor.memory` vs `spark.memory.fraction` in context of spilling?
1164. How does increasing executor memory reduce spilling?
1165. How does increasing `spark.sql.shuffle.partitions` affect spilling?
1166. What is the trade-off between partitions and spilling?
1167. What is `spark.shuffle.spill.compress` and should it be enabled?
1168. What is `spark.shuffle.spill.batchSize` and how does it affect performance?
1169. How does data serialization format affect spilling?
1170. Does Kryo serialization reduce spilling compared to Java serialization?
1171. What is the impact of spilling on network I/O?
1172. What is the impact of spilling on disk I/O?
1173. How do you configure local disk directories for spilling?
1174. What is `spark.local.dir` and why should it point to fast disks (SSDs)?
1175. How does disk speed affect spill performance?
1176. What happens if spill directories run out of space?
1177. How do you prevent spilling in memory-intensive operations?
1178. What operations are most likely to cause spilling?
1179. How does caching affect spilling behavior?

### 10.4 Caching & Persistence Strategies
1180. Does caching happen on worker nodes or executors? Explain the relationship.
1181. When should you cache DataFrames?
1182. What storage levels are available for caching in Spark?
1183. What is MEMORY_ONLY storage level?
1184. What is MEMORY_AND_DISK storage level?
1185. What is MEMORY_ONLY_SER (serialized)?
1186. What is MEMORY_AND_DISK_SER?
1187. What is DISK_ONLY storage level?
1188. What is OFF_HEAP storage level?
1189. What storage levels support replication (_2 suffix)?
1190. When should you use MEMORY_ONLY vs MEMORY_AND_DISK?
1191. What are the trade-offs between deserialized vs serialized caching?
1192. When should you use serialized caching?
1193. How much memory does serialized caching save?
1194. What is the CPU overhead of serialized caching?
1195. What is the difference between `cache()` and `persist()`?
1196. Can you specify storage level with `cache()`?
1197. What is the default storage level for `cache()`?
1198. How do you unpersist cached data?
1199. What happens to cached data when executors fail?
1200. How does caching work with replication factor?
1201. How does caching fit into multi-join query optimization strategies?
1202. Should you cache intermediate results in a DAG?
1203. When is caching counterproductive?
1204. How do you monitor cache usage in Spark UI?
1205. What is cache hit ratio and why is it important?
1206. What is LRU (Least Recently Used) eviction in caching?
1207. What happens when cache memory is full?
1208. How do you size cache memory appropriately?
1209. What is `spark.storage.memoryFraction` in older Spark versions?
1210. How does caching interact with shuffle operations?
1211. Should you cache before or after wide transformations?
1212. How does checkpoint differ from caching?
1213. When should you use checkpoint instead of cache?
1214. What is the relationship between persistence and lineage?

### 10.5 Serialization & Performance
1215. Why is serialization important in Spark?
1216. What serialization types are available (Java, Kryo)?
1217. What is SerDe (Serializer/Deserializer) in Spark's context?
1218. What are the performance differences between Java and Kryo serialization?
1219. How much faster is Kryo compared to Java serialization (2-10x)?
1220. How do you enable Kryo serialization?
1221. What is `spark.serializer` configuration?
1222. What is `spark.kryo.registrationRequired`?
1223. What is `spark.kryo.classesToRegister`?
1224. Why should you register classes with Kryo?
1225. What happens if you don't register classes with Kryo?
1226. What is the cost of class registration in Kryo?
1227. How does serialization affect shuffle performance?
1228. How does serialization affect caching efficiency?
1229. How does serialization affect network transfer?
1230. What data types benefit most from Kryo serialization?
1231. When is Java serialization preferred over Kryo?
1232. What is broadcast serialization and how does it work?
1233. How does serialization affect broadcast join performance?
1234. What is task serialization and when does it occur?
1235. What causes "Task not serializable" errors?
1236. How do you fix task serialization issues?
1237. What objects must be serializable in Spark?
1238. How do you make custom classes serializable?

## 11. Catalyst Optimizer & Query Execution

### 11.1 Catalyst Optimizer Deep Dive
1239. What is the Catalyst Optimizer in Spark?
1240. Explain the Catalyst optimization phases: Analysis → Logical Optimization → Physical Planning → Code Generation.
1241. What happens during the Analysis phase of Catalyst?
1242. What is the unresolved logical plan?
1243. What is the resolved logical plan?
1244. How does Catalyst resolve column names and table references?
1245. What is the Catalog in Spark and how does it help Catalyst?
1246. What happens during the Logical Optimization phase?
1247. What rule-based optimizations does Catalyst apply?
1248. What is predicate pushdown in Catalyst?
1249. What is column pruning in Catalyst?
1250. What is constant folding in Catalyst?
1251. What is null propagation in Catalyst?
1252. What is boolean expression simplification?
1253. What is filter combining/merging in Catalyst?
1254. What is projection collapsing in Catalyst?
1255. What happens during the Physical Planning phase?
1256. How does Catalyst generate multiple physical plans?
1257. What is cost-based optimization (CBO) in Catalyst?
1258. How does Catalyst use cost-based optimization to enhance query performance?
1259. What role do statistics play in cost-based query optimization?
1260. What statistics does Spark collect for CBO?
1261. How do you collect table statistics using `ANALYZE TABLE`?
1262. What is the difference between table statistics and column statistics?
1263. What is `ANALYZE TABLE ... COMPUTE STATISTICS`?
1264. What is `ANALYZE TABLE ... COMPUTE STATISTICS FOR COLUMNS`?
1265. What statistics are collected: row count, data size, column histograms?
1266. How do statistics affect join strategy selection?
1267. How do statistics affect join order selection?
1268. What is the cost model used by Catalyst?
1269. How does Catalyst estimate the cost of different physical plans?
1270. What is the cost of a full table scan vs index scan vs broadcast?
1271. What happens during the Code Generation phase (Whole-Stage Code Generation)?
1272. What is Tungsten's role in code generation?
1273. How does whole-stage code generation improve performance?
1274. What is the benefit of generating Java bytecode at runtime?
1275. What operations support whole-stage code generation?
1276. What is the hand-written code generation approach?
1277. How do you view the generated code for a query?
1278. What is `explain(extended=True)` and what does it show?
1279. What is `explain(mode='formatted')` and its output?
1280. What is `explain(mode='cost')` and what does it reveal?
1281. How do you read the physical plan output?
1282. What does the `*` symbol mean in physical plans (whole-stage codegen)?
1283. What optimization rules can you see in the logical plan?

### 11.2 Tungsten Engine Deep Dive
1284. What is the Tungsten Engine?
1285. How does Tungsten optimize execution through code generation and memory management?
1286. What are the three main components of Tungsten?
1287. What is Tungsten's memory management component?
1288. What is Tungsten's cache-aware computation?
1289. What is Tungsten's code generation (whole-stage codegen)?
1290. How does Tungsten reduce CPU overhead?
1291. What is the Unsafe API in Tungsten?
1292. How does Tungsten use off-heap memory?
1293. What is binary data format in Tungsten?
1294. How does Tungsten eliminate virtual function calls?
1295. How does Tungsten reduce object creation overhead?
1296. What is the performance improvement from Tungsten (2-10x)?
1297. What operations benefit most from Tungsten optimizations?
1298. How do you verify Tungsten is being used in your queries?

### 11.3 Predicate Pushdown Deep Dive
1299. What is predicate pushdown?
1300. How does predicate pushdown reduce data processing?
1301. Can Spark push down filters to all types of data sources (internal and external)?
1302. Categorize which data sources support predicate pushdown and which don't.
1303. Does Parquet support predicate pushdown? How?
1304. Does ORC support predicate pushdown? How?
1305. Does Avro support predicate pushdown?
1306. Does CSV support predicate pushdown?
1307. Does JSON support predicate pushdown?
1308. Do JDBC sources support predicate pushdown?
1309. How does JDBC predicate pushdown work?
1310. What filters can be pushed down to JDBC sources?
1311. What is the benefit of pushing filters to the database in JDBC reads?
1312. Does Hive support predicate pushdown?
1313. Does Delta Lake support predicate pushdown?
1314. How does partition pruning relate to predicate pushdown?
1315. What is the difference between predicate pushdown and partition pruning?
1316. How do you verify predicate pushdown is working?
1317. What does the physical plan show for pushed filters?
1318. What is `PushedFilters` in the physical plan?
1319. Why might some filters not be pushed down?
1320. What types of predicates cannot be pushed down?
1321. How does predicate pushdown work with complex expressions?
1322. Can predicates with UDFs be pushed down?
1323. How does projection pushdown complement predicate pushdown?
1324. What is projection pushdown (column pruning at source)?

### 11.4 Adaptive Query Execution (AQE) Deep Dive
1325. What is Adaptive Query Execution (AQE)?
1326. When was AQE introduced in Spark (3.0)?
1327. What is the main difference between static optimization and adaptive optimization?
1328. What optimizations does AQE enable?
1329. How do you enable AQE?
1330. What is `spark.sql.adaptive.enabled` (default true in Spark 3.2+)?
1331. What are the three main features of AQE?

### 11.4.1 AQE: Dynamic Coalescing of Shuffle Partitions
1332. What is dynamically coalescing shuffle partitions?
1333. What problem does partition coalescing solve?
1334. What is `spark.sql.adaptive.coalescePartitions.enabled`?
1335. What is `spark.sql.adaptive.coalescePartitions.minPartitionSize` (default 1MB)?
1336. What is `spark.sql.adaptive.advisoryPartitionSizeInBytes` (default 64MB)?
1337. How does AQE determine the target partition size?
1338. What is `spark.sql.adaptive.coalescePartitions.initialPartitionNum`?
1339. How does AQE coalesce small partitions after shuffle?
1340. What is the algorithm for partition coalescing?
1341. When does partition coalescing happen in the query execution?
1342. What is the benefit of coalescing partitions (reduced tasks, less overhead)?
1343. How much can AQE reduce the number of tasks in shuffle stages?
1344. How do you verify partition coalescing in Spark UI?
1345. What does "AQE coalesced" indicate in the SQL tab?

### 11.4.2 AQE: Dynamic Join Strategy Switching  
1346. What is dynamically switching join strategies?
1347. When does AQE switch from sort-merge join to broadcast join?
1348. What triggers join strategy conversion at runtime?
1349. What is `spark.sql.adaptive.autoBroadcastJoinThreshold` (default 10MB)?
1350. How is adaptive threshold different from static `spark.sql.autoBroadcastJoinThreshold`?
1351. How does AQE measure actual data size after shuffle?
1352. What happens if shuffle output is smaller than expected?
1353. Can AQE convert both sides of a join if they're small enough?
1354. What is the performance benefit of runtime join strategy switching?
1355. How do you verify join strategy switching in Spark UI?
1356. What does "broadcast join after adaptive planning" indicate?

### 11.4.3 AQE: Skew Join Optimization
1357. What is skew join optimization in AQE?
1358. How does AQE detect skewed partitions?
1359. What is `spark.sql.adaptive.skewJoin.enabled` (default true)?
1360. What is `spark.sql.adaptive.skewJoin.skewedPartitionFactor` (default 5)?
1361. What is `spark.sql.adaptive.skewJoin.skewedPartitionThresholdInBytes` (default 256MB)?
1362. How does the skew detection algorithm work?
1363. What makes a partition "skewed" in AQE's definition?
1364. How does AQE handle skewed partitions?
1365. What is the partition splitting strategy in skew join?
1366. How many sub-partitions does AQE create from skewed partitions?
1367. What is `spark.sql.adaptive.skewJoin.skewedPartitionMaxSplits`?
1368. How does AQE replicate the non-skewed side in skew join?
1369. What is the broadcast-replicate approach for skew handling?
1370. How does skew join optimization improve performance?
1371. What is the overhead of skew join optimization?
1372. How do you verify skew join optimization in Spark UI?
1373. What does "optimized skewed join" indicate in the plan?
1374. Can AQE handle multiple skewed partitions?
1375. Does AQE work with all join types for skew handling?
1376. What join types benefit from skew optimization (inner, left, right)?

### 11.4.4 AQE: Additional Features & Configuration
1377. What is `spark.sql.adaptive.localShuffleReader.enabled`?
1378. How does local shuffle reader optimization work?
1379. What is the benefit of converting shuffle read to local read?
1380. What is `spark.sql.adaptive.optimizeSkewedJoin.enabled`?
1381. What is `spark.sql.adaptive.nonEmptyPartitionRatioForBroadcastJoin`?
1382. How does AQE interact with DPP (Dynamic Partition Pruning)?
1383. Can AQE and DPP be used together?
1384. What is the execution order: DPP then AQE or AQE then DPP?
1385. What are the prerequisites for AQE to work effectively?
1386. Does AQE work with all query types?
1387. What queries benefit most from AQE?
1388. When might AQE make performance worse?
1389. What is the overhead of enabling AQE?
1390. How does AQE affect query planning time?
1391. How do you debug AQE optimizations?
1392. How do you see AQE decisions in Spark UI?
1393. What does the "Adaptive Spark Plan" section show?
1394. How do you compare original plan vs adaptive plan?
1395. What metrics indicate successful AQE optimizations?

## 12. RDDs (Resilient Distributed Datasets)

### 12.1 RDD Fundamentals
1396. What is an RDD (Resilient Distributed Dataset)?
1397. What makes RDDs resilient?
1398. How are RDDs fault-tolerant?
1399. What is the difference between narrow dependency and wide dependency in RDDs?

### 12.2 RDD vs DataFrame
1400. Compare RDDs and DataFrames in terms of:
   - a) Optimization capabilities
   - b) Type safety
   - c) Performance
   - d) Ease of use
1401. When would you prefer using RDDs over DataFrames/Datasets?

### 12.3 API Hierarchy
1402. How do Spark SQL, Dataset API, DataFrame API, Catalyst Optimizer, and RDD relate to each other?
1403. What is Spark Core and how does it relate to higher-level APIs?

## 13. Table Management & Metastore

### 13.1 Table Types
1404. What is the difference between Spark managed tables and unmanaged (external) tables?
1405. When does Spark delete underlying data for managed vs unmanaged tables?
1406. What is the difference between Spark's in-memory database (per session) and Hive metastore (persistent)?

### 13.2 Warehouse Configuration
1407. What does `spark.sql.warehouse.dir` specify?
1408. What is `sparkSession.enableHiveSupport()` and when do you need it?
1409. Why would you enable Hive support for managed tables?

### 13.3 Catalog Operations
1410. What is the Spark Catalog API?
1411. How do you switch databases using `spark.catalog.setCurrentDatabase()`?
1412. How do you list available tables using `spark.catalog.listTables()`?

### 13.4 Tables vs Files
1413. What are the advantages of using Spark SQL tables vs raw Parquet files for external tools (ODBC/JDBC, Tableau, Power BI)?
1414. What are the advantages of using Spark SQL tables vs raw Parquet files for internal Spark API usage?

## 14. Monitoring & Troubleshooting

### 14.1 Spark UI
1415. How do you explore and navigate the Spark UI for performance analysis?
1416. Is Spark UI only available during active Spark sessions?
1417. How can you preserve execution history and logs using log4j?

### 14.2 Metrics & Accumulators
1418. What are accumulators in Spark?
1419. How are accumulators used for distributed counting and metrics collection?
1420. What metrics indicate performance bottlenecks (skew, spilling, GC time)?

### 14.3 Common Errors & Debugging
1421. What is the "out of memory" error and common causes in Spark?
1422. Why do you get "Task not serializable" errors? How do you fix them?
1423. What causes "Stage X has Y failed attempts" and how do you debug it?
1424. What is data skew and what are the symptoms in Spark UI?
1425. How do you identify and fix shuffle spill to disk issues?
1426. What are best practices for naming columns to avoid conflicts?
1427. How do you handle special characters in column names?
1428. What is the impact of data types on performance (e.g., StringType vs IntegerType)?
1429. Why should you avoid using `count()` multiple times on the same DataFrame?
1430. What happens when you mix transformation logic with actions improperly?

## 15. Advanced Topics

### 15.1 Broadcast Variables & Accumulators
1431. What are broadcast variables in Spark?
1432. When should you use broadcast variables?
1433. How do you create and use a broadcast variable?
1434. What are the limitations and size restrictions of broadcast variables?
1435. What are accumulators in Spark?
1436. How are accumulators used for distributed counting and metrics collection?
1437. What is the difference between accumulators and regular variables?
1438. Can you read accumulator values inside transformations? Why or why not?
1439. What happens to accumulator values if a task fails and retries?

### 15.2 Streaming & Real-Time Processing
1440. How does Spark handle time-series data processing?
1441. What is Spark Streaming?
1442. What capabilities does Spark provide for real-time analytics?

### 15.3 Machine Learning
1443. What machine learning libraries are available in Spark (MLlib)?
1444. What are the key components of Spark MLlib?

### 15.4 Graph Processing
1445. What is GraphX?
1446. What graph processing capabilities does GraphX provide?

### 15.5 Performance Optimization Scenarios
1447. When processing a multi-terabyte dataset, what strategies should be considered to optimize data read and write operations?
1448. Should you cache frequently accessed data in memory for large datasets?
1449. How does Spark optimize read/write operations to HDFS compared to Hadoop MapReduce?

## 16. Big Data Fundamentals

### 16.1 Core Concepts
1450. What are the 3 Vs of Big Data (Volume, Velocity, Variety)? Explain each with examples.
1451. What is a data lake architecture?

## 17. Platform-Specific Topics

### 17.1 AWS Glue
1452. How do AWS Glue Dynamic Frames differ from standard Spark DataFrames?
1453. What are the unique features of Glue Dynamic Frames?

### 17.2 Development Tools
1454. What is the role of Zeppelin notebooks in the Spark ecosystem?
1455. How are Zeppelin notebooks different from Databricks notebooks?

## 18. Miscellaneous Important Topics

### 18.1 DataFrame vs SQL - When to Use What
1456. When should you use DataFrame API vs Spark SQL?
1457. Can you mix DataFrame API and SQL in the same application?
1458. How do you register a DataFrame as a temporary view?
1459. What is the difference between `createTempView()` and `createGlobalTempView()`?
1460. How does performance compare between DataFrame API and SQL?
1461. Are there operations easier to express in SQL vs DataFrame API?

### 18.2 Data Sampling & Debugging
1462. How do you use `sample()` for testing on subset of data?
1463. What does `sample(withReplacement, fraction, seed)` mean?
1464. What is stratified sampling using `sampleBy()`?
1465. How do you use `limit()` for quick data inspection?
1466. What does `show(n, truncate)` do? What are the parameters?
1467. How do you use `printSchema()` for debugging?
1468. What does `explain()` show? How do you read the physical plan?
1469. What does `explain(extended=True)` reveal?

### 18.3 Type Safety & Datasets (Scala/Java)
1470. What is the difference between DataFrame and Dataset in Spark?
1471. What are the advantages of type safety in Datasets?
1472. When would you use Dataset over DataFrame?
1473. What is the performance cost of Datasets vs DataFrames?
1474. How does the encoder work in Datasets?

### 18.4 Miscellaneous Important Questions
1475. What is the relationship between Spark SQL engine, Catalyst optimizer, and Tungsten engine?
1476. How do DataFrame API and RDD API differ in their relationship to SparkSession vs SparkContext?
1477. What is the difference between client libraries (PySpark, Spark Scala, Spark Java, SparkR)?
1478. How does PySpark communicate with JVM (Py4J)?
1479. What are the performance implications of using PySpark vs Scala Spark?
1480. When would you drop down to RDD API from DataFrame API?
1481. How do you convert between RDD and DataFrame?
1482. What is the cost of `collect()` in terms of network and memory?
1483. How do you handle timezone-aware timestamp operations?
1484. What is the difference between `current_timestamp()` and `now()`?
1485. How do you generate surrogate keys in distributed systems?
1486. What is `uuid()` function used for?
1487. How do you handle slowly changing dimensions (SCD) in Spark?
1488. What are best practices for handling PII (Personally Identifiable Information) in Spark?
1489. How do you implement data quality checks in Spark pipelines?

---

## Summary Statistics

**Total Questions: 1489**

### Category Breakdown:
- **Spark Architecture & Core Concepts**: 15 questions
- **Spark Configuration & Deployment**: 19 questions
- **DataFrame & Dataset API**: 1000+ questions (largest section)
  - Basic Operations: 25 questions
  - Schema Management: 4 questions
  - Data Types: 10 questions
  - Column Operations: 28 questions
  - String Functions: 12 questions
  - Date & Time Functions: 42 questions
  - Aggregate Functions: 52 questions
  - Array Functions: 52 questions
  - Map Functions: 32 questions
  - Struct Functions: 28 questions
  - Type Conversion: 35 questions
  - Null Handling: 32 questions
  - Performance Optimization: 139 questions
  - Advanced Transformations: 11 questions
  - Function Comparisons: 16 questions
  - Sampling Methods: 15 questions
  - Repartitioning Methods: 42 questions
  - Caching & Persistence: 38 questions
  - And more...
- **Spark Collections**: 71 questions
- **User-Defined Functions**: 5 questions
- **Data Sources & I/O Operations**: 82 questions
- **File Formats & Storage Systems**: 45 questions
- **Joins in Spark**: 129 questions
- **Shuffle & Partitioning**: 18 questions
- **Memory Management & Performance**: 133 questions
- **Catalyst Optimizer & Query Execution**: 157 questions
- **RDDs**: 8 questions
- **Table Management & Metastore**: 11 questions
- **Monitoring & Troubleshooting**: 16 questions
- **Advanced Topics**: 19 questions
- **Big Data Fundamentals**: 2 questions
- **Platform-Specific Topics**: 4 questions
- **Miscellaneous Important Topics**: 34 questions

### Key Additions in This Expanded Edition:
1. ✅ Action methods comparison (first, head, take, collect)
2. ✅ Sorting methods performance comparison
3. ✅ GroupBy vs agg() critical distinctions
4. ✅ ROLLUP and CUBE with SQL database compatibility
5. ✅ Union operations inconsistency (DataFrame API vs SQL)
6. ✅ Intersect vs IntersectAll detailed comparison
7. ✅ Comprehensive sampling methods comparison
8. ✅ Complete repartitioning methods analysis
9. ✅ Repartition vs Coalesce critical decision guide
10. ✅ Cache vs Persist deep dive
11. ✅ Checkpoint vs localCheckpoint comparison
12. ✅ Pandas integration (toPandas vs pandas_api)
13. ✅ Temporary views and global temporary views
14. ✅ freqItems() function details
15. ✅ NULL handling (na.replace vs na.fill distinction)
16. ✅ COALESCE, NVL, and NVL2 functions comparison

This expanded edition now provides comprehensive coverage of Apache Spark interview topics with detailed comparisons, critical distinctions, and practical decision-making guidelines!
