
-- Given the reviews table, write a query to retrieve the average star rating for each product, grouped by month. The output should display the month as a numerical value, product ID, and average star rating rounded to two decimal places. Sort the output first by month and then by product ID.

-- P.S. If you've read the Ace the Data Science Interview, and liked it, consider writing us a review?
-- reviews Table:
-- Column Name	Type
-- review_id	integer
-- user_id	integer
-- submit_date	datetime
-- product_id	integer
-- stars	integer (1-5)

SELECT
EXTRACT(MONTH FROM submit_date) AS mth,
product_id,
-- ROUND(AVG(stars::FLOAT),2) AS avg_stars -- it does not work
ROUND(AVG(stars::NUMERIC),2) AS avg_stars
FROM reviews
GROUP BY mth, product_id
ORDER BY  mth, product_id