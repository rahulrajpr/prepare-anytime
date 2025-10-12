
-- You are given a dataset that tracks user activity. The dataset includes information 
-- about the date of user activity, the account_id associated with the activity, and 
-- the user_id of the user performing the activity. Each row in the dataset represents 
-- a user's activity on a specific date for a particular account_id.
--
-- Your task is to calculate the monthly retention rate for users for each account_id 
-- for December 2020 and January 2021. The retention rate is defined as the percentage 
-- of users active in a given month who have activity in any future month.
--
-- For instance, a user is considered retained for December 2020 if they have activity 
-- in December 2020 and any subsequent month (e.g., January 2021 or later). Similarly, 
-- a user is retained for January 2021 if they have activity in January 2021 and any 
-- later month (e.g., February 2021 or later).
--
-- The final output should include the account_id and the ratio of the retention rate 
-- in January 2021 to the retention rate in December 2020 for each account_id. If there 
-- are no users retained in December 2020, the retention rate ratio should be set to 0.
--
-- Table: sf_events
-- Columns:
-- | record_date | account_id | user_id |
-- |-------------|------------|---------|
-- | 2021-01-01  | A1         | U1      |
-- | 2021-01-01  | A1         | U2      |
-- | 2021-01-06  | A1         | U3      |
-- | 2021-01-02  | A1         | U1      |
-- | 2020-12-24  | A1         | U2      |
--
-- Expected Output:
-- | account_id | retention |
-- |------------|-----------|
-- | A1         | 1         |
-- | A2         | 1         |
-- | A3         | 0         |

with activity_by_month as 
(
select account_id, user_id, date_trunc('month',record_date) as record_date
from sf_events
group by account_id, user_id, date_trunc('month',record_date)
),
main as 
(
select *, 
lead(record_date,1)
    over(partition  by account_id, user_id order by record_date) as next_activity_date,
case when lead(record_date,1)
    over(partition  by account_id, user_id order by record_date) is not null then 1 end as 
    isretained
from activity_by_month
),
result as 
(
select account_id,record_date,
round(sum(isretained)::NUMERIC/count(user_id),2) as retaintion_rate
from main
group by account_id, record_date
)
select account_id,
COALESCE(
((MAX(case when record_date = '2020-12-01'::DATE THEN retaintion_rate END)::NUMERIC)
/
(MAX(case when record_date = '2021-01-01'::DATE THEN retaintion_rate END)))
,0)
AS retention
from result
group by account_id
order by account_id