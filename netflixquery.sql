SELECT *
FROM netflix_titles;

-- Checking for duplicate shows 
SELECT show_id, COUNT(*) 
FROM netflix_titles
GROUP BY show_id
HAVING COUNT(*) > 1
ORDER BY show_id DESC;
-- No duplicates found

-- Checking for null values across all columns
SELECT
	(SELECT COUNT(*) FROM netflix_titles WHERE show_id = '') AS show_id_nulls,
    (SELECT COUNT(*) FROM netflix_titles WHERE type = '') AS type_nulls,
    (SELECT COUNT(*) FROM netflix_titles WHERE title = '') AS title_nulls,
    (SELECT COUNT(*) FROM netflix_titles WHERE director = '') AS director_nulls,
    (SELECT COUNT(*) FROM netflix_titles WHERE cast = '') AS cast_nulls,
    (SELECT COUNT(*) FROM netflix_titles WHERE country = '') AS country_nulls,
    (SELECT COUNT(*) FROM netflix_titles WHERE date_added = '') AS date_nulls,
    (SELECT COUNT(*) FROM netflix_titles WHERE release_year = '') AS release_nulls,
    (SELECT COUNT(*) FROM netflix_titles WHERE rating = '') AS rating_nulls,
    (SELECT COUNT(*) FROM netflix_titles WHERE duration = '') AS duration_nulls,
    (SELECT COUNT(*) FROM netflix_titles WHERE listed_in = '') AS listed_nulls,
    (SELECT COUNT(*) FROM netflix_titles WHERE description = '') AS description_nulls;
    
/*
Remove the date, rating and duration rows with nulls as there's very few of them
*/

ALTER TABLE netflix_titles -- Make the show_id column VARCHAR so that we can set it as the primary key column
MODIFY show_id VARCHAR(255);

ALTER TABLE netflix_titles -- Makes the show_id column the primary key column
ADD PRIMARY KEY (show_id);

-- Finding and removing date nulls
SELECT show_id
FROM netflix_titles
WHERE date_added = '';

DELETE
FROM netflix_titles
WHERE show_id
IN ('s6067','s6175','s6796','s6807','s6902','s7197','s7255','s7407','s7848','s8183');
 
-- Finding and removing rating nulls
SELECT show_id
FROM netflix_titles
WHERE rating = '';

DELETE
FROM netflix_titles
WHERE show_id
IN ('s5990','s6828','s7313','s7538');

-- Finding and removing duration nulls
SELECT show_id
FROM netflix_titles
WHERE duration = '';

DELETE 
FROM netflix_titles
WHERE show_id
IN ('s5542','s5795','s5814');

SELECT COUNT(*) -- Check that rows were removed
FROM netflix_titles;

/*
Filling empty strings with 'Not Given'
*/

SET SQL_SAFE_UPDATES = 0; -- temporarily turn safe update mode off

UPDATE netflix_titles -- Update the rows where there are null values
SET
	director = 'Not Given',
    cast = 'Not Given',
    country = 'Not Given'
WHERE
	director = '' OR
	cast = '' OR
	country = '';

SELECT *  -- Check to see the changes applied
FROM netflix_titles;

/*
Query to get distribution of show types by the top 10 countries
*/

SELECT COUNT(*) AS rows_with_commas -- Check how many rows have multiple countries
FROM netflix_titles
WHERE (CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', ''))) >= 1; -- 447 entries

UPDATE netflix_titles -- Take the first country for all entries
SET country = SUBSTRING_INDEX(country, ',', 1);

SELECT country -- Check to see the changes
FROM netflix_titles;

SELECT  -- Get the top 10 countries distribution of content
    country,
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS tv_show_count,
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS movie_count
FROM netflix_titles
WHERE country != 'Not Given'
GROUP BY country
ORDER BY movie_count DESC
LIMIT 10;

/*
Query to get the distribution of content over the years
*/

ALTER TABLE netflix_titles -- Create a year_added column 
ADD year_added VARCHAR(4);  

UPDATE netflix_titles -- Fill in the year added column
SET year_added = CAST(RIGHT(date_added, 4) AS UNSIGNED);

SELECT year_added, COUNT(*) AS count, type -- Count of movies and tv shows added per year
FROM netflix_titles
GROUP BY year_added , type
ORDER BY year_added;

SELECT *
FROM netflix_titles;

SET SQL_SAFE_UPDATES = 1; -- turn safe update mode back on

