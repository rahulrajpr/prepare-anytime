-- Problem Statement:
-- Find the best-selling item for each month (no need to separate months by year). 
-- The best-selling item is determined by the highest total sales amount, 
-- calculated as: total_paid = unitprice * quantity. 
-- Output the month, description of the item, and the total amount paid.

-- Table Schema:
-- online_retail Table:
-- | Column Name   | Type             |
-- |---------------|------------------|
-- | invoiceno     | text             |
-- | stockcode     | text             |
-- | description   | text             |
-- | quantity      | bigint           |
-- | invoicedate   | date             |
-- | unitprice     | double precision |
-- | customerid    | double precision |
-- | country       | text             |

-- Example Input (first few rows):
-- | invoiceno | stockcode | description                    | quantity | invoicedate | unitprice | customerid | country       |
-- |-----------|-----------|--------------------------------|----------|-------------|-----------|------------|---------------|
-- | 544586    | 21890     | S/6 WOODEN SKITTLES IN COTTON BAG | 3       | 2011-02-21  | 2.95      | 17338      | United Kingdom|
-- | 541104    | 84509G    | SET OF 4 FAIRY CAKE PLACEMATS  | 3        | 2011-01-13  | 3.29      |            | United Kingdom|
-- | 560772    | 22499     | WOODEN UNION JACK BUNTING      | 3        | 2011-07-20  | 4.96      |            | United Kingdom|
-- | ... (additional rows) ... |

-- Expected Output:
-- | month | description              | total_paid |
-- |-------|--------------------------|------------|
-- | 1     | LUNCH BAG SPACEBOY DESIGN| 74.26      |
-- | 2     | REGENCY CAKESTAND 3 TIER | 38.25      |
-- | 3     | PAPER BUNTING WHITE LACE | 102        |
-- | 4     | SPACEBOY LUNCH BOX       | 23.4       |
-- | 5     | PAPER BUNTING WHITE LACE | 51         |

WITH cte AS 
(
  SELECT 
    EXTRACT(MONTH FROM invoicedate) AS mth, 
    stockcode,
    description,
    SUM(quantity * unitprice) AS sale
  FROM online_retail
  GROUP BY EXTRACT(MONTH FROM invoicedate), stockcode, description
),
intermediateResult AS 
(
  SELECT *,
    DENSE_RANK() OVER(
      PARTITION BY mth 
      ORDER BY sale DESC
    ) AS dnsrank
  FROM cte 
)
SELECT 
  mth AS month, 
  description,
  sale AS total_paid
FROM intermediateResult
WHERE dnsrank = 1
ORDER BY mth, description