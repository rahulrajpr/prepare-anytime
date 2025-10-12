
-- Problem Statement:
-- The election is conducted in a city and everyone can vote for one or more candidates, or choose not to vote at all. 
-- Each person has 1 vote so if they vote for multiple candidates, their vote gets equally split across these candidates. 
-- For example, if a person votes for 2 candidates, these candidates receive an equivalent of 0.5 vote each. 
-- Some voters have chosen not to vote, which explains the blank entries in the dataset.

-- Find out who got the most votes and won the election. Output the name of the candidate or multiple names in case of a tie.

-- To avoid issues with a floating-point error you can round the number of votes received by a candidate to 3 decimal places.

-- Table Schema:
-- voting_results Table:
-- | Column Name | Type    |
-- |-------------|---------|
-- | voter       | text    |
-- | candidate   | text    |

-- Example Input (first few rows):
-- | voter     | candidate  |
-- |-----------|------------|
-- | Kathy     |            |
-- | Charles   | Ryan       |
-- | Charles   | Christine  |
-- | Charles   | Kathy      |
-- | Benjamin  | Christine  |
-- | ... (additional rows) ... |

-- Expected Output:
-- | candidate  |
-- |------------|
-- | Christine  |

WITH CTE AS 
(
  SELECT *,
    ROUND(
      (1)::NUMERIC /
      (COUNT(candidate) OVER(PARTITION BY voter))
      ,3
      ) AS vote_contribution
  FROM voting_results
  WHERE candidate IS NOT NULL
),
IntermediateResult AS 
(
  SELECT 
    candidate,
    SUM(vote_contribution) AS votes
  FROM CTE
  GROUP BY candidate
)
SELECT candidate
FROM IntermediateResult
WHERE votes = (SELECT MAX(votes) FROM IntermediateResult)
ORDER BY candidate