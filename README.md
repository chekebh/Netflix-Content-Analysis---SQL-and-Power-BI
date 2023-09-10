# Netflix Content Analysis - SQL & Power BI
![](https://github.com/chekebh/Netflix-Content-Analysis---SQL-and-Power-BI/blob/main/intro_image.jpg)
# Introduction
The aim of this project is to analyse Netflix's content library using a CSV dataset and provide the client with a better understanding of the media on their platform. This project places more emphasis on data cleaning as the dataset has a lot of missing values and the cleaned data will be used to provide visual representations that enhance the client's understanding of their platform's content. This is an overview of the project and relevant files are attached for your viewing.
# Tools used 
* MySQL Workbench
* Power BI
# Problem
1) What's the distribution of movies and tv shows?
2) Which rating is the most frequently assigned to our content?
3) How are movies and TV shows distributed among the top 10 countries?
4) In which year did we release the highest volume of content?
# Data Analysis
## Data Exploration
In this section, we aim to get an understanding of the dataset by checking the data for any incorrect datatypes, null values and duplicates.

We first check for duplicate values.
```sql
SELECT show_id, COUNT(*) 
FROM netflix_titles
GROUP BY show_id
HAVING COUNT(*) > 1
ORDER BY show_id DESC;
```
This returned 0 hence no duplicates.

Then we check for null values across all columns.
```sql
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
```

| show\_id\_nulls | type_nulls | title_nulls | director_nulls | cast_nulls | country_nulls | date_nulls | release_nulls | rating_nulls | duration_nulls | listed_nulls | description_nulls |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0   | 0   | 0   | 2631 | 825 | 830 | 10  | 0   | 4   | 3   | 0   | 0   |

## Data Cleaning

Since the cells contained empty strings, we check for empty strings as our null values. Given that **date_added**, **rating** and **duration** have minimal null values, we'll remove these rows from the dataset.

We first try and find where these null values are.
```sql
SELECT show_id
FROM netflix_titles
WHERE date_added = '';

SELECT show_id
FROM netflix_titles
WHERE rating = '';

SELECT show_id
FROM netflix_titles
WHERE duration = '';
```
Then we will remove them from the dataset.

```sql
DELETE
FROM netflix_titles
WHERE show_id
IN ('s6067','s6175','s6796','s6807','s6902','s7197','s7255','s7407','s7848','s8183');

DELETE
FROM netflix_titles
WHERE show_id
IN ('s5990','s6828','s7313','s7538');

DELETE 
FROM netflix_titles
WHERE show_id
IN ('s5542','s5795','s5814');
```
Given the substantial amount of missing data, our approach will be to replace these missing values with 'Not Given' rather than deleting them.

```sql
UPDATE netflix_titles -- Update the rows where there are null values
SET
    director = 'Not Given',
    cast = 'Not Given',
    country = 'Not Given'
WHERE
    director = '' OR
    cast = '' OR
    country = '';
```

I noticed that the country column had entries with multiple rows so I wanted to check how many rows this affected.

```sql
SELECT COUNT(*) AS rows_with_commas -- Check how many rows have multiple countries
FROM netflix_titles
WHERE (CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', ''))) >= 1; -- 447 entries
```
This returned 447 entries hence the approach I took was to simply select the first country of each cell rather than remove these rows.

```sql
UPDATE netflix_titles -- Take the first country for all entries
SET country = SUBSTRING_INDEX(country, ',', 1);
```
## Additional queries

The first two questions can be answered using Power BI hence we'll write two queries to answer the last two questions.

Query to get the content distribution across the top 10 countries.

```sql
SELECT  -- Get the top 10 countries distribution of content
    country,
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS tv_show_count,
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS movie_count
FROM netflix_titles
WHERE country != 'Not Given'
GROUP BY country
ORDER BY movie_count DESC
LIMIT 10;
```

Queries to get the distribution of content over the years.

```sql
ALTER TABLE netflix_titles -- Create a year_added column 
ADD year_added VARCHAR(4);  

UPDATE netflix_titles -- Fill in the year added column
SET year_added = CAST(RIGHT(date_added, 4) AS UNSIGNED);

SELECT year_added, COUNT(*) AS count, type -- Count of movies and tv shows added per year
FROM netflix_titles
GROUP BY year_added , type
ORDER BY year_added;
```
The tables returned from these queries were saved onto Power BI to create the required visuals.

# Data Visualisation

After cleaning the data, the MySQL database was integrated with Power BI to create the following dashboard.

![](https://github.com/chekebh/Netflix-Content-Analysis---SQL-and-Power-BI/blob/main/dashboard.jpg)

# Conclusion

The essence of this project was to analyse Netflix's content, making use of a dataset riddled with missing values. My initial step was dedicated to data cleaning, aiming to rectify these gaps in the dataset. Through this experience, I acquired valuable skills in filling missing data and began to appreciate the pivotal role of data cleaning in the data analysis process.
