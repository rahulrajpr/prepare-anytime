-- Assume you're given a table Twitter tweet data, 
-- write a query to obtain a histogram of tweets posted per user in 2022. 
-- Output the tweet count per user as the bucket and the number of Twitter users who fall into that bucket.
-- In other words, 
-- group the users by the number of tweets they posted in 2022 and count the number of users in each group.

-- tweets Table:

-- Column Name	Type
-- tweet_id	    integer
-- user_id	    integer
-- msg	        string
-- tweet_date	timestamp

--=================
-- Solution 
--====================

WITH CTE AS 
(
    SELECT user_id,count(*) AS users_num
    FROM tweets
    WHERE EXTRACT(YEAR FROM tweet_date) = 2022
    GROUP BY user_id
)
SELECT 
    users_num AS tweet_bucket, 
    COUNT(user_id) AS users_num
FROM CTE 
GROUP BY users_num
ORDER BY tweet_bucket ASC