-- Problem Statement:
-- Amazon wants to maximize the storage capacity of its 500,000 square-foot warehouse by prioritizing a specific batch of prime items. 
-- The specific prime product batch detailed in the inventory table must be maintained.

-- So, if the prime product batch specified in the item_category column included 1 laptop and 1 side table, that would be the base batch. 
-- We could not add another laptop without also adding a side table; they come all together as a batch set.

-- After prioritizing the maximum number of prime batches, any remaining square footage will be utilized to stock non-prime batches, 
-- which also come in batch sets and cannot be separated into individual items.

-- Write a query to find the maximum number of prime and non-prime batches that can be stored in the 500,000 square feet warehouse based on the following criteria:
-- - Prioritize stocking prime batches
-- - After accommodating prime items, allocate any remaining space to non-prime batches

-- Output the item_type with prime_eligible first followed by not_prime, along with the maximum number of batches that can be stocked.

-- Assumptions:
-- - Products must be stocked in batches, so we want to find the largest available quantity of prime batches, and then the largest available quantity of non-prime batches
-- - Non-prime items must always be available in stock to meet customer demand, so the non-prime item count should never be zero.
-- - Item count should be whole numbers (integers).

-- Table Schema:
-- inventory Table:
-- | Column Name      | Type     |
-- |------------------|----------|
-- | item_id          | integer  |
-- | item_type        | string   |
-- | item_category    | string   |
-- | square_footage   | decimal  |

-- Example Input:
-- | item_id | item_type      | item_category      | square_footage |
-- |---------|----------------|--------------------|----------------|
-- | 1374    | prime_eligible | mini refrigerator | 68.00          |
-- | 4245    | not_prime      | standing lamp      | 26.40          |
-- | 2452    | prime_eligible | television         | 85.00          |
-- | 3255    | not_prime      | side table         | 22.60          |
-- | 1672    | prime_eligible | laptop             | 8.50           |

-- Example Output:
-- | item_type      | item_count |
-- |----------------|------------|
-- | prime_eligible | 9285       |
-- | not_prime      | 6          |

WITH primeItems AS 
(
  SELECT 
    'prime_eligible' AS item_type,
    SUM(CASE WHEN item_type = 'prime_eligible' THEN square_footage END) AS SpacePerPrimeBatch,
    FLOOR(500000::NUMERIC / SUM(CASE WHEN item_type = 'prime_eligible' THEN square_footage END)) AS batch_count
  FROM inventory
),
Non_primeItems AS 
(
  SELECT 
    'not_prime' AS item_type,
    FLOOR(
      (500000 - (SELECT batch_count * SpacePerPrimeBatch FROM primeItems))::NUMERIC /
      SUM(CASE WHEN item_type = 'not_prime' THEN square_footage END)
    ) AS batch_count 
  FROM inventory
)
SELECT item_type, batch_count AS item_count
FROM primeItems
UNION ALL
SELECT item_type, batch_count AS item_count
FROM Non_primeItems;