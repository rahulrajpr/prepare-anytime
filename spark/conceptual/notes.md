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
