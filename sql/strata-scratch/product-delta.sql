-- Problem Statement:
-- Calculate the net change in the number of products launched by companies in 2020 compared to 2019. 
-- Your output should include the company names and the net difference.

-- (Net difference = Number of products launched in 2020 - The number launched in 2019.)

-- Table Schema:
-- car_launches Table:
-- | Column Name    | Type    |
-- |----------------|---------|
-- | company_name   | text    |
-- | product_name   | text    |
-- | year           | bigint  |

SELECT 
    company_name,
    (COUNT(DISTINCT CASE WHEN year = 2020 THEN product_name END) -
     COUNT(DISTINCT CASE WHEN year = 2019 THEN product_name END)) AS net_products
FROM car_launches
GROUP BY company_name
ORDER BY company_name ASC;