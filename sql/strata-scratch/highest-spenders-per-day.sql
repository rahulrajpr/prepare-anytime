-- Problem Statement:
-- Find the customers with the highest daily total order cost between 2019-02-01 and 2019-05-01. 
-- If a customer had more than one order on a certain day, sum the order costs on a daily basis. 
-- Output each customer's first name, total cost of their items, and the date.

-- For simplicity, you can assume that every first name in the dataset is unique.

-- Table Schemas:
-- customers Table:
-- | Column Name    | Type    |
-- |----------------|---------|
-- | address        | text    |
-- | city           | text    |
-- | first_name     | text    |
-- | id             | bigint  |
-- | last_name      | text    |
-- | phone_number   | text    |

-- orders Table:
-- | Column Name       | Type    |
-- |-------------------|---------|
-- | cust_id           | bigint  |
-- | id                | bigint  |
-- | order_date        | date    |
-- | order_details     | text    |
-- | total_order_cost  | bigint  |

WITH cte AS 
(
  SELECT 
    orders.order_date AS order_date, 
    customers.id AS customer_id,
    MAX(customers.first_name) AS customer_first_name,
    SUM(total_order_cost) AS total_order_cost
  FROM orders
  INNER JOIN customers 
    ON orders.cust_id = customers.id
  WHERE orders.order_date BETWEEN '2019-02-01' AND '2019-05-01'
  GROUP BY customer_id, orders.order_date
),
intermediateResult AS 
(
  SELECT *, 
    DENSE_RANK() OVER(
      PARTITION BY order_date 
      ORDER BY total_order_cost DESC
    ) AS densRnk 
  FROM cte 
)
SELECT 
  customer_first_name AS first_name,
  order_date AS order_date,
  total_order_cost AS max_cost
FROM intermediateResult
WHERE densRnk = 1
ORDER BY first_name, order_date;