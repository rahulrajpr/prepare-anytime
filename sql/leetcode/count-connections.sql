-- Table: RequestAccepted

-- +----------------+---------+
-- | Column Name    | Type    |
-- +----------------+---------+
-- | requester_id   | int     |
-- | accepter_id    | int     |
-- | accept_date    | date    |
-- +----------------+---------+
-- (requester_id, accepter_id) is the primary key (combination of columns with unique values) for this table.
-- This table contains the ID of the user who sent the request, the ID of the user who received the request, and the date when the request was accepted.

-- Write a solution to find the people who have the most friends and the most friends number.

-- The test cases are generated so that only one person has the most friends.

-- The result format is in the following example.

-- Example 1:

-- Input: 
-- RequestAccepted table:

-- +--------------+-------------+-------------+
-- | requester_id | accepter_id | accept_date |
-- +--------------+-------------+-------------+
-- | 1            | 2           | 2016/06/03  |
-- | 1            | 3           | 2016/06/08  |
-- | 2            | 3           | 2016/06/08  |
-- | 3            | 4           | 2016/06/09  |
-- +--------------+-------------+-------------+
-- Output: 
-- +----+-----+
-- | id | num |
-- +----+-----+
-- | 3  | 3   |
-- +----+-----+

WITH CTE AS 
(
SELECT requester_id AS id
FROM RequestAccepted
WHERE accept_date IS NOT NULL
UNION ALL 
SELECT accepter_id AS id
FROM RequestAccepted
WHERE accept_date IS NOT NULL
)
SELECT Id, COUNT(id) AS num
FROM CTE 
GROUP BY id
ORDER BY COUNT(id) DESC
LIMIT 1