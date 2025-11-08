Notes : 
* collect() method bring `list of the rows` from `executor nodes` to the `driver node` (dataframe --> list of rows)
* read.option('SamplingRatio','true')
* function regexp_expr
* registering the udf in the dataframe function and udf in a sql expression and when the udf is available in the spark catelogue
* spark catelogue listFunctions
* toDF method
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
