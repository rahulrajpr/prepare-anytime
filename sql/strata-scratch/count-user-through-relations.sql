
-- Problem Statement:
-- Which user flagged the most distinct videos that ended up approved by YouTube? 
-- Output, in one column, their full name or names in case of a tie. 
-- In the user's full name, include a space between the first and the last name.

-- Table Schemas:
-- user_flags Table:
-- | Column Name     | Type    |
-- |-----------------|---------|
-- | user_firstname  | text    |
-- | user_lastname   | text    |
-- | video_id        | text    |
-- | flag_id         | text    |

-- flag_review Table:
-- | Column Name       | Type     |
-- |-------------------|----------|
-- | flag_id           | text     |
-- | reviewed_by_yt    | boolean  |
-- | reviewed_date     | date     |
-- | reviewed_outcome  | text     |

-- Example Input (first few rows):
-- user_flags:
-- | user_firstname | user_lastname | video_id       | flag_id |
-- |----------------|---------------|----------------|---------|
-- | Richard        | Hasson        | y6120QOlsfU    | 0cazx3  |
-- | Mark           | May           | Ct6BUPvE2sM    | 1cn76u  |
-- | Gina           | Korman        | dQw4w9WgXcQ    | 1i43zk  |
-- | ... (additional rows) ... |

-- flag_review:
-- | flag_id | reviewed_by_yt | reviewed_date | reviewed_outcome |
-- |---------|----------------|---------------|------------------|
-- | 0cazx3  | FALSE          |               |                  |
-- | 1cn76u  | TRUE           | 2022-03-15    | REMOVED          |
-- | 1i43zk  | TRUE           | 2022-03-15    | REMOVED          |
-- | ... (additional rows) ... |

-- Expected Result:
-- | username        |
-- |-----------------|
-- | Mark May        |
-- | Richard Hasson  |


WITH cte AS 
(
    SELECT 
        uf.user_firstname || ' ' || uf.user_lastname AS username,
        COUNT(DISTINCT video_id) AS countVideos
    FROM user_flags AS uf
    INNER JOIN flag_review AS fr
        ON uf.flag_id = fr.flag_id
    WHERE fr.reviewed_outcome = 'APPROVED'
    GROUP BY uf.user_firstname || ' ' || uf.user_lastname
)
SELECT username
FROM cte
WHERE countVideos = (SELECT MAX(countVideos) FROM cte)