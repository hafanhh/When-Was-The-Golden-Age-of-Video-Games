DROP TABLE game_sales;

CREATE TABLE game_sales (
  game VARCHAR(100) PRIMARY KEY,
  platform VARCHAR(64),
  publisher VARCHAR(64),
  developer VARCHAR(64),
  games_sold NUMERIC(5, 2),
  year INT
);

DROP TABLE reviews;

CREATE TABLE reviews (
    game VARCHAR(100) PRIMARY KEY,
    critic_score NUMERIC(4, 2),   
    user_score NUMERIC(4, 2)
);

DROP TABLE top_critic_years;

CREATE TABLE top_critic_years (
    year INT PRIMARY KEY,
    avg_critic_score NUMERIC(4, 2)  
);

DROP TABLE top_critic_years_more_than_four_games;

CREATE TABLE top_critic_years_more_than_four_games (
    year INT PRIMARY KEY,
    num_games INT,
    avg_critic_score NUMERIC(4, 2)  
);

DROP TABLE top_user_years_more_than_four_games;

CREATE TABLE top_user_years_more_than_four_games (
    year INT PRIMARY KEY,
    num_games INT,
    avg_user_score NUMERIC(4, 2)  
);

\copy game_sales FROM 'game_sales.csv' DELIMITER ',' CSV HEADER;
\copy reviews FROM 'game_reviews.csv' DELIMITER ',' CSV HEADER;
\copy top_critic_years FROM 'top_critic_scores.csv' DELIMITER ',' CSV HEADER;
\copy top_critic_years_more_than_four_games FROM 'top_critic_scores_more_than_four_games.csv' DELIMITER ',' CSV HEADER;
\copy top_user_years_more_than_four_games FROM 'top_user_scores_more_than_four_games.csv' DELIMITER ',' CSV HEADER;

-- Select all information for the top ten best-selling games
-- Order the results from best-selling game down to tenth best-selling
SELECT *
FROM game_sales
ORDER BY games_sold DESC
LIMIT 10;

-- Join games_sales and reviews
-- Select a count of the number of games where both critic_score and user_score are null
SELECT COUNT(DISTINCT game)
FROM game_sales 
LEFT JOIN reviews
USING (game)
WHERE critic_score IS NULL 
	AND user_score IS NULL

-- Select release year and average critic score for each year, rounded and aliased
-- Join the game_sales and reviews tables
-- Group by release year
-- Order the data from highest to lowest avg_critic_score and limit to 10 results
SELECT year, 
	ROUND(AVG(critic_score), 2) AS avg_critic_score
FROM game_sales
LEFT JOIN reviews 
USING (game)
GROUP BY year
ORDER BY avg_critic_score DESC
LIMIT 10;

-- Paste your query from the previous task; update it to add a count of games released in each year called num_games
-- Update the query so that it only returns years that have more than four reviewed games
SELECT year, 
	ROUND(AVG(critic_score), 2) AS avg_critic_score,
	COUNT(DISTINCT game_sales.game) AS num_games
FROM game_sales
inner JOIN reviews 
USING (game)
GROUP BY year
HAVING COUNT(DISTINCT game_sales.game) > 4
ORDER BY avg_critic_score DESC
LIMIT 10;

-- Select the year and avg_critic_score for those years that dropped off the list of critic favorites 
-- Order the results from highest to lowest avg_critic_score
SELECT top_critic_years.year, top_critic_years.avg_critic_score
FROM top_critic_years
LEFT JOIN top_critic_years_more_than_four_games
USING (year)
WHERE top_critic_years_more_than_four_games.YEAR IS NULL
ORDER BY avg_critic_score DESC

SELECT g.year, 
    COUNT(g.game) AS num_games, 
    ROUND(AVG(r.user_score),2) AS avg_user_score
FROM game_sales AS g
INNER JOIN reviews AS r
ON g.game = r.game
GROUP BY g.year
HAVING COUNT(g.game) > 4
ORDER BY avg_user_score DESC
LIMIT 10;

-- Select the year results that appear on both tables
SELECT year
FROM top_critic_years_more_than_four_games 
INTERSECT 
SELECT year
FROM top_user_years_more_than_four_games 

-- Select year and sum of games_sold, aliased as total_games_sold; order results by total_games_sold descending
-- Filter game_sales based on whether each year is in the list returned in the previous task

SELECT year,
	SUM(games_sold) as total_games_sold
FROM game_sales
WHERE year IN 
    (SELECT year
    FROM top_critic_years_more_than_four_games 
    INTERSECT 
    SELECT year
    FROM top_user_years_more_than_four_games)
GROUP BY year
ORDER BY total_games_sold DESC;


