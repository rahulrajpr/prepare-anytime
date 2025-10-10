-- Problem Statement:
-- Given a table of Facebook posts, for each user who posted at least twice in 2021, write a query to find the number of days between each user's first post of the year and last post of the year in the year 2021. 
-- Output the user and number of the days between each user's first and last post.

-- p.s. If you've read the Ace the Data Science Interview and liked it, consider writing us a review?

-- Table Schema:
-- posts Table:
-- | Column Name    | Type      |
-- |----------------|-----------|
-- | user_id        | integer   |
-- | post_id        | integer   |
-- | post_content   | text      |
-- | post_date      | timestamp |

-- Example Input:
-- | user_id | post_id | post_content          | post_date           |
-- |---------|---------|-----------------------|---------------------|
-- | 151652  | 599415  | Need a hug            | 02/10/2021 00:00:00 |
-- | 151652  | 599416  | Bedtime stories?      | 02/11/2021 00:00:00 |
-- | 151652  | 599417  | Happy Birthday!       | 02/12/2021 00:00:00 |
-- | 661093  | 624356  | Say hello to my dog   | 06/01/2021 00:00:00 |
-- | 661093  | 624357  | Vacation mode: ON     | 06/10/2021 00:00:00 |
-- | 661093  | 624358  | Beach day!            | 06/20/2021 00:00:00 |

-- Example Output:
-- | user_id | days_between |
-- |---------|--------------|
-- | 151652  | 2            |
-- | 661093  | 19           |

WITH CTE AS 
(
SELECT 
  user_id,
  COUNT(*) AS numPosts,
  MAX(post_date) AS maxDate,
  MIN(post_date) AS minDate
FROM posts
WHERE EXTRACT(YEAR FROM post_date) = 2021
GROUP BY user_id
)
SELECT 
  user_id,
  EXTRACT(DAY FROM (maxDate - minDate)) AS days_between
FROM CTE 
WHERE numPosts >= 2;