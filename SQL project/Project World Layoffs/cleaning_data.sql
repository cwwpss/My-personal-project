-- Data Cleaning in world layoffs data
-- 1. Remove duplicate
-- 2. Standardize the data
-- 3. Null Values or blank values
-- 4. Remove any columns

 SELECT *
FROM world_layoffs.layoffs; 

-- Create copy table for cleaning
CREATE TABLE layoffs_prep01
LIKE world_layoffs.layoffs;

SELECT *
FROM layoffs_prep01;

INSERT layoffs_prep01
SELECT *
FROM layoffs; 

-- 1. Remove duplicate
-- Check data set have duplicate or not?
SELECT COUNT(*) FROM layoffs_prep01;

SELECT * FROM layoffs_prep01;

WITH count_duplicate AS (
SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, COUNT(*) AS count_dup
FROM layoffs_prep01
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
SELECT count_dup, COUNT(*) FROM count_duplicate
GROUP BY count_dup; -- duplicate 5 data

WITH duplicate_table AS (
SELECT 
	*,
    ROW_NUMBER() OVER(PARTITION BY 
		company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country, funds_raised_millions) AS detect_dup
FROM layoffs_prep01)
SELECT detect_dup, COUNT(*)
FROM duplicate_table
GROUP BY detect_dup; -- duplicate 5 data

-- Create table for remove duplicate data
CREATE TABLE layoffs_prep02
LIKE layoffs;

ALTER TABLE layoffs_prep02
ADD COLUMN row_num INT; 

SELECT * FROM layoffs_prep02;

INSERT layoffs_prep02
SELECT 
	*,
    ROW_NUMBER() OVER(PARTITION BY 
		company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country, funds_raised_millions) AS detect_dup
FROM layoffs_prep01; 

-- Pre-view data
SELECT * FROM layoffs_prep02;

-- Remove duplicate data
DELETE FROM layoffs_prep02
WHERE row_num > 1;

-- Re-check duplicate data
WITH check_data AS (
SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, COUNT(*) AS count_dup
FROM layoffs_prep02
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
SELECT * FROM check_data
WHERE count_dup <> 1;


-- 2. Standardize the data
SELECT * FROM layoffs_prep02;
-- Pre-view company column
SELECT DISTINCT company FROM layoffs_prep02;

SELECT company, LENGTH(company) 
FROM layoffs_prep02; -- company columns some data have white space

UPDATE layoffs_prep02
SET company = TRIM(company);

SELECT company, LENGTH(company) FROM layoffs_prep02;
-- Pre-view location and induscolumn
SELECT DISTINCT location FROM layoffs_prep02;

SELECT location, LENGTH(location) 
FROM layoffs_prep02;

SELECT location
FROM layoffs_prep02
WHERE location = '' OR location IS NULL;

-- Pre-view industry column
SELECT DISTINCT industry FROM layoffs_prep02; -- found the incorrect data name and missing values

SELECT DISTINCT industry, LENGTH(industry) 
FROM layoffs_prep02; -- Found incorrect input data

SELECT DISTINCT industry
FROM layoffs_prep02
WHERE LOWER(industry) LIKE 'Cryp%';

UPDATE layoffs_prep02
SET industry = 'Crypto Currency'
WHERE LOWER(industry) LIKE 'Cryp%';

-- Pre-view date column
-- change data type and date formate
SELECT * FROM layoffs_prep02
WHERE `date` IS NULL OR `date` = '';

UPDATE layoffs_prep02
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

UPDATE layoffs_prep02
SET `date` = DATE_FORMAT(`date`, '%Y-%m-%d');

SELECT * FROM layoffs_prep02;

-- Pre-view country column
SELECT DISTINCT country
FROM layoffs_prep02; -- Found incorrect data 

SELECT DISTINCT(COUNTRY)
FROM layoffs_prep02
WHERE LOWER(country) LIKE 'united s%';

UPDATE layoffs_prep02
SET country = 'United States'
WHERE LOWER(country) LIKE 'united s%';

SELECT DISTINCT country, LENGTH(country)
FROM layoffs_prep02;


-- 3. Null Values or blank values
SELECT * FROM layoffs_prep02;
-- company coloumn
SELECT DISTINCT company
FROM layoffs_prep02
WHERE company is NULL OR company = ''; -- No blank and Null values
-- location coloumn
SELECT * 
FROM layoffs_prep02
WHERE location is NULL OR location = ''; -- No blank and Null values
-- industry column
SELECT * 
FROM layoffs_prep02
WHERE industry is NULL OR industry = '';

SELECT * 
FROM layoffs_prep02
WHERE LOWER(company) IN (SELECT LOWER(company) 
FROM layoffs_prep02
WHERE industry is NULL OR industry = '');

UPDATE layoffs_prep02
SET industry = NULL
WHERE industry is NULL OR industry = '';

SELECT * FROM layoffs_prep02
WHERE LOWER(company) = 'airbnb';

UPDATE layoffs_prep02
SET industry = COALESCE('Travel', industry)
WHERE LOWER(company) = 'airbnb';

SELECT * FROM layoffs_prep02
WHERE LOWER(company) = 'carvana';

UPDATE layoffs_prep02
SET industry = COALESCE('Transportation', industry)
WHERE LOWER(company) = 'carvana';

SELECT * FROM layoffs_prep02
WHERE LOWER(company) = 'juul';

UPDATE layoffs_prep02
SET industry = COALESCE('Consumer', industry)
WHERE LOWER(company) = 'juul';
 
-- total_laid_off coloumn
SELECT *
FROM layoffs_prep02
WHERE total_laid_off is NULL OR total_laid_off = '';

-- percentage_laid_off column
SELECT *
FROM layoffs_prep02
WHERE percentage_laid_off is NULL OR percentage_laid_off = '';

-- date column
SELECT *
FROM layoffs_prep02
WHERE `date` is NULL OR `date` = ''; -- DROP

DELETE FROM layoffs_prep02
WHERE `date` is NULL OR `date` = '';

-- stage column
SELECT *
FROM layoffs_prep02
WHERE stage is NULL OR stage = '';

SELECT *
FROM layoffs_prep02
WHERE company = 'Relevel';

-- country column
SELECT *
FROM layoffs_prep02
WHERE country is NULL OR country = '';

-- fundsraised column
SELECT *
FROM layoffs_prep02
WHERE funds_raised_millions is NULL OR funds_raised_millions = '';


-- 4. Remove any columns
ALTER TABLE layoffs_prep02
DROP COLUMN row_num;

SELECT * FROM layoffs_prep02;
