-- Problem Statement:
-- UnitedHealth Group (UHG) has a program called Advocate4Me, which allows policy holders (or, members) to call an advocate 
-- and receive support for their health care needs – whether that's claims and benefits support, drug coverage, 
-- pre- and post-authorisation, medical records, emergency assistance, or member portal services.

-- To analyze the performance of the program, write a query to determine the month-over-month growth rate specifically for long-calls. 
-- A long-call is defined as any call lasting more than 5 minutes (300 seconds).

-- Output the year and month in numerical format and chronological order, along with the growth percentage rounded to 1 decimal place.

-- Table Schema:
-- callers Table:
-- | Column Name          | Type      |
-- |----------------------|-----------|
-- | policy_holder_id     | integer   |
-- | case_id              | varchar   |
-- | call_category        | varchar   |
-- | call_date            | timestamp |
-- | call_duration_secs   | integer   |

-- Example Input:
-- | policy_holder_id | case_id                             | call_category    | call_date           | call_duration_secs |
-- |------------------|-------------------------------------|------------------|---------------------|-------------------|
-- | 1                | f1d012f9-9d02-4966-a968-bf6c5bc9a9fe | emergency assistance | 04/13/2023 19:16:53 | 144               |
-- | 1                | 41ce8fb6-1ddd-4f50-ac31-07bfcce6aaab | authorisation    | 05/25/2023 09:09:30 | 815               |
-- | 2                | 8471a3d4-6fc7-4bb2-9fc7-4583e3638a9e | emergency assistance | 03/09/2023 10:58:54 | 128               |
-- | 2                | 38208fae-bad0-49bf-99aa-7842ba2e37bc | benefits         | 06/05/2023 07:35:43 | 619               |
-- | 3                | f0e7a8e3-df93-40f3-9b5e-fadff9ebe072 | provider network | 01/12/2023 04:53:41 | 483               |
-- | 3                | b72f91e6-c3f8-4358-a1f2-c9507e8dcba4 | member portal    | 04/04/2023 20:03:22 | 275               |
-- | 3                | 3acbe22d-22b3-4144-954d-74c127bc49ea | benefits         | 04/12/2023 00:05:29 | 329               |
-- | 3                | e32b61c2-a90d-4371-a5ee-6bc44fa49bbd | benefits         | 05/25/2023 06:07:41 | 512               |
-- | 3                | 6099f469-b5d6-4447-9acf-d936355eae7c | emergency assistance | 06/11/2023 12:04:21 | 33                |

-- Example Output:
-- | yr   | mth | long_calls_growth_pct |
-- |------|-----|----------------------|
-- | 2023 | 1   | NULL                 |
-- | 2023 | 2   | 0.0                  |
-- | 2023 | 3   | 100.0                |
-- | 2023 | 4   | 200.0                |
-- | 2023 | 5   | -33.3                |
-- | 2023 | 6   | 0.0                  |


WITH CTE AS 
(
  SELECT 
    DATE_TRUNC('month', call_date) AS YrMn, 
    COUNT(case_id) AS numCalls
  FROM callers
  WHERE call_duration_secs > 300
  GROUP BY YrMn
)
SELECT 
  EXTRACT(YEAR FROM YrMn) AS yr,
  EXTRACT(MONTH FROM YrMn) AS mth,
  ROUND((
        (numCalls::NUMERIC) /
        LAG(numCalls) OVER(ORDER BY YrMn ASC)) - 1.0) * 100
        ,1) AS long_calls_growth_pct
FROM CTE
ORDER BY yr, mth