-- Problem Statement:
-- UnitedHealth Group (UHG) has a program called Advocate4Me, which allows policy holders (or, members) to call an advocate 
-- and receive support for their health care needs – whether that's claims and benefits support, drug coverage, 
-- pre- and post-authorisation, medical records, emergency assistance, or member portal services.

-- Write a query to obtain the number of unique callers who made calls within a 7-day interval of their previous calls. 
-- If a caller made more than two calls within the 7-day period, count them only once.

-- If you like this question, try out Patient Support Analysis (Part 4)!

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
-- | 13               | 894a08c6-82c6-49ed-84a0-b627752cdca7 | benefits         | 01/11/2023 02:09:23 | 794               |
-- | 13               | 7ee4e5f0-4924-47f7-8809-172bb59c6ef0 | provider network | 02/01/2023 18:41:03 | 659               |
-- | 14               | 0b68aafa-6907-43c3-9dbd-a6c171cf5006 | claims assistance| 02/17/2023 10:03:27 | 757               |
-- | 14               | c4660294-9443-4aba-b6d4-f39a9d5e5f00 | benefits         | 02/21/2023 13:57:31 | 36                |
-- | 15               | 06545ac5-18f5-4ae8-9b1e-087c7dc8deca | member portal    | 01/08/2023 03:19:24 | 973               |
-- | 15               | 9580a1ad-842a-482f-a05c-7e1c09b926b3 | provider network | 01/09/2023 01:33:06 | 729               |

-- Example Output:
-- | policy_holder_count |
-- |---------------------|
-- | 2                   |

WITH CTE AS
    (
  SELECT *,
    LAG(call_date, 1) OVER(PARTITION BY policy_holder_id ORDER BY call_date ASC) AS prevCall_date
  FROM callers
    )
SELECT COUNT(DISTINCT policy_holder_id) AS policy_holder_count 
FROM CTE 
WHERE (call_date - prevCall_date) < INTERVAL '7 DAYS'