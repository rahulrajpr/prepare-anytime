-- Problem Statement:
-- Given the reviews table, write a query to retrieve the average star rating for each product, grouped by month. 
-- The output should display the month as a numerical value, product ID, and average star rating rounded to two decimal places. 
-- Sort the output first by month and then by product ID.

-- P.S. If you've read the Ace the Data Science Interview, and liked it, consider writing us a review?

-- Table Schema:
-- reviews Table:
-- | Column Name  | Type      |
-- |--------------|-----------|
-- | review_id    | integer   |
-- | user_id      | integer   |
-- | submit_date  | datetime  |
-- | product_id   | integer   |
-- | stars        | integer (1-5) |

-- Example Input:
-- | review_id | user_id | submit_date        | product_id | stars |
-- |-----------|---------|-------------------|------------|-------|
-- | 1         | 101     | 01/15/2023 00:00:00 | 5001       | 5     |
-- | 2         | 102     | 01/20/2023 00:00:00 | 5001       | 4     |
-- | 3         | 103     | 02/05/2023 00:00:00 | 5002       | 3     |
-- | 4         | 104     | 02/10/2023 00:00:00 | 5001       | 5     |
-- | 5         | 105     | 02/15/2023 00:00:00 | 5002       | 2     |
-- | 6         | 106     | 03/01/2023 00:00:00 | 5001       | 4     |

-- Example Output:
-- | mth | product_id | avg_stars |
-- |-----|------------|-----------|
-- | 1   | 5001       | 4.50      |
-- | 2   | 5001       | 5.00      |
-- | 2   | 5002       | 2.50      |
-- | 3   | 5001       | 4.00      |

SELECT
  EXTRACT(MONTH FROM submit_date) AS mth,
  product_id,
  ROUND(AVG(stars::NUMERIC), 2) AS avg_stars
FROM reviews
GROUP BY mth, product_id
ORDER BY mth, product_id;