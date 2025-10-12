-- Problem Statement:
-- Find the total number of downloads for paying and non-paying users by date. 
-- Include only records where non-paying customers have more downloads than paying customers. 
-- The output should be sorted by earliest date first and contain 3 columns: date, non-paying downloads, paying downloads.

-- Hint: In Oracle you should use "date" when referring to date column (reserved keyword).

-- Table Schemas:
-- ms_user_dimension Table:
-- | Column Name | Type    |
-- |-------------|---------|
-- | user_id     | bigint  |
-- | acc_id      | bigint  |

-- ms_acc_dimension Table:
-- | Column Name       | Type    |
-- |-------------------|---------|
-- | acc_id            | bigint  |
-- | paying_customer   | text    |

-- ms_download_facts Table:
-- | Column Name | Type    |
-- |-------------|---------|
-- | date        | date    |
-- | user_id     | bigint  |
-- | downloads   | bigint  |

-- Example Input:
-- ms_user_dimension (first few rows):
-- | user_id | acc_id |
-- |---------|--------|
-- | 1       | 716    |
-- | 2       | 749    |
-- | 3       | 713    |
-- | ...     | ...    |

-- ms_acc_dimension (first few rows):
-- | acc_id | paying_customer |
-- |--------|-----------------|
-- | 700    | no              |
-- | 701    | no              |
-- | ...    | ...             |
-- | 725    | yes             |
-- | 726    | yes             |

-- ms_download_facts (first few rows):
-- | date       | user_id | downloads |
-- |------------|---------|-----------|
-- | 2020-08-24 | 1       | 6         |
-- | 2020-08-22 | 2       | 6         |
-- | ...        | ...     | ...       |

-- Example Output:
-- | download_date | non_paying | paying |
-- |---------------|------------|--------|
-- | 2020-08-16    | 15         | 14     |
-- | 2020-08-17    | 45         | 9      |
-- | 2020-08-18    | 10         | 7      |
-- | 2020-08-21    | 32         | 17     |

SELECT 
    dw.date AS download_date,
    SUM(CASE WHEN acc.paying_customer = 'no' THEN dw.downloads ELSE 0 END) AS non_paying,
    SUM(CASE WHEN acc.paying_customer = 'yes' THEN dw.downloads ELSE 0 END) AS paying
FROM ms_download_facts AS dw
INNER JOIN ms_user_dimension AS us
    ON dw.user_id = us.user_id
INNER JOIN ms_acc_dimension AS acc
    ON acc.acc_id = us.acc_id
GROUP BY dw.date
HAVING SUM(CASE WHEN acc.paying_customer = 'no' THEN dw.downloads ELSE 0 END) >
       SUM(CASE WHEN acc.paying_customer = 'yes' THEN dw.downloads ELSE 0 END)
ORDER BY download_date ASC;