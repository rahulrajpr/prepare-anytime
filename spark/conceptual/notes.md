Notes : 
* collect() method bring `list of the rows` from `executor nodes` to the `driver node` (dataframe --> list of rows)
* read.option('SamplingRatio','true')
* function regexp_expr
* registering the udf in the dataframe function and udf in a sql expression and when the udf is available in the spark catelogue
* spark catelogue listFunctions
* what is toDF method, what is the purpose ?
* monotonically_increasing_id() function
* passing list of values to methods like .drop("col1","col2","col3") and .dropDuplicate(["col1","col2"]) -- like how to pass the list of values
* count(*), count(1) and count(col), differences
* rowsBetween in the window functions
* When I join two tables that both have an id column, using select(*) works and returns both columns. But if I explicitly write select('id'), Spark throws an "ambiguous column" error. Why is there a difference?
* outer join, full outer join, left outer join and their implications ?
* shuffle sort join (shuffle join) vs broadcast join ?
* how to optimise the join and improve the performance ?
* how will you define the large dataframe and small dataframe , what is the criteria on saying that ?
* how to see the size of a dataframe in spark session ?
* how to explore the spark ui ?
* distinguish executors and worker nodes and threds ?
* where the spark-warehouse tables are getting loaded ?
* spark.sql.autoBroadcastJoinThreshold ?
* how to optimise the spark joins effectively ?
* Bucket By for removing the shuffle from sort-merge join ?
* Spark data-lake?
* Distributed file storage systema and file formats and table formats ?
* how to handle reading a corrected file like csv, with some rows having issue with dataframe reader?
* dataframe.schema.simpleString() ?
* inferScheama option, explicitly Specify Schema, Implicity Get Schema from file format for DataFrame Reader Api ?
* spark datatypes?
* Dataframe reader option('dateFormat','fmt') , likely date formts ? while reading the dataframe?
* supplying schema for dataFrame reader -- schems Struct, SQL DDL Way ?
* what is sink Api ?
* MAP Exchange and Reduce Exchange in the shuffle sort merge join ?
* spark.read.table ?
* spark datasources and sinks ?
* findspark library ?
* maxRecordPerFile while writing the dataframe?
* BucketBy and Partition By and SortBy while writing the dataframe
* dataframe.rdd.getNumPartitions ?
* there could be chances that the dataframe may have multiple partitions but in some cases the some of the partitons are empty, so while writing the dataframe without partitionBy method or repartion method, you may see num of the dataframe partitions and file output partions may not match?
* what are crc files in the output, write results ?
* reasonable write file sizes in spark ?
* repartition(n) method and partitionBy(col) method in write method -- with parallellizm and partition pruning ?
* parttion by numeber and partitoion by column how the output is orgsnized by the dierctory level ?
* using maxRecordsPerFiles to control the size of the output file, but how can we existimate them properly ?
* spark in memory database per session and spark uses then hive metastore persistent datastore ? distinguish and how does it work ?
* spark managed tables and unmanaged tables ?
* spark sql warehouse, spark.sql.warehouse.dir ?
* sparkSession.enableHiveSupport() ? for the managed tables
* advantage of the having spark sql table for external use like odbc/jdbc, tablue and powerbi etc and using a parquet file etrenally.
also using sql tables and parquet filesn interanlly by the spark api's ?
* spark.catelogue, spark.catelogue.setCurrentDatabase("databasename"), spark.catelogue.listTables()
* how bucketBy works bucket numbers, list of columns and hashing works, how bucketBy in combination with sortBy support sortmerge join ?
* spark sql, dataset api, dataframe api , catelist optimizer and rdd?
* RDD, what is it and how they are resiliant and , compate with dataframe, how they are fault tolerant ?
* dataframe api are based on spark session and RDD are based on SparkContext ?
* spark sql engine and catelyst optimiser , different phases from analysis, logical, physical, and code generation ?
* what is the difference between distributed file storage system and notmal storage system?
* driver machine, worker nodes, executors, cores, and cluster manager ?
* spark operations - transformation and actions ?
* narrow depandancy transformation and wide depandancy transformation ?
* is it possible to push-down the filters to all kinds of internal ans external data sources for spark, categorise them ?
* shuffle sort operation , explain the same in the perview of the group by and join operataions ?
* lazy evaluation, and what are the advantages of the same ?
  
  
