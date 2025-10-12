-- Problem Statement:
-- Find the top actors based on their average movie rating within the genre they appear in most frequently.

-- Requirements:
-- • For each actor, determine their most frequent genre (i.e., the one they've appeared in the most).
-- • If there is a tie in genre count, select the genre where the actor has the highest average rating.
-- • If there is still a tie in both count and rating, include all tied genres for that actor.
-- • Rank all resulting actor + genre pairs in descending order by their average movie rating.
-- • Return all pairs that fall within the top 3 ranks (not simply the top 3 rows), including ties.
-- • Do not skip rank numbers — for example, if two actors are tied at rank 1, the next rank is 2 (not 3).

-- Table Schema:
-- top_actors_rating Table:
-- | Column Name          | Type              |
-- |----------------------|-------------------|
-- | actor_name           | text              |
-- | genre                | text              |
-- | movie_rating         | double precision  |
-- | movie_title          | text              |
-- | release_date         | date              |
-- | production_company   | text              |

-- Example Input (first few rows):
-- | actor_name        | genre   | movie_rating | movie_title        | release_date | production_company |
-- |-------------------|---------|--------------|--------------------|--------------|-------------------|
-- | Ryan Gosling      | drama   | 9            | Urban Hunt         | 2017-07-03   | Google            |
-- | Ryan Gosling      | sci-fi  | 8.9          | Veil of Secrets    | 2015-12-23   | Apple             |
-- | Chris Evans       | drama   | 6.1          | Crimson Chase      | 2017-08-10   | Apple             |
-- | ... (additional rows) ... |

-- Expected Output:
-- | actor_name        | genre   | avg_rating | actor_rank |
-- |-------------------|---------|------------|------------|
-- | Tom Hardy         | romance | 9.3        | 1          |
-- | Jennifer Lawrence | thriller| 9          | 2          |
-- | Ryan Gosling      | drama   | 9          | 2          |
-- | Scarlett Johansson| thriller| 9          | 2          |
-- | Meryl Streep      | romance | 8.85       | 3          |

with base_dataset as 
(
select 
    actor_name, 
    genre,
    count(actor_name) as actor_genre_count,
    avg(movie_rating) as actor_genre_avg_rating
from top_actors_rating
group by actor_name, genre
),
best_genre as 
(
select *,
    dense_rank() 
        over(partition by actor_name 
                order by actor_genre_count desc, actor_genre_avg_rating desc) as best_genre_identifer
from base_dataset
),
intermediate_result as 
(
select *,
    dense_rank() over(order by actor_genre_avg_rating desc) as best_ratings_rank
from best_genre
where best_genre_identifer = 1
)
select 
  actor_name,
  genre,
  actor_genre_avg_rating as avg_rating,
  best_ratings_rank as actor_rank
from intermediate_result
where best_ratings_rank <= 3
order by best_ratings_rank, actor_name;