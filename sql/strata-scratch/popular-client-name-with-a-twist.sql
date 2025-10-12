-- Problem Statement:
-- Select the most popular client_id based on the number of users who individually have at least 50% 
-- of their events from the following list: 'video call received', 'video call sent', 
-- 'voice call received', 'voice call sent'.

-- Table Schema:
-- fact_events Table:
-- | Column Name   | Type    |
-- |---------------|---------|
-- | id            | bigint  |
-- | time_id       | date    |
-- | user_id       | text    |
-- | customer_id   | text    |
-- | client_id     | text    |
-- | event_type    | text    |
-- | event_id      | bigint  |

-- Example Input (first few rows):
-- | id | time_id   | user_id   | customer_id | client_id | event_type        | event_id |
-- |----|-----------|-----------|-------------|-----------|-------------------|----------|
-- | 1  | 2020-02-28| 3668-QPYBK| Sendit      | desktop   | message sent      | 3        |
-- | 2  | 2020-02-28| 7892-POOKP| Connectix   | mobile    | file received     | 2        |
-- | 3  | 2020-04-03| 9763-GRSKD| Zoomit      | desktop   | video call received| 7        |
-- | ... (additional rows) ... |

-- Expected Output:
-- | client_id |
-- |-----------|
-- | desktop   |

with relevant_users as 
(
  select 
    user_id
  from fact_events
  group by user_id
  having 
    round(
        (sum(case when event_type in 
                            ('video call received', 'video call sent','voice call received', 'voice call sent')
                  then 1 else 0 end)::numeric * 100) 
        /
        count(user_id)
        ,2) >= 50.00
),
intermediateresult as 
(
  select 
    client_id,
    count(client_id) as cnt
  from fact_events
  where user_id in (select user_id from relevant_users)
  group by client_id
)
select 
  client_id
from intermediateresult
order by cnt desc
limit 1