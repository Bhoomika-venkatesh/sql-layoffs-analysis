-- EDA

SELECT * 
FROM world_layoffs.layoffs_staging2;



SELECT MAX(total_laid_off)
FROM world_layoffs.layoffs_staging2;



-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1;
-- these are mostly startups it looks like who all went out of business during this time

-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;





--------------------------------------------------------------------------------------------------

-- Companies with the biggest single Layoff

SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY 2 DESC
LIMIT 5;
-- now that's just on a single day

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;



-- by location
SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- this it total in the past 3 years or in the dataset

SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 ASC;


SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;






---------------------------------------------------------------------------------------------------------------------------------

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;




-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;

-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
-------------------------------------------------------------------------------------------------------------------
-- 1. Industry Recovery Analysis
-- Comparing layoffs in early period (2022) vs later period (2023) to identify recovery trends
SELECT industry,
    SUM(CASE WHEN YEAR(date) = 2022 THEN total_laid_off ELSE 0 END) AS layoffs_2022,
    SUM(CASE WHEN YEAR(date) = 2023 THEN total_laid_off ELSE 0 END) AS layoffs_2023,
    SUM(CASE WHEN YEAR(date) = 2022 THEN total_laid_off ELSE 0 END) - 
    SUM(CASE WHEN YEAR(date) = 2023 THEN total_laid_off ELSE 0 END) AS recovery_diff
FROM layoffs_staging2
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY recovery_diff DESC;

-- 2. Layoff Rate by Funding Stage
-- Are early-stage companies laying off more than late-stage?
SELECT stage,
    COUNT(company) AS num_companies,
    SUM(total_laid_off) AS total_laid_off,
    ROUND(AVG(percentage_laid_off * 100), 2) AS avg_percentage_laid_off
FROM layoffs_staging2
WHERE stage IS NOT NULL
AND percentage_laid_off IS NOT NULL
GROUP BY stage
ORDER BY avg_percentage_laid_off DESC;

-- 3. Top 5 Countries by Average Percentage Laid Off
-- Which countries had the highest workforce reduction on average?
SELECT country,
    COUNT(company) AS num_companies,
    ROUND(AVG(percentage_laid_off * 100), 2) AS avg_percentage_laid_off,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
AND country IS NOT NULL
GROUP BY country
ORDER BY avg_percentage_laid_off DESC
LIMIT 5;

-- 4. Companies with Multiple Rounds of Layoffs
-- Identifying companies that conducted repeated layoffs
SELECT company,
    COUNT(*) AS layoff_rounds,
    SUM(total_laid_off) AS total_laid_off,
    MIN(date) AS first_layoff,
    MAX(date) AS last_layoff
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company
HAVING COUNT(*) > 1
ORDER BY layoff_rounds DESC, total_laid_off DESC
LIMIT 10;

-- 5. Month-over-Month Percentage Change in Layoffs
-- Tracking how layoffs accelerated or slowed each month
WITH monthly_layoffs AS (
    SELECT 
        SUBSTRING(date, 1, 7) AS month,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    WHERE date IS NOT NULL
    GROUP BY SUBSTRING(date, 1, 7)
    ORDER BY month ASC
),
mom_change AS (
    SELECT 
        month,
        total_laid_off,
        LAG(total_laid_off) OVER (ORDER BY month) AS prev_month_layoffs
    FROM monthly_layoffs
)
SELECT 
    month,
    total_laid_off,
    prev_month_layoffs,
    ROUND(((total_laid_off - prev_month_layoffs) / prev_month_layoffs) * 100, 2) 
        AS mom_percentage_change
FROM mom_change
WHERE prev_month_layoffs IS NOT NULL
ORDER BY month ASC;
















































