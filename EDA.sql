USE world_layoffs;
SELECT * FROM layoffs3; -- This Table was cleaned in Data_Cleaning 

SELECT MIN(`date`), MAX(`date`)
FROM layoffs3;-- Date range (Post COVID period)

SELECT industry, SUM(total_laid_off) -- Total layoffs by industry
FROM layoffs3
GROUP BY industry
ORDER BY 2 DESC; -- Order by the second column in the SELECT list: SUM()

SELECT YEAR(`date`), MONTH(`date`), SUM(total_laid_off) -- Total layoffs by month
FROM layoffs3
GROUP BY YEAR(`date`), MONTH(`date`)
ORDER BY 3 DESC;

-- Cumulative layoffs (Rolling total)
WITH DATE_CTE AS -- Set a CTE (Temporary table)
(
SELECT SUBSTRING(date,1,7) as `Month`, SUM(total_laid_off) AS total_laid_off
FROM layoffs3
GROUP BY `Month`
ORDER BY `Month` ASC
)
SELECT `Month`, SUM(total_laid_off) OVER (ORDER BY `Month` ASC) as Rolling_total_layoffs
FROM DATE_CTE
WHERE `Month` IS NOT NULL
ORDER BY `Month` ASC;

-- Year by year Top-3 Layoffs:
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS Years, SUM(total_laid_off) AS Total_laid_off
  FROM layoffs3
  GROUP BY company, Years
)
, Company_Year_Rank AS (
  SELECT company, Years, Total_laid_off, DENSE_RANK() OVER (PARTITION BY Years ORDER BY Total_laid_off DESC) AS Ranking
  FROM Company_Year
)
SELECT company, Years, Total_laid_off, Ranking
FROM Company_Year_Rank
WHERE Ranking <= 3
AND Years IS NOT NULL
ORDER BY Years ASC, Total_laid_off DESC;

