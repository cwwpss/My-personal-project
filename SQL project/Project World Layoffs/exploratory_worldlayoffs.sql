-- Exploratory Data Analysis
SELECT * FROM layoffs_prep02;

-- Find the hightest total layoffs
SELECT MAX(total_laid_off)
FROM layoffs_prep02;

-- Find the hightest layoffs from the company that have 100 percen layoff
SELECT *
FROM layoffs_prep02
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC
;

-- Find the total layoff from the company that have highest fund raise
SELECT *
FROM layoffs_prep02
WHERE percentage_laid_off = 1 AND total_laid_off IS NOT NULL
ORDER BY funds_raised_millions DESC
;

-- Find the top 10 overtime layoffs in each company
SELECT company, SUM(total_laid_off)
FROM layoffs_prep02
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
;

-- Find the top 10 overtime layoffs in each industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_prep02
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
;

-- Find the overtime layoffs in each country
SELECT country, SUM(total_laid_off)
FROM layoffs_prep02
GROUP BY 1
ORDER BY 2 DESC
;

-- Find the top 10 overtime layoffs in each stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_prep02
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
;

SELECT stage, ROUND(AVG(percentage_laid_off),2)
FROM layoffs_prep02
GROUP BY 1
ORDER BY 2 DESC
;

-- Find the total layoff in each year
SELECT YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_prep02
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`);

-- Industries with the Most Employee Layoffs in Each Country
WITH cte_total_laid_off AS
(SELECT country, industry, SUM(total_laid_off) AS total_laid_off
	FROM layoffs_prep02
	GROUP BY country, industry
	ORDER BY SUM(total_laid_off) DESC)
 , cte_country AS
( SELECT *, DENSE_RANK() OVER(PARTITION BY country ORDER BY total_laid_off DESC) AS rank_laid_off
FROM cte_total_laid_off
WHERE total_laid_off IS NOT NULL)
SELECT * FROM cte_country
WHERE rank_laid_off = 1
ORDER BY total_laid_off DESC
;

WITH cte_stage AS
( SELECT stage, industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_prep02
GROUP BY stage, industry)
SELECT *, DENSE_RANK() OVER(PARTITION BY stage ORDER BY total_laid_off DESC) AS rank_laid_off
FROM cte_stage
WHERE stage IS NOT NULL; 

-- Find the overtime layoff percentage 
WITH cte_my (month_year, total_laid_off) AS
(
SELECT DATE_FORMAT(`date`, '%Y-%m'), SUM(total_laid_off)
FROM layoffs_prep02
GROUP BY 1
ORDER BY 1 )
, cte_sum (month_year, total_laid_off, sum_laid_off) AS
(
SELECT *, SUM(total_laid_off) OVER(ORDER BY month_year)
FROM cte_my )
SELECT *, total_laid_off/sum_laid_off AS LaidoffsPercentageEachMonth
FROM cte_sum
;

WITH cte_my (`date`, country, total_laid_off) AS
(
SELECT `date`, country, SUM(total_laid_off) 
FROM layoffs_prep02
GROUP BY 1, 2
ORDER BY 1 )
, cte_sum AS
(
SELECT *, SUM(total_laid_off) OVER(ORDER BY `date`) AS sum_laid_off
FROM cte_my )
SELECT *, total_laid_off/sum_laid_off AS LaidoffsPercentageEachMonth
FROM cte_sum
WHERE total_laid_off IS NOT NULL
;

WITH cte_my (`date`, total_laid_off) AS
(
SELECT `date`, SUM(total_laid_off) 
FROM layoffs_prep02
GROUP BY 1
ORDER BY 1 )
, cte_sum AS
(
SELECT *, SUM(total_laid_off) OVER(ORDER BY `date`) AS sum_laid_off
FROM cte_my )
SELECT *, total_laid_off/sum_laid_off AS LaidoffsPercentageEachMonth
FROM cte_sum
WHERE total_laid_off IS NOT NULL
;

-- Find top 3 company that highest layyoff employee in each year
WITH cte_company(company, `year`, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_prep02
GROUP BY company, YEAR(`date`) )
, cte_rank AS (
SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) AS laidoffs_ranking
FROM cte_company)
SELECT * 
FROM cte_rank
WHERE laidoffs_ranking <= 3
ORDER BY `year`
;

-- Total laidoffs each country
SELECT country, SUM(total_laid_off)
FROM layoffs_prep02
GROUP BY 1
ORDER BY 2 DESC;
