```sql
SELECT industry, SUM(total_laid_off)
FROM layoffs3
GROUP BY industry
ORDER BY 2 DESC;
