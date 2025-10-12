-- Problem Statement:
-- Calculate the friend acceptance rate for each date when friend requests were sent. 
-- A request is sent if action = 'sent' and accepted if action = 'accepted'. 
-- If a request is not accepted, there is no record of it being accepted in the table.

-- The output will only include dates where requests were sent and at least one of them was accepted 
-- (acceptance can occur on any date after the request is sent).

-- Table Schema:
-- fb_friend_requests Table:
-- | Column Name        | Type    |
-- |--------------------|---------|
-- | action             | text    |
-- | date               | date    |
-- | user_id_receiver   | text    |
-- | user_id_sender     | text    |

-- Example Input:
-- | user_id_sender | user_id_receiver | date       | action    |
-- |----------------|------------------|------------|-----------|
-- | ad4943sdz      | 948ksx123d       | 2020-01-04 | sent      |
-- | ad4943sdz      | 948ksx123d       | 2020-01-06 | accepted  |
-- | dfdfxf9483     | 9djjjd9283       | 2020-01-04 | sent      |
-- | dfdfxf9483     | 9djjjd9283       | 2020-01-15 | accepted  |
-- | ffdfff4234234  | lpjzjdi4949      | 2020-01-06 | sent      |

WITH cte AS 
(
  SELECT 
    user_id_sender, 
    user_id_receiver,
    MIN(CASE WHEN action = 'sent' THEN date END) AS request_date, 
    MIN(CASE WHEN action = 'accepted' THEN date END) AS accepted_date
  FROM fb_friend_requests
  WHERE action IN ('sent', 'accepted')
  GROUP BY user_id_sender, user_id_receiver
)
SELECT 
  request_date,
  ROUND(
    SUM(CASE WHEN accepted_date IS NOT NULL THEN 1 ELSE 0 END)::NUMERIC /
    COUNT(user_id_sender), 
    2
  ) AS acceptance_rate
FROM cte 
GROUP BY request_date;