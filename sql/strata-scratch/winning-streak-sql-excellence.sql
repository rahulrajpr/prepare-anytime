-- Problem Statement:
-- You are given a table of tennis players and their matches that they could either win (W) or lose (L). 
-- Find the longest streak of wins. A streak is a set of consecutive won matches of one player. 
-- The streak ends once a player loses their next match. Output the ID of the player or players and the length of the streak.

-- Table Schema:
-- players_results Table:
-- | Column Name    | Type    |
-- |----------------|---------|
-- | player_id      | bigint  |
-- | match_date     | date    |
-- | match_result   | text    |

-- Example Input (first few rows):
-- | player_id | match_date | match_result |
-- |-----------|------------|--------------|
-- | 401       | 2021-05-04 | W            |
-- | 401       | 2021-05-09 | L            |
-- | 401       | 2021-05-16 | L            |
-- | 401       | 2021-05-18 | W            |
-- | ... (additional rows) ... |

-- Expected Output:
-- | player_id | streak_length |
-- |-----------|---------------|
-- | 402       | 5             |
-- | 403       | 5             |


WITH match_order AS 
    (
    SELECT *,
        ROW_NUMBER() OVER(
        PARTITION BY player_id ORDER BY match_date AS) AS match_order
    FROM players_results
    ),
win_orders AS 
    (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY match_date ASC) AS win_order,
        match_order - ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY match_date ASC) AS match_order_win_order_gap
    FROM match_order
    WHERE match_result = 'W'
    ),
intermediateResult AS 
    (
    SELECT 
        player_id, 
        match_order_win_order_gap,
        COUNT(player_id) AS streakcount
    FROM win_orders
    GROUP BY player_id, match_order_win_order_gap
    )

SELECT 
  player_id,
  streakcount AS streak_length
FROM intermediateResult
WHERE streakcount = (SELECT MAX(streakcount) FROM intermediateResult)
ORDER BY player_id