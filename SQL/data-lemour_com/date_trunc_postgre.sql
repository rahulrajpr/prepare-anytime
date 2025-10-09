
-- Write a query to identify the top 2 Power Users who sent the highest number of messages on Microsoft Teams in August 2022. Display the IDs of these 2 users along with the total number of messages they sent. Output the results in descending order based on the count of the messages.

-- Assumption:

--     No two users have sent the same number of messages in August 2022.

-- messages Table:
-- Column Name	Type
-- message_id	integer
-- sender_id	integer
-- receiver_id	integer
-- content	varchar
-- sent_date	datetime


SELECT sender_id, COUNT(message_id) AS message_count
FROM messages
WHERE DATE_TRUNC('month',sent_date) = '2022-08-01' :: DATE
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2