USE world_layoffs;
SELECT * FROM layoffs;
-- Creating a Playground Table to avoid errors in the original table
CREATE TABLE layoffs2 LIKE layoffs;
INSERT layoffs2
SELECT * FROM  layoffs; -- At this point we created layoffs2 which is a playground Table of layoffs

-- 1.Remove Duplicates -------------------------------------------------------------------------------
-- Create Unique identifier (Since there is no ID col):

-- Right click layoffs2 >> Copy to clipboard >> Create statement:
CREATE TABLE `layoffs3` ( -- Note the name change
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `Row_num` INT -- Note this addition - indcator of duplicate - if greater than 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- Now insert the data:
INSERT INTO layoffs3
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
AS Row_num
FROM layoffs2;

-- Check if there are duplicates:
SELECT * FROM layoffs3
WHERE Row_num > 1;

-- Delete duplicates:
DELETE FROM layoffs3
WHERE Row_num > 1;

-- At this point we can delete the extra column we created:
ALTER TABLE layoffs3
DROP COLUMN Row_num;

-- 2.Standardizing -------------------------------------------------------------------------------
UPDATE layoffs3	SET company = TRIM(company); -- Removes any space before or after the word

-- Unite several inustries (for example - crypto / cryptoCurrency / cryptograph Are all the same!)
UPDATE layoffs3
SET industry = 'Crypto'
WHERE LOWER(TRIM(industry)) LIKE '%crypto%'; -- trim handles any space before or after the name

SELECT DISTINCT industry FROM layoffs3 ORDER BY 1; -- Checking if works
-- Same
UPDATE layoffs3
SET country = 'United States'
WHERE LOWER(TRIM(country)) LIKE '%States%';

SELECT DISTINCT country FROM layoffs3 ORDER BY 1; -- Checking if works
-- Date formatting
UPDATE layoffs3
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs3
MODIFY COLUMN `date` DATE; -- At this point if we look at layoffs3 >> Columns : date is in "date" format

-- 3.Handeling blanks and NULLS ---------------------------------------------------------------------
-- Before deleting the rows : add missing values if possible:
-- For example: if industry is blank and the company is AirB&B - it is obv a Travel industry
UPDATE layoffs3
SET industry = NULL
WHERE industry = ''; -- Step1: Convert blank to NULL

UPDATE layoffs3 t1
JOIN layoffs3 t2
 ON t1.company = t2.company
 SET t1.industry = t2.industry
 WHERE t1.industry IS NULL
 AND t2.industry IS NOT NULL; -- Step2: Set the industry where we can
 
DELETE
FROM layoffs3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; -- Step3: Delete NULLS

SELECT * FROM layoffs3;

