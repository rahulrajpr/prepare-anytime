
-- Problem Statement:
-- Find the email activity rank for each user. Email activity rank is defined by the total number of emails sent. 
-- The user with the highest number of emails sent will have a rank of 1, and so on. 
-- Output the user, total emails, and their activity rank.

-- Requirements:
-- • Order records first by the total emails in descending order.
-- • Then, sort users with the same number of emails in alphabetical order by their username.
-- • In your rankings, return a unique value (i.e., a unique rank) even if multiple users have the same number of emails.

-- Table Schema:
-- google_gmail_emails Table:
-- | Column Name | Type    |
-- |-------------|---------|
-- | id          | bigint  |
-- | from_user   | text    |
-- | to_user     | text    |
-- | day         | bigint  |

-- Example Input (first few rows):
-- | id | from_user           | to_user             | day |
-- |----|---------------------|---------------------|-----|
-- | 0  | 6edf0be4b2267df1fa | 75d295377a46f83236 | 10  |
-- | 1  | 6edf0be4b2267df1fa | 32ded68d89443e808  | 6   |
-- | 2  | 6edf0be4b2267df1fa | 55e60cfcc9dc49c17e | 10  |
-- | ... (additional rows) ... |

-- Expected Output:
-- | user_id           | total_emails | activity_rank |
-- |-------------------|--------------|---------------|
-- | 32ded68d89443e808 | 19           | 1             |
-- | ef5fe98c6b9f313075 | 19           | 2             |
-- | 5b8754928306a18b68 | 18           | 3             |
-- | 55e60cfcc9dc49c17e | 16           | 4             |
-- | 91f59516cb9dee1e88 | 16           | 5             |

WITH cte AS 
(
  SELECT 
    from_user, 
    COUNT(id) AS total_emails
  FROM google_gmail_emails
  GROUP BY from_user
)
SELECT 
  from_user AS user_id,
  total_emails,
  ROW_NUMBER() OVER(
    ORDER BY total_emails DESC, from_user ASC
  ) AS activity_rank
FROM cte;