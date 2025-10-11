-- Problem Statement:
-- Amazon Web Services (AWS) is powered by fleets of servers. Senior management has requested data-driven solutions to optimize server usage.

-- Write a query that calculates the total time that the fleet of servers was running. The output should be in units of full days.

-- Assumptions:
-- - Each server might start and stop several times.
-- - The total time in which the server fleet is running can be calculated as the sum of each server's uptime.

-- Table Schema:
-- server_utilization Table:
-- | Column Name      | Type      |
-- |------------------|-----------|
-- | server_id        | integer   |
-- | status_time      | timestamp |
-- | session_status   | string    |

-- Example Input:
-- | server_id | status_time        | session_status |
-- |-----------|-------------------|----------------|
-- | 1         | 08/02/2022 10:00:00 | start         |
-- | 1         | 08/04/2022 10:00:00 | stop          |
-- | 2         | 08/17/2022 10:00:00 | start         |
-- | 2         | 08/24/2022 10:00:00 | stop          |

-- Example Output:
-- | total_uptime_days |
-- |-------------------|
-- | 21                |

WITH CTE AS 
(
  SELECT *, 
    LEAD(status_time, 1) OVER(PARTITION BY server_id ORDER BY status_time ASC) AS nextTimeStamp
  FROM server_utilization  
),
Result AS 
(
  SELECT 
    server_id,
    status_time AS start_time, 
    nextTimeStamp AS stop_time,
    nextTimeStamp - status_time AS uptime
  FROM CTE 
  WHERE session_status = 'start'
)
SELECT 
  EXTRACT(DAYS FROM JUSTIFY_HOURS(SUM(uptime))) AS total_uptime_days
FROM Result