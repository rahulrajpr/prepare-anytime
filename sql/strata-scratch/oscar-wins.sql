-- Problem Statement:
-- Find the genre of the person with the most number of oscar winnings.

-- If there are more than one person with the same number of oscar wins, return the first one in alphabetic order 
-- based on their name. Use the names as keys when joining the tables.

-- Table Schemas:
-- oscar_nominees Table:
-- | Column Name | Type    |
-- |-------------|---------|
-- | year        | bigint  |
-- | category    | text    |
-- | nominee     | text    |
-- | movie       | text    |
-- | winner      | boolean |
-- | id          | bigint  |

-- nominee_information Table:
-- | Column Name   | Type              |
-- |---------------|-------------------|
-- | name          | character varying |
-- | amg_person_id | character varying |
-- | top_genre     | character varying |
-- | birthday      | date              |
-- | id            | bigint            |

-- Example Input (first few rows):
-- oscar_nominees:
-- | year | category                     | nominee         | movie               | winner | id |
-- |------|------------------------------|-----------------|---------------------|--------|----|
-- | 2006 | actress in a supporting role | Abigail Breslin | Little Miss Sunshine| FALSE  | 1  |
-- | 1984 | actor in a supporting role   | Adolph Caesar   | A Soldier's Story   | FALSE  | 2  |
-- | ... (additional rows) ... |

-- nominee_information:
-- | name          | amg_person_id | top_genre | birthday   | id  |
-- |---------------|---------------|-----------|------------|-----|
-- | Ruby Dee      | P 18243       | Drama     | 1924-10-27 | 234 |
-- | Hal Holbrook  | P 32790       | Drama     | 1925-02-17 | 241 |
-- | ... (additional rows) ... |

-- Expected Output:
-- | top_genre |
-- |-----------|
-- | Drama     |

WITH cte AS 
(
  SELECT 
    nominee, COUNT(id) AS oscarwins
  FROM oscar_nominees
  WHERE winner = TRUE
  GROUP BY nominee
)
SELECT 
    info.top_genre
FROM cte AS main
INNER JOIN nominee_information AS info
  ON main.nominee = info.name
WHERE oscarwins = (SELECT MAX(oscarwins) FROM cte)
ORDER BY main.nominee
LIMIT 1;