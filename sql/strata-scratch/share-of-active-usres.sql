-- Problem Statement:
-- Calculate the percentage of users who are both from the US and have an 'open' status, 
-- as indicated in the fb_active_users table.

-- Table Schema:
-- fb_active_users Table:
-- | Column Name | Type    |
-- |-------------|---------|
-- | user_id     | bigint  |
-- | name        | text    |
-- | status      | text    |
-- | country     | text    |

-- Example Input (first few rows):
-- | user_id | name            | status | country    |
-- |---------|-----------------|--------|------------|
-- | 33      | Amanda Leon     | open   | Australia  |
-- | 27      | Jessica Farrell | open   | Luxembourg |
-- | 18      | Wanda Ramirez   | open   | USA        |
-- | 50      | Samuel Miller   | closed | Brazil     |
-- | 16      | Jacob York      | open   | Australia  |
-- | 25      | Natasha Bradford| closed | USA        |
-- | ... (additional rows) ... |

-- Expected Output:
-- | us_active_share        |
-- |------------------------|
-- | 13.043478260869565     |


SELECT 
  ROUND(
    (SUM(CASE WHEN country = 'USA' AND status = 'open' THEN 1 ELSE 0 END) * 100.0) 
    /
    COUNT(user_id)
    ,15) 
    AS us_active_share
FROM fb_active_users