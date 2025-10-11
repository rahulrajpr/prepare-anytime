-- Problem Statement:
-- Write a query to identify the top 2 Power Users who sent the highest number of messages on Microsoft Teams in August 2022. 
-- Display the IDs of these 2 users along with the total number of messages they sent. 
-- Output the results in descending order based on the count of the messages.

-- Assumption:
-- No two users have sent the same number of messages in August 2022.

-- Table Schema:
-- messages Table:
-- | Column Name   | Type      |
-- |---------------|-----------|
-- | message_id    | integer   |
-- | sender_id     | integer   |
-- | receiver_id   | integer   |
-- | content       | varchar   |
-- | sent_date     | datetime  |

-- Example Input:
-- | message_id | sender_id | receiver_id | content           | sent_date           |
-- |------------|-----------|-------------|-------------------|---------------------|
-- | 901        | 3601      | 4500        | You up?           | 08/03/2022 00:00:00 |
-- | 902        | 4500      | 3601        | Only if you're buying | 08/03/2022 00:00:00 |
-- | 743        | 3601      | 8752        | Let's take this offline | 06/14/2022 00:00:00 |
-- | 922        | 3601      | 4500        | Get on the call   | 08/10/2022 00:00:00 |
-- | 901        | 3601      | 4500        | You up?           | 08/03/2022 00:00:00 |
-- | 903        | 4500      | 3601        | I'm in!           | 08/03/2022 00:00:00 |

-- Example Output:
-- | sender_id | message_count |
-- |-----------|---------------|
-- | 3601      | 4             |
-- | 4500      | 3             |

SELECT 
  sender_id, 
  COUNT(message_id) AS message_count
FROM messages
WHERE DATE_TRUNC('month', sent_date) = '2022-08-01'::DATE
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2;