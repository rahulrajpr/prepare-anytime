-- Problem Statement:
-- Compare the total number of comments made by users in each country between December 2019 and January 2020. 
-- For each month, rank countries by total comments using dense ranking (i.e., avoid gaps between ranks) in descending order. 
-- Then, return the names of the countries whose rank decreased from December to January.

-- Table Schemas:
-- fb_comments_count Table:
-- | Column Name         | Type    |
-- |---------------------|---------|
-- | user_id             | bigint  |
-- | created_at          | date    |
-- | number_of_comments  | bigint  |

-- fb_active_users Table:
-- | Column Name | Type    |
-- |-------------|---------|
-- | user_id     | bigint  |
-- | name        | text    |
-- | status      | text    |
-- | country     | text    |

-- Example Input (first few rows):
-- fb_comments_count:
-- | user_id | created_at  | number_of_comments |
-- |---------|-------------|-------------------|
-- | 18      | 2019-12-29  | 1                 |
-- | 25      | 2019-12-21  | 1                 |
-- | 78      | 2020-01-04  | 1                 |
-- | ... (additional rows) ... |

-- fb_active_users:
-- | user_id | name            | status | country    |
-- |---------|-----------------|--------|------------|
-- | 33      | Amanda Leon     | open   | Australia  |
-- | 27      | Jessica Farrell | open   | Luxembourg |
-- | 18      | Wanda Ramirez   | open   | USA        |
-- | ... (additional rows) ... |

-- Expected Output:
-- | country |
-- |---------|
-- | Mali    |

WITH cte AS 
(
  SELECT 
    EXTRACT(MONTH FROM comments.created_at) AS mth,
    users.country,
    SUM(comments.number_of_comments) AS num_comments
  FROM fb_comments_count AS comments
  INNER JOIN fb_active_users AS users
    ON comments.user_id = users.user_id
  WHERE comments.created_at::DATE BETWEEN '2019-12-01'::DATE AND '2020-01-31'::DATE
  GROUP BY EXTRACT(MONTH FROM comments.created_at), users.country 
),
intermediateResult AS 
(
  SELECT *,
    DENSE_RANK() OVER(
      PARTITION BY mth 
      ORDER BY num_comments DESC
    ) AS rankCountry
  FROM cte
)
SELECT country
FROM intermediateResult
GROUP BY country
HAVING MAX(CASE WHEN mth = 1 THEN rankCountry END) <
       MAX(CASE WHEN mth = 12 THEN rankCountry END)
ORDER BY country