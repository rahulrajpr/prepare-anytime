-- Problem Statement:
-- As a Data Analyst on Snowflake's Marketing Analytics team, your objective is to analyze customer relationship management (CRM) data 
-- and identify contacts that satisfy two conditions:
-- 1. Contacts who had a marketing touch for three or more consecutive weeks.
-- 2. Contacts who had at least one marketing touch of the type 'trial_request'.

-- Marketing touches, also known as touch points, represent the interactions or points of contact between a brand and its customers.

-- Your goal is to generate a list of email addresses for these contacts.

-- Table Schemas:
-- marketing_touches Table:
-- | Column Name   | Type    | Description |
-- |---------------|---------|-------------|
-- | event_id      | integer |             |
-- | contact_id    | integer |             |
-- | event_type    | string  | ('webinar', 'conference_registration', 'trial_request') |
-- | event_date    | date    |             |

-- crm_contacts Table:
-- | Column Name   | Type    |
-- |---------------|---------|
-- | contact_id    | integer |
-- | email         | string  |

-- Example Input:
-- marketing_touches Table:
-- | event_id | contact_id | event_type               | event_date |
-- |----------|------------|--------------------------|------------|
-- | 1        | 1          | webinar                  | 4/17/2022  |
-- | 2        | 1          | trial_request            | 4/23/2022  |
-- | 3        | 1          | whitepaper_download      | 4/30/2022  |
-- | 4        | 2          | handson_lab              | 4/19/2022  |
-- | 5        | 2          | trial_request            | 4/23/2022  |
-- | 6        | 2          | conference_registration  | 4/24/2022  |
-- | 7        | 3          | whitepaper_download      | 4/30/2022  |
-- | 8        | 4          | trial_request            | 4/30/2022  |
-- | 9        | 4          | webinar                  | 5/14/2022  |

-- crm_contacts Table:
-- | contact_id | email                     |
-- |------------|---------------------------|
-- | 1          | andy.markus@att.net       |
-- | 2          | rajan.bhatt@capitalone.com|
-- | 3          | lissa_rogers@jetblue.com  |
-- | 4          | kevinliu@square.com       |

-- Example Output:
-- | email               |
-- |---------------------|
-- | andy.markus@att.net |

WITH weekly_touches AS (
  SELECT DISTINCT
    contact_id,
    DATE_TRUNC('week', event_date) AS week_start
  FROM marketing_touches
),
numbered_weeks AS (
  SELECT 
    contact_id,
    week_start,
    ROW_NUMBER() OVER (PARTITION BY contact_id ORDER BY week_start) as week_seq
  FROM weekly_touches
),
consecutive_groups AS (
  SELECT 
    contact_id,
    week_start,
    week_start - (week_seq * INTERVAL '7 days') AS group_start
  FROM numbered_weeks
),
consecutive_counts AS (
  SELECT 
    contact_id,
    COUNT(*) as consecutive_count
  FROM consecutive_groups
  GROUP BY contact_id, group_start
  HAVING COUNT(*) >= 3
),
has_trial_request AS (
  SELECT DISTINCT contact_id
  FROM marketing_touches
  WHERE event_type = 'trial_request'
)
SELECT DISTINCT c.email
FROM consecutive_counts cc
JOIN has_trial_request htr ON cc.contact_id = htr.contact_id
JOIN crm_contacts c ON cc.contact_id = c.contact_id
ORDER BY c.email;