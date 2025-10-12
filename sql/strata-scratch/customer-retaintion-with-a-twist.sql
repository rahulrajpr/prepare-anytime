
-- Problem Statement:
-- Identify returning active users by finding users who made a second purchase within 1 to 7 days after their first purchase. 
-- Ignore same-day purchases. Output a list of these user_ids.

-- Table Schema:
-- amazon_transactions Table:
-- | Column Name   | Type    |
-- |---------------|---------|
-- | created_at    | date    |
-- | id            | bigint  |
-- | item          | text    |
-- | revenue       | bigint  |
-- | user_id       | bigint  |

-- Example Input:
-- | id | user_id | item    | created_at | revenue |
-- |----|---------|---------|------------|---------|
-- | 1  | 109     | milk    | 2020-03-03 | 123     |
-- | 2  | 139     | biscuit | 2020-03-18 | 421     |
-- | 3  | 120     | milk    | 2020-03-18 | 176     |
-- | 4  | 108     | banana  | 2020-03-18 | 862     |
-- | 5  | 130     | milk    | 2020-03-28 | 333     |
-- | ... (additional rows) ... |


WITH CTE AS (
    SELECT 
        user_id,
        created_at::DATE AS created_at
    FROM amazon_transactions
    GROUP BY user_id, created_at::DATE
),
Result AS (
    SELECT *,
        CASE WHEN 
            (created_at::timestamp 
            - MIN(created_at::timestamp) 
                OVER(PARTITION BY user_id)) 
                BETWEEN '1 DAY'::INTERVAL AND '7 DAYS'::INTERVAL 
            THEN 1 
        END AS custAttract
    FROM CTE
)
SELECT DISTINCT user_id
FROM Result
WHERE custAttract = 1 
ORDER BY user_id