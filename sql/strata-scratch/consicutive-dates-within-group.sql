
-- Problem Statement:
-- Find all the users who were active for 3 consecutive days or more.

-- Table Schema:
-- sf_events Table:
-- | Column Name   | Type             |
-- |---------------|------------------|
-- | account_id    | character varying|
-- | record_date   | date             |
-- | user_id       | character varying|

WITH CTE AS 
(
  SELECT *,
    SUM(1) OVER(PARTITION BY account_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as runningCount,
    MIN(record_date) OVER(PARTITION BY account_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as minDate,
    MAX(record_date) OVER(PARTITION BY account_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as maxDate
  FROM sf_events
)
SELECT DISTINCT user_id
FROM CTE 
WHERE runningCount = 3
  AND (maxDate - minDate) + 1 = 3