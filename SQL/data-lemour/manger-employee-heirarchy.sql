-- Problem Statement:
-- Assume we have a table of Google employees with their corresponding managers.

-- A manager is an employee with a direct report. A senior manager is an employee who manages at least one manager, 
-- but none of their direct reports is senior managers themselves. Write a query to find the senior managers and their direct reports.

-- Output the senior manager's name and the count of their direct reports. 
-- The senior manager with the most direct reports should be the first result.

-- Assumption:
-- - An employee can report to two senior managers.

-- Table Schema:
-- employees Table:
-- | Column Name     | Type    |
-- |-----------------|---------|
-- | emp_id          | integer |
-- | manager_id      | integer |
-- | manager_name    | string  |

-- Example Input:
-- | emp_id | manager_id | manager_name |
-- |--------|------------|--------------|
-- | 1      | 101        | Duyen        |
-- | 101    | 1001       | Rick         |
-- | 103    | 1001       | Rick         |
-- | 1001   | 1008       | John         |

-- Example Output:
-- | manager_name | direct_reportees |
-- |--------------|------------------|
-- | Rick         | 1                |

SELECT 
    managers.manager_name AS manager_name,
    COUNT(DISTINCT managers.emp_id) AS direct_reportees
FROM Employees AS emp
INNER JOIN Employees AS managers 
    ON emp.manager_id = managers.emp_id
INNER JOIN Employees AS SRmanagers 
    ON managers.manager_id = SRmanagers.emp_id
GROUP BY managers.manager_name
ORDER BY direct_reportees DESC, 
         anager_name ASC;