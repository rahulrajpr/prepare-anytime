-- Problem Statement:
-- You are given a dataset of actors and the films they have been involved in, including each film's release date and rating. 
-- For each actor, calculate the difference between the rating of their most recent film and their average rating across all previous films 
-- (the average rating excludes the most recent one).

-- Return a list of actors along with their average lifetime rating, the rating of their most recent film, 
-- and the difference between the two ratings. Round the difference calculation to 2 decimal places. 
-- If an actor has only one film, return 0 for the difference and their only film's rating for both the average and latest rating fields.

-- Table Schema:
-- actor_rating_shift Table:
-- | Column Name    | Type              |
-- |----------------|-------------------|
-- | actor_name     | text              |
-- | film_title     | text              |
-- | release_date   | date              |
-- | film_rating    | double precision  |

-- Example Input (first few rows):
-- | actor_name        | film_title     | release_date | film_rating |
-- |-------------------|----------------|--------------|-------------|
-- | Matt Damon        | Equal Depths   | 2018-09-21   | 8           |
-- | Matt Damon        | Equal Heights  | 2015-06-15   | 8           |
-- | Emma Stone        | Quantum Fate   | 2003-08-31   | 8.1         |
-- | Leonardo Dicaprio | Rebel Rising   | 2001-06-26   | 9.2         |
-- | ... (additional rows) ... |

-- Expected Output:
-- | actor_name     | avg_rating | latest_rating | rating_difference |
-- |----------------|------------|---------------|-------------------|
-- | Alex Taylor    | 7.52       | 8.5           | 0.98              |
-- | Angelina Jolie | 6          | 6             | 0                 |
-- | Brad Pitt      | 6          | 6             | 0                 |
-- | Chris Evans    | 5.75       | 7.7           | 1.95              |
-- | Emma Stone     | 7.62       | 6.2           | -1.42             |

WITH latestFilm AS 
(
  SELECT *,
    ROW_NUMBER() OVER(
      PARTITION BY actor_name 
      ORDER BY release_date DESC
    ) AS latestFilm
  FROM actor_rating_shift
),
avgRating AS 
(
  SELECT 
    actor_name, 
    AVG(film_rating) AS avg_rating
  FROM latestFilm
  WHERE latestFilm > 1
  GROUP BY actor_name
)
SELECT 
  lf.actor_name, 
  COALESCE(avRat.avg_rating, lf.film_rating) AS avg_rating,
  lf.film_rating AS latest_rating,
  ROUND(
    COALESCE(lf.film_rating - avRat.avg_rating, 0.0)::NUMERIC, 
    2
  ) AS rating_difference
FROM latestFilm AS lf
LEFT JOIN avgRating AS avRat
  ON lf.actor_name = avRat.actor_name
WHERE latestFilm = 1
ORDER BY lf.actor_name;