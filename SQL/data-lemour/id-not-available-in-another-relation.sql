-- Problem Statement:
-- Write a query to return the IDs of the Facebook pages that have zero likes. The output should be sorted in ascending order based on the page IDs.

-- Table Schemas:
-- pages Table:
-- | Column Name | Type    |
-- |-------------|---------|
-- | page_id     | integer |
-- | page_name   | varchar |

-- page_likes Table:
-- | Column Name | Type      |
-- |-------------|-----------|
-- | user_id     | integer   |
-- | page_id     | integer   |
-- | liked_date  | datetime  |

-- Example Input:
-- pages Table:
-- | page_id | page_name            |
-- |---------|----------------------|
-- | 20001   | SQL Solutions        |
-- | 20045   | Brain Exercises      |
-- | 20701   | Tips for Data Analysts |

-- page_likes Table:
-- | user_id | page_id | liked_date        |
-- |---------|---------|-------------------|
-- | 111     | 20001   | 04/08/2022 00:00:00 |
-- | 121     | 20045   | 03/12/2022 00:00:00 |
-- | 156     | 20001   | 07/25/2022 00:00:00 |

-- Example Output:
-- | page_id |
-- |---------|
-- | 20701   |

-- Solution 1: Using EXCEPT
SELECT page_id
FROM
  (
    SELECT page_id
    FROM pages 
    EXCEPT
    SELECT page_id
    FROM page_likes
  ) AS exceptions
ORDER BY page_id;

-- Solution 2: Using LEFT JOIN
SELECT pages.page_id 
FROM pages
LEFT JOIN page_likes
  ON pages.page_id = page_likes.page_id
WHERE page_likes.page_id IS NULL
ORDER BY pages.page_id;