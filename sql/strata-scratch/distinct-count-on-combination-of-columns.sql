
-- Problem Statement:
-- For each video, find how many unique users flagged it. 
-- A unique user can be identified using the combination of their first name and last name. 
-- Do not consider rows in which there is no flag ID.

-- Table Schema:
-- user_flags Table:
-- | Column Name     | Type    |
-- |-----------------|---------|
-- | user_firstname  | text    |
-- | user_lastname   | text    |
-- | video_id        | text    |
-- | flag_id         | text    |

-- Example Input (first few rows):
-- | user_firstname | user_lastname | video_id       | flag_id |
-- |----------------|---------------|----------------|---------|
-- | Richard        | Hasson        | y6120QOlsfU    | 0cazx3  |
-- | Mark           | May           | Ct6BUPvE2sM    | 1cn76u  |
-- | Gina           | Korman        | dQw4w9WgXcQ    | 1i43zk  |
-- | Mark           | May           | Ct6BUPvE2sM    | 1n0vef  |
-- | Mark           | May           | jNQXAC9IVRw    | 1sv6ib  |
-- | ... (additional rows) ... |

SELECT 
  video_id,
  COUNT(DISTINCT (user_firstname, user_lastname)) AS num_unique_users
FROM user_flags
WHERE flag_id IS NOT NULL
GROUP BY video_id
ORDER BY video_id