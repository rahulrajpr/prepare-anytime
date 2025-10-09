-- Given a table of Facebook posts, for each user who posted at least twice in 2021, write a query to find the number of days between each user’s first post of the year and last post of the year in the year 2021. Output the user and number of the days between each user's first and last post.

-- p.s. If you've read the Ace the Data Science Interview and liked it, consider writing us a review?
-- posts Table:

-- Column Name	Type
-- user_id	integer
-- post_id	integer
-- post_content	text
-- post_date	timestamp


WITH CTE AS 
(
SELECT user_id,
COUNT(*) AS numPosts,
MAX(post_date) AS minDate,
MIN(post_date) AS maxDate
FROM posts
WHERE EXTRACT(YEAR FROM post_date) = 2021
GROUP BY user_id
)
SELECT user_id,
EXTRACT (DAY FROM (minDate-maxDate)) AS days_between
FROM CTE 
WHERE numPosts >= 2