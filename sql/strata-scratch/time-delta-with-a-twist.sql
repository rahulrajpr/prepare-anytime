
-- Problem Statement:
-- Calculate each user's average session time, where a session is defined as the time difference between 
-- a page_load and a page_exit. Assume each user has only one session per day. If there are multiple 
-- page_load or page_exit events on the same day, use only the latest page_load and the earliest page_exit. 
-- Only consider sessions where the page_load occurs before the page_exit on the same day. 
-- Output the user_id and their average session time.

-- Table Schema:
-- facebook_web_log Table:
-- | Column Name | Type                      |
-- |-------------|---------------------------|
-- | action      | text                      |
-- | timestamp   | timestamp without time zone |
-- | user_id     | bigint                    |

-- Example Input:
-- | user_id | timestamp           | action      |
-- |---------|---------------------|-------------|
-- | 0       | 2019-04-25 13:30:15 | page_load   |
-- | 0       | 2019-04-25 13:30:18 | page_load   |
-- | 0       | 2019-04-25 13:30:40 | scroll_down |
-- | 0       | 2019-04-25 13:30:45 | scroll_up   |
-- | 0       | 2019-04-25 13:31:10 | scroll_down |
-- | 0       | 2019-04-25 13:31:25 | scroll_down |
-- | 0       | 2019-04-25 13:31:40 | page_exit   |
-- | 1       | 2019-04-25 13:40:00 | page_load   |

WITH cte AS 
(
  SELECT 
    user_id, 
    timestamp,
    action,
    CASE WHEN action = 'page_load' THEN timestamp END AS page_load,
    CASE WHEN action = 'page_exit' THEN timestamp END AS page_exit,
    MAX(CASE WHEN action = 'page_exit' THEN timestamp END) 
      OVER(PARTITION BY user_id, timestamp::DATE) AS max_page_exit
  FROM facebook_web_log
  WHERE action IN ('page_load', 'page_exit')
),
intermediateResult AS 
(
  SELECT 
    user_id,
    timestamp::DATE AS date,
    MAX(CASE WHEN page_load < max_page_exit THEN page_load ELSE NULL END) AS max_page_load,
    MAX(max_page_exit) AS max_page_exit
  FROM cte
  GROUP BY user_id, timestamp::DATE
)
SELECT 
  main.user_id,  
  AVG((main.max_page_exit - main.max_page_load)) AS session_duration
FROM intermediateResult AS main
WHERE main.max_page_load IS NOT NULL 
  AND main.max_page_exit IS NOT NULL
GROUP BY main.user_id
HAVING AVG((main.max_page_exit - main.max_page_load)) IS NOT NULL;