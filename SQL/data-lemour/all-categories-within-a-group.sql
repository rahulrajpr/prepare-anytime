-- Problem Statement:
-- A Microsoft Azure Supercloud customer is defined as a customer who has purchased at least one product from every product category listed in the products table.

-- Write a query that identifies the customer IDs of these Supercloud customers.

-- Table Schemas:
-- customer_contracts Table:
-- | Column Name   | Type    |
-- |---------------|---------|
-- | customer_id   | integer |
-- | product_id    | integer |
-- | amount        | integer |

-- products Table:
-- | Column Name       | Type    |
-- |-------------------|---------|
-- | product_id        | integer |
-- | product_category  | string  |
-- | product_name      | string  |

-- Example Input:
-- customer_contracts Table:
-- | customer_id | product_id | amount |
-- |-------------|------------|--------|
-- | 1           | 1          | 1000   |
-- | 1           | 3          | 2000   |
-- | 1           | 5          | 1500   |
-- | 2           | 2          | 3000   |
-- | 2           | 6          | 2000   |

-- products Table:
-- | product_id | product_category | product_name           |
-- |------------|------------------|------------------------|
-- | 1          | Analytics        | Azure Databricks       |
-- | 2          | Analytics        | Azure Stream Analytics |
-- | 4          | Containers       | Azure Kubernetes Service |
-- | 5          | Containers       | Azure Service Fabric   |
-- | 6          | Compute          | Virtual Machines       |
-- | 7          | Compute          | Azure Functions        |

-- Example Output:
-- | customer_id |
-- |-------------|
-- | 1           |

WITH RefCategories AS 
(
  SELECT DISTINCT product_category
  FROM products
),
DataSet AS 
(
  SELECT 
    cs.customer_id,
    COUNT(DISTINCT p.product_category) AS distCategory
  FROM customer_contracts AS cs
  INNER JOIN products AS p 
    ON cs.product_id = p.product_id
  GROUP BY cs.customer_id
)
SELECT customer_id
FROM DataSet 
WHERE distCategory = (SELECT COUNT(*) FROM RefCategories);
