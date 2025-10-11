-- Problem Statement:
-- In an effort to identify high-value customers, Amazon asked for your help to obtain data about users who go on shopping sprees. 
-- A shopping spree occurs when a user makes purchases on 3 or more consecutive days.

-- List the user IDs who have gone on at least 1 shopping spree in ascending order.

-- Table Schema:
-- transactions Table:
-- | Column Name        | Type      |
-- |--------------------|-----------|
-- | user_id            | integer   |
-- | amount             | float     |
-- | transaction_date   | timestamp |

-- Example Input:
-- | user_id | amount | transaction_date      |
-- |---------|--------|----------------------|
-- | 1       | 9.99   | 08/01/2022 10:00:00  |
-- | 1       | 55     | 08/17/2022 10:00:00  |
-- | 2       | 149.5  | 08/05/2022 10:00:00  |
-- | 2       | 4.89   | 08/06/2022 10:00:00  |
-- | 2       | 34     | 08/07/2022 10:00:00  |

-- Example Output:
-- | user_id |
-- |---------|
-- | 2       |

WITH CTE AS 
(
  SELECT 
    user_id, 
    transaction_date::DATE AS transaction_date,
    SUM(amount) AS amount
  FROM transactions
  GROUP BY user_id, transaction_date
),
ResultHelp AS
(
  SELECT *,
    SUM(CASE WHEN amount > 0.0 THEN 1 END)
    OVER(
      PARTITION BY user_id 
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS threeConsecutiveDaysPurchased
  FROM CTE
)
SELECT DISTINCT user_id
FROM ResultHelp 
WHERE threeConsecutiveDaysPurchased = 3
ORDER BY user_id;
