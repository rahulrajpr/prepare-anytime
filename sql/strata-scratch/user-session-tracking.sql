-- Problem Statement:
-- Given the users' sessions logs on a particular day, calculate how many hours each user was active that day.

-- Note: The session starts when state=1 and ends when state=0.

-- Table Schema:
-- cust_tracking Table:
-- | Column Name | Type                      |
-- |-------------|---------------------------|
-- | cust_id     | text                      |
-- | state       | bigint                    |
-- | timestamp   | timestamp without time zone |

-- Example Input:
-- | cust_id | state | timestamp           |
-- |---------|-------|---------------------|
-- | c001    | 1     | 2024-11-26 07:00:00 |
-- | c001    | 0     | 2024-11-26 09:30:00 |
-- | c001    | 1     | 2024-11-26 12:00:00 |
-- | c001    | 0     | 2024-11-26 14:30:00 |
-- | c002    | 1     | 2024-11-26 08:00:00 |
-- | c002    | 0     | 2024-11-26 09:30:00 |
-- | ... (additional rows) ... |

-- Expected Output:
-- | cust_id | total_hours |
-- |---------|-------------|
-- | c001    | 5           |
-- | c002    | 4.5         |
-- | c003    | 1.5         |
-- | c004    | 2           |
-- | c005    | 7.5         |

with cte as 
(
select *,
row_number() 
    over(partition by cust_id, state order by timestamp asc) as activityOrder
from cust_tracking
),
intermediateResult as 
(
select 
startsession.cust_id,
startsession.activityOrder,
max(startsession.timestamp) as start_timestamp,
max(endsession.timestamp) as end_timestamp,
(max(endsession.timestamp)::timestamp 
    - max(startsession.timestamp)::timestamp)::interval as session_interval
from cte as startsession
inner join cte as endsession
on startsession.cust_id = endsession.cust_id
and startsession.activityOrder = endsession.activityOrder
where startsession.state = 1
and endsession.state = 0
group by startsession.cust_id,
        startsession.activityOrder
)
select 
  cust_id,
  round(
    extract(epoch from sum(session_interval))::numeric / 60 / 60
    ,1) as total_hours
from intermediateResult
group by cust_id