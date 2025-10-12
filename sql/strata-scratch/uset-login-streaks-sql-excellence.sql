-- Problem Statement:
-- Provided a table with user id and the dates they visited the platform, find the top 3 users 
-- with the longest continuous streak of visiting the platform as of August 10, 2022. 
-- Output the user ID and the length of the streak.

-- In case of a tie, display all users with the top three longest streaks.

-- Table Schema:
-- user_streaks Table:
-- | Column Name   | Type    |
-- |---------------|---------|
-- | user_id       | text    |
-- | date_visited  | date    |

-- Example Input (first few rows):
-- | user_id | date_visited |
-- |---------|--------------|
-- | u001    | 2022-08-01   |
-- | u001    | 2022-08-01   |
-- | u004    | 2022-08-01   |
-- | u005    | 2022-08-01   |
-- | u005    | 2022-08-01   |
-- | u003    | 2022-08-02   |
-- | ... (additional rows) ... |

-- Expected Output:
-- | user_id | streak_length |
-- |---------|---------------|
-- | u004    | 10            |
-- | u005    | 10            |
-- | u003    | 5             |
-- | u001    | 4             |
-- | u006    | 4             |

with date_extremes as 
(
select 
min(date_visited::date) as start_date,
max(date_visited::date) as end_date 
from user_streaks
), 
all_dates as 
(
select date_series
from date_extremes,
generate_series(start_date, end_date, '1 day'::interval) as date_series
),
all_users as 
(
select user_id
from user_streaks
group by user_id
),
all_dates_all_user as 
(
select user_id, date_series
from all_dates
cross join all_users
),
unique_visits as
(
select user_id, date_visited::date as date_visited
from user_streaks
group by user_id, date_visited::date 
),
main as 
(
select 
all_userdate.user_id,
all_userdate.date_series,
act_userdate.date_visited,
all_userdate.date_series - act_userdate.date_visited as dategap_group
from all_dates_all_user as all_userdate
    left join unique_visits as act_userdate
        on all_userdate.user_id = act_userdate.user_id
        and all_userdate.date_series = act_userdate.date_visited
),
streaks as
(
select 
user_id, 
dategap_group,
count(date_visited) as streak_length
from main
group by user_id, dategap_group
), 
streaks_rank as 
(
select *,
dense_rank() over(order by streak_length desc) as dnsRank
from streaks
)
select 
user_id, 
streak_length
from streaks_rank
where dnsRank <= 3