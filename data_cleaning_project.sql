-- Data Cleaning

SELECT * 
FROM layoffs;

# Remove Duplicates
# Standardize values
# handle NULL values
# removes unnecessary rows,columns

-- create a duplicate table so that raw data is not modified

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * 
FROM layoffs;

SELECT * 
FROM layoffs_staging;


-- Removing duplicates


-- assigns  row number 1 to unique records
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,
funds_raised_millions) AS row_num
FROM layoffs_staging;

-- making CTE

WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,
funds_raised_millions) AS row_num
FROM layoffs_staging
) 
SELECT *
FROM duplicate_cte 
WHERE row_num>1;

-- How to delete?

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
   `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;
-- insert  in this empty table
 
INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,
funds_raised_millions) AS row_num
FROM layoffs_staging;

-- to delete
DELETE  
FROM layoffs_staging2
WHERE row_num>1;

SELECT *
FROM layoffs_staging2
WHERE row_num>1;



-- Standardising data

SELECT company, TRIM(company)    -- removing spaces from the column company
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company=TRIM(company);


SELECT DISTINCT industry         -- taking a look at the industry column 
FROM layoffs_staging2
ORDER BY industry;


SELECT *                          -- taking a look at the crypto industry  
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

-- set 'cryptocurrency' as 'crypto'

UPDATE layoffs_staging2
SET industry='Crypto'
WHERE industry LIKE 'Crypto%';



SELECT DISTINCT country         -- taking a look at country column 
FROM layoffs_staging2
ORDER BY country; 

-- 2 USA ---> USA and USA.

UPDATE layoffs_staging2
SET country='United States'
WHERE country LIKE 'United States%';

-- try changing the date column to date format instead of Text

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date`=STR_TO_DATE(`date`,'%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

-- now modify the column 'date'

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; 


-- handling empty and NULL values

SELECT *         
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *        
FROM layoffs_staging2              -- we'll try to populate these
WHERE industry IS NULL
OR industry='';


SELECT *        
FROM layoffs_staging2              
WHERE company ='Airbnb';

SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company=t2.company
    AND t1.location=t2.location
WHERE (t1.industry IS NULL OR t1.industry='') 
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2    -- changing blanks to NULL
SET industry=NULL
WHERE industry='';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company=t2.company
SET t1.industry=t2.industry
WHERE (t1.industry IS NULL) 
AND t2.industry IS NOT NULL;



-- we are removing these columns as these do not help

SELECT *         
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE       
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- REMOVE the row_num column

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *         
FROM layoffs_staging2;





