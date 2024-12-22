-- Data Cleaning Project --

-- 1. Remove Duplicates --
-- 2. Standardize the Data --
-- 3. Handle Null or Blank Values --
-- 4. Remove Irrelevant Columns --

-- Created a copy of raw data. --
CREATE TABLE layoffs_1
LIKE layoffs;

INSERT INTO layoffs_1
SELECT * FROM layoffs;

-- Give row numbers to find duplicate rows --
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
AS row_num
FROM layoffs_1;

WITH duplicate_cte AS 
(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
AS row_num
FROM layoffs_1
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;
-- Can't delete from a CTE so another table will be created --

CREATE TABLE `layoffs_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
AS row_num
FROM layoffs_1;

DELETE FROM layoffs_2
WHERE row_num > 1;

SELECT * FROM layoffs_2
WHERE row_num > 1;

-- Standardization --
SELECT company, TRIM(company)
FROM layoffs_2;

UPDATE layoffs_2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_2
ORDER BY 1;

SELECT * FROM layoffs_2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location 
FROM layoffs_2
ORDER BY 1;

UPDATE layoffs_2
SET location = 'Dusseldorf'
WHERE location = 'DÃ¼sseldorf';

UPDATE layoffs_2
SET location = 'Florianapolis'
WHERE location = 'FlorianÃ³polis';

UPDATE layoffs_2 
SET location = 'Malmo'
WHERE location = 'MalmÃ¶';

SELECT DISTINCT country
FROM layoffs_2 
ORDER BY 1;

UPDATE layoffs_2
SET country = 'United States'
WHERE country = 'United States.';

UPDATE layoffs_2
SET location = TRIM(location);

UPDATE layoffs_2
SET industry = TRIM(industry);

-- Convert date column from text to date --
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') -- Standard date format is year/month/day --
FROM layoffs_2; 

UPDATE layoffs_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date` FROM layoffs_2;

ALTER TABLE layoffs_2
MODIFY COLUMN `date` DATE;

-- Dealing with null and blank values --
SELECT * FROM layoffs_2
WHERE total_laid_off IS NULL OR total_laid_off = '' AND percentage_laid_off IS NULL OR percentage_laid_off = '';

DELETE FROM layoffs_2
WHERE total_laid_off IS NULL OR total_laid_off = '' AND percentage_laid_off IS NULL OR percentage_laid_off = '';

SELECT * FROM layoffs_2
WHERE industry IS NULL OR industry = '';

SELECT * FROM layoffs_2 
WHERE company = 'Airbnb' OR company = 'Carvana' OR company = 'Juul';

UPDATE layoffs_2
SET industry = 'Travel'
WHERE company = 'Airbnb';

UPDATE layoffs_2
SET industry = 'Transportation'
WHERE company = 'Carvana';

UPDATE layoffs_2
SET industry = 'Consumer'
WHERE company = 'Juul';

/* Note to self: This also can be used instead of last three UPDATE queries
UPDATE layoffs_2
SET industry = NULL
WHERE industry = ''

UPDATE layoffs_2 AS t1
JOIN layoffs_2 AS t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL OR t1.industry = ''
AND t2.industry IS NOT NULL OR t2.industry != '';
*/

ALTER TABLE layoffs_2
DROP COLUMN row_num;

SELECT * FROM layoffs_2;