--removing duplicates

--creating table layoffs_staging
SELECT company, location, industry, total_laid_off, percentage_laid_off, 
       layoff_date, stage, country, funds_raised_millions, COUNT(*)
FROM layoffs_staging
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, 
         layoff_date, stage, country, funds_raised_millions
HAVING COUNT(*) > 1;

--inserting data to layoffs_staging
INSERT INTO layoffs_staging (company, location, industry, total_laid_off, percentage_laid_off, layoff_date, stage, country, funds_raised_millions)
SELECT company, location, industry, total_laid_off, percentage_laid_off, layoff_date, stage, country, funds_raised_millions
FROM layoffs;

--determining duplicates
WITH CTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, 
                            percentage_laid_off, layoff_date, stage, country, funds_raised_millions
               ORDER BY layoff_date -- You can change the order to any column you'd like to prioritize
           ) AS rn
    FROM layoffs_staging
)
SELECT * 
FROM CTE
WHERE rn > 1;


--deleting duplicates
WITH CTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, 
                            percentage_laid_off, layoff_date, stage, country, funds_raised_millions
               ORDER BY layoff_date -- Change the column to prioritize when row number is assigned
           ) AS rn
    FROM layoffs_staging
)
DELETE ls
FROM layoffs_staging ls
INNER JOIN CTE cte
    ON ls.company = cte.company
    AND ls.location = cte.location
    AND ls.industry = cte.industry
    AND ls.total_laid_off = cte.total_laid_off
    AND ls.percentage_laid_off = cte.percentage_laid_off
    AND ls.layoff_date = cte.layoff_date
    AND ls.stage = cte.stage
    AND ls.country = cte.country
    AND ls.funds_raised_millions = cte.funds_raised_millions
WHERE cte.rn > 1;

select * from layoffs where company = 'casper'

--checking duplicates
SELECT company, location, industry, total_laid_off, percentage_laid_off, 
       layoff_date, stage, country, funds_raised_millions, COUNT(*)
FROM layoffs_staging
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, 
         layoff_date, stage, country, funds_raised_millions
HAVING COUNT(*) > 1;


-- standardizing data

select company, trim(company) as trimm from layoffs_staging;
update layoffs_staging
set company = trim(company);


select distinct industry from layoffs_staging order by 1;

select * from layoffs_staging where industry like 'crypto%' ;
update layoffs_staging set industry = 'Crypto' where industry like 'crypto%';
select distinct industry from layoffs_staging order by 1;
select * from layoffs_staging order by 1;
select distinct country from layoffs_staging where country like 'united states%' order by 1;

select * from layoffs_staging;



--null&blank values

select * from layoffs_staging where total_laid_off is null and percentage_laid_off is null;
select * from layoffs_staging where industry is null or industry = ' ';
select * from layoffs_staging where company = 'Airbnb'


select t1.industry, t2.industry from layoffs_staging t1
join layoffs_staging t2
on t1.company = t2.company
where (t1.industry is null or t1.industry = ' ')
and t2.industry is not null;

--checking null&blanks
SELECT *
FROM layoffs_staging
WHERE industry IS NULL OR industry = '';

--checking not null/blamk matches
SELECT DISTINCT t1.company
FROM layoffs_staging t1
WHERE t1.industry IS NULL OR t1.industry = ''
AND EXISTS (
    SELECT 1
    FROM layoffs_staging t2
    WHERE t1.company = t2.company
    AND t2.industry IS NOT NULL AND t2.industry <> ''
);

--updating nulls&blanks
UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging t1
JOIN layoffs_staging t2
    ON t1.company = t2.company
   AND t1.location = t2.location
   AND t2.industry IS NOT NULL AND t2.industry <> ''
WHERE (t1.industry IS NULL OR t1.industry = '');


select * from layoffs_staging where company = 'Airbnb'



--removing Unnecessary Columns/Rows
delete from layoffs_staging where total_laid_off is null and percentage_laid_off is null;
select * from layoffs_staging