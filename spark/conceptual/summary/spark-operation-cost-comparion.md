# Spark Operation Cost Comparison

| Operation                     | Type           | Primary Cost Driver                          | Shuffle   | Network I/O | Memory Pressure | When to Use                                                             |
| ----------------------------- | -------------- | -------------------------------------------- | --------- | ----------- | --------------- | ----------------------------------------------------------------------- |
| **groupBy Aggregation** | Transformation | **Shuffle**                            | Very High | Very High   | Medium          | Standard aggregations, summary statistics, data reduction               |
| **Window Functions**    | Transformation | **Shuffle + Sort**                     | High      | High        | High            | Rankings, running totals, row-wise calculations without collapsing data |
| **JOIN (Broadcast)**    | Transformation | **Network (one-time)**                 | None      | Low         | Low             | Large fact table + small dimension table joins                          |
| **JOIN (Sort Merge)**   | Transformation | **Shuffle (both sides)**               | Very High | Very High   | Medium          | Two large tables with equality conditions (equi-joins)                  |
| **JOIN (Shuffle Hash)** | Transformation | **Shuffle + Hash Build**               | Very High | Very High   | High            | Medium + large tables when one side fits in memory                      |
| **Self-Join**           | Transformation | **Shuffle (both sides)**               | Very High | Very High   | Medium          | Finding relationships within same dataset, hierarchical data            |
| **Partition Join**      | Optimization   | **Data Locality**                      | None      | None        | Medium          | Pre-partitioned/bucketed data, frequent joins on same keys              |
| **Equi Join**           | Condition Type | **Algorithm Choice**                   | Depends   | Depends     | Depends         | Equality-based joins that enable broadcast/sort-merge optimizations     |
| **Non-Equi Join**       | Condition Type | **Cartesian Logic**                    | Always    | Extreme     | Very High       | Inequality/range joins (avoid when possible)                            |
| **ROLLUP**              | Transformation | **Shuffle + Multiple Aggregations**    | Very High | Very High   | High            | Hierarchical subtotals, multi-level aggregations with grouping sets     |
| **CUBE**                | Transformation | **Shuffle + Exponential Aggregations** | Very High | Very High   | Very High       | Cross-tabulation, all combination aggregations, data exploration        |
