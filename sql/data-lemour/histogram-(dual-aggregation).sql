-- Problem Statement:
-- Assume you're given a table Twitter tweet data, 
-- write a query to obtain a histogram of tweets posted per user in 2022. 
-- Output the tweet count per user as the bucket and the number of Twitter users who fall into that bucket.
-- In other words, 
-- group the users by the number of tweets they posted in 2022 and count the number of users in each group.

-- Table Schema:
-- tweets Table:
-- | Column Name | Type      |
-- |-------------|-----------|
-- | tweet_id    | integer   |
-- | user_id     | integer   |
-- | msg         | string    |
-- | tweet_date  | timestamp |

-- Example Input:
-- | tweet_id | user_id | msg               | tweet_date           |
-- |----------|---------|-------------------|---------------------|
-- | 1        | 101     | Hello World!      | 01/15/2022 00:00:00 |
-- | 2        | 101     | Beautiful day!    | 02/20/2022 00:00:00 |
-- | 3        | 102     | Learning SQL      | 03/10/2022 00:00:00 |
-- | 4        | 101     | Coffee time       | 04/05/2022 00:00:00 |
-- | 5        | 103     | New job!          | 05/15/2022 00:00:00 |
-- | 6        | 103     | Weekend vibes     | 06/20/2022 00:00:00 |
-- | 7        | 104     | Vacation mode     | 07/01/2022 00:00:00 |

-- Example Output:
-- | tweet_bucket | users_num |
-- |--------------|-----------|
-- | 1            | 2         |
-- | 2            | 1         |
-- | 3            | 1         |

WITH CTE AS 
(
    SELECT 
        user_id, 
        COUNT(*) AS users_num
    FROM tweets
    WHERE EXTRACT(YEAR FROM tweet_date) = 2022
    GROUP BY user_id
)
SELECT 
    users_num AS tweet_bucket, 
    COUNT(user_id) AS users_num
FROM CTE 
GROUP BY users_num
ORDER BY tweet_bucket ASC;