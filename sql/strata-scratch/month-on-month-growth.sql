-- Problem Statement:
-- Given a table of purchases by date, calculate the month-over-month percentage change in revenue. 
-- The output should include the year-month date (YYYY-MM) and percentage change, rounded to the 2nd decimal point, 
-- and sorted from the beginning of the year to the end of the year.

-- The percentage change column will be populated from the 2nd month forward and can be calculated as 
-- ((this month's revenue - last month's revenue) / last month's revenue)*100.

-- Table Schema:
-- sf_transactions Table:
-- | Column Name   | Type    |
-- |---------------|---------|
-- | id            | bigint  |
-- | created_at    | date    |
-- | value         | bigint  |
-- | purchase_id   | bigint  |

-- Example Input (first few rows):
-- | id | created_at | value  | purchase_id |
-- |----|------------|--------|-------------|
-- | 1  | 2019-01-01 | 172692 | 43          |
-- | 2  | 2019-01-05 | 177194 | 36          |
-- | 3  | 2019-01-09 | 109513 | 30          |
-- | ... (additional rows) ... |

-- Expected Output:
-- | year_month | revenue_diff_pct |
-- |------------|------------------|
-- | 2019-01    |                  |
-- | 2019-02    | -28.56           |
-- | 2019-03    | 23.35            |
-- | 2019-04    | -13.84           |
-- | 2019-05    | 13.49            |

with cte as 
(
select 
date_trunc('month', created_at) as mth, sum(value) as revenue
from sf_transactions
group by date_trunc('month', created_at)
),
lastmonthrevenue as 
(
select *,
lag(revenue, 1) over(order by mth asc) as last_month_revenue
from cte
)
select 
  to_char(mth, 'YYYY-MM') as year_month,
  round(((revenue - last_month_revenue)::numeric * 100 / last_month_revenue), 2) as revenue_diff_pct
from lastmonthrevenue
order by mth