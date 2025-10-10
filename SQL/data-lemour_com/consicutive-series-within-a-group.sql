-- Problem Statement:
-- Intuit, a company known for its tax filing products like TurboTax and QuickBooks, offers multiple versions of these products.

-- Write a query that identifies the user IDs of individuals who have filed their taxes using any version of TurboTax 
-- for three or more consecutive years. Each user is allowed to file taxes once a year using a specific product. 
-- Display the output in the ascending order of user IDs.

-- Table Schema:
-- filed_taxes Table:
-- | Column Name   | Type      |
-- |---------------|-----------|
-- | filing_id     | integer   |
-- | user_id       | varchar   |
-- | filing_date   | datetime  |
-- | product       | varchar   |

-- Example Input:
-- | filing_id | user_id | filing_date | product               |
-- |-----------|---------|-------------|----------------------|
-- | 1         | 1       | 4/14/2019   | TurboTax Desktop 2019 |
-- | 2         | 1       | 4/15/2020   | TurboTax Deluxe       |
-- | 3         | 1       | 4/15/2021   | TurboTax Online       |
-- | 4         | 2       | 4/07/2020   | TurboTax Online       |
-- | 5         | 2       | 4/10/2021   | TurboTax Online       |
-- | 6         | 3       | 4/07/2020   | TurboTax Online       |
-- | 7         | 3       | 4/15/2021   | TurboTax Online       |
-- | 8         | 3       | 3/11/2022   | QuickBooks Desktop Pro |
-- | 9         | 4       | 4/15/2022   | QuickBooks Online     |

-- Example Output:
-- | user_id |
-- |---------|
-- | 1       |

WITH userYear AS 
(
  SELECT 
    user_id,
    EXTRACT(YEAR FROM filing_date) AS yr
  FROM filed_taxes
  WHERE product ILIKE '%TurboTax%'
  GROUP BY user_id, yr
),
userYearWithDelta AS 
(
  SELECT *,
    yr - LAG(yr, 1) OVER(PARTITION BY user_id ORDER BY yr ASC) AS YrDelta
  FROM userYear
),
Result AS 
(
  SELECT 
    user_id, 
    MIN(yr) AS mnYr,
    MAX(yr) AS mxYr,
    (MAX(yr) - MIN(yr)) + 1 AS YrsCount,
    CASE 
      WHEN (MAX(yr) - MIN(yr)) = SUM(YrDelta) THEN 1 
      ELSE 0 
    END AS isConsecutive
  FROM userYearWithDelta
  GROUP BY user_id
)
SELECT user_id 
FROM Result
WHERE isConsecutive = 1
  AND YrsCount >= 3
ORDER BY user_id;