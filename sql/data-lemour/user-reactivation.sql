-- Problem Statement:
-- Imagine you're provided with a table containing information about user logins on Facebook in 2022. 
-- Write a query that determines the number of reactivated users for a given month. 
-- Reactivated users are those who were inactive the previous month but logged in during the current month.

-- Output the month in numerical format along with the count of reactivated users.

-- Important assumptions to consider:
-- - The user_logins table only contains data for the year 2022 and there are no missing dates within that period.
-- - For instance, if a user whose first login date is on 3 March 2022, we assume that they had previously 
--   logged in during the year 2021. Although the data for their previous logins is not present in the 
--   user_logins table, we consider these users as reactivated users.

-- As of Aug 4th, 2023, we have carefully reviewed the feedback received and made necessary updates to the solution.

-- Table Schema:
-- user_logins Table:
-- | Column Name  | Type      |
-- |--------------|-----------|
-- | user_id      | integer   |
-- | login_date   | datetime  |

-- Example Input:
-- | user_id | login_date        |
-- |---------|-------------------|
-- | 123     | 02/22/2022 12:00:00 |
-- | 112     | 03/15/2022 12:00:00 |
-- | 245     | 03/28/2022 12:00:00 |
-- | 123     | 05/01/2022 12:00:00 |
-- | 725     | 05/25/2022 12:00:00 |

-- Example Output:
-- | mth | reactivated_users |
-- |-----|-------------------|
-- | 2   | 1                 |
-- | 3   | 2                 |
-- | 5   | 2                 |


WITH MonthlyActivity AS (
    SELECT 
        user_id,
        DATE_TRUNC('month', login_date) AS activity_month
    FROM user_logins
    WHERE EXTRACT(YEAR FROM login_date) = 2022
    GROUP BY user_id, DATE_TRUNC('month', login_date)
),
UserMonthlyStatus AS (
    SELECT 
        user_id,
        activity_month,
        EXTRACT(MONTH FROM activity_month) AS month_num,
        LAG(activity_month) OVER (PARTITION BY user_id ORDER BY activity_month) AS previous_activity_month
    FROM MonthlyActivity
),
ReactivatedUsers AS (
    SELECT 
        month_num,
        user_id
    FROM UserMonthlyStatus
    WHERE 
        -- User is reactivated if:
        -- 1. This is their first appearance in 2022 (previous_activity_month is NULL)
        -- OR 2. There was a gap of at least 1 month since their last activity
        previous_activity_month IS NULL 
        OR activity_month > previous_activity_month + INTERVAL '1 month'
)
SELECT 
    month_num AS mth,
    COUNT(user_id) AS reactivated_users
FROM ReactivatedUsers
GROUP BY month_num
ORDER BY mth;