SELECT * FROM data_cleaning.layoffs;

CREATE TABLE Cleaning_Process
LIKE data_cleaning.layoffs;

SELECT * FROM Cleaning_Process;

INSERT Cleaning_Process
SELECT * FROM data_cleaning.layoffs;

UPDATE Cleaning_Process
SET percentage_laid_off = 'Unknown'
WHERE percentage_laid_off = NULL ;

-- ***************************************************** REMOVE DUPLICATE *****************************************************************************************
WITH duplicate_row AS 
( SELECT
	*,
    ROW_NUMBER () OVER( PARTITION BY
    company,location,industry,total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
)  AS ROW_NUM
 FROM Cleaning_Process)

SELECT * FROM  duplicate_row
WHERE ROW_NUM > 1; 

ALTER TABLE Cleaning_Process ADD COLUMN duplicate_row INT;
ALTER TABLE Cleaning_Process DROP COLUMN duplicate_row ;

-- CREATE ANOTHER TABLE TOSTORE THE COLUMN DUPLICATE
CREATE TABLE `cleaning_process_duplicate` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `duplicate_row` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM cleaning_process_duplicate ; 

INSERT INTO cleaning_process_duplicate
SELECT
	*,
    ROW_NUMBER () OVER( PARTITION BY
    company,location,industry,total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
)  AS ROW_NUM
 FROM Cleaning_Process; 

SELECT * 
FROM cleaning_process_duplicate
WHERE duplicate_row > 1 ; 

DELETE 
FROM cleaning_process_duplicate
WHERE duplicate_row > 1 ; 


-- ***************************************************** STANDARDIZING DATA *****************************************************************************************
-- TRIM COMPANY COLUMN 

SELECT company, TRIM(company)
FROM cleaning_process_duplicate; 

UPDATE cleaning_process_duplicate
SET company = TRIM(company) ; 

-- A LOOK AT INDUSTRY

SELECT industry
FROM cleaning_process_duplicate
WHERE industry LIKE '%Crypto%' ; 

UPDATE cleaning_process_duplicate
SET industry = 'Crypto'
WHERE industry = 'Crypto Currency';

SELECT DISTINCT (industry)
FROM cleaning_process_duplicate ;

-- A LOOK AT COUNTRY

SELECT DISTINCT country
FROM cleaning_process_duplicate ;

SELECT DISTINCT (country), TRIM(TRAILING'.' FROM country)
FROM cleaning_process_duplicate ;

UPDATE cleaning_process_duplicate 
SET country = (TRIM(TRAILING'.' FROM country));

-- CHANGE THE FROMAT OF date VARIABLE TO DATE 

SELECT date, str_to_date(date, '%m/%d/%Y')
FROM cleaning_process_duplicate ;

UPDATE cleaning_process_duplicate 
SET date = str_to_date(date, '%m/%d/%Y'); 

SELECT *
FROM cleaning_process_duplicate;

ALTER TABLE cleaning_process_duplicate
MODIFY COLUMN date DATE;

-- ***************************************************** NULL AND BLANK VALUE *****************************************************************************************
-- POPULATE INDUSTRY THROUGH THE COMANY

SELECT  -- (FIND COMPANY THAT INDISTRY IS BLANK)
	company,industry
FROM cleaning_process_duplicate
WHERE industry ='';

SELECT--  (POPULATE Airbnb INDUSTRY ) *****************************************************
	company,industry
FROM cleaning_process_duplicate
WHERE company = 'Airbnb' ;

UPDATE cleaning_process_duplicate -- (SET SQL_SAFE_UPDATES = 0;)
SET industry = 'Travel'
WHERE Company = 'Airbnb' AND
industry =''; 

SELECT -- (POPUATE Carnava INDUSTRY) *****************************************************
	company,industry
FROM cleaning_process_duplicate
WHERE company = 'Carvana' ;

UPDATE cleaning_process_duplicate -- (SET SQL_SAFE_UPDATES = 0;)
SET industry = 'Transportation'
WHERE Company = 'Carvana' AND
industry =''; 

SELECT -- (POPULATE Juul INDUSTRY) *****************************************************
	company,industry
FROM cleaning_process_duplicate
WHERE company = 'Juul' ;

UPDATE cleaning_process_duplicate -- (SET SQL_SAFE_UPDATES = 0;)
SET industry = 'Consumer'
WHERE Company = 'Juul' AND
industry =''; 


SELECT *
FROM cleaning_process_duplicate
WHERE industry IS NULL OR 
industry = '' ;  
 
DELETE
FROM cleaning_process_duplicate
WHERE total_laid_off IS NULL OR 
total_laid_off = '' ; 
 
DELETE
FROM cleaning_process_duplicate
WHERE percentage_laid_off IS NULL OR 
percentage_laid_off = '' ;  

SELECT company, funds_raised_millions
FROM cleaning_process_duplicate
WHERE funds_raised_millions IS NULL
OR funds_raised_millions =''; 

SELECT *
FROM cleaning_process_duplicate
WHERE stage IS NULL 
OR stage = '' ;

ALTER TABLE cleaning_process_duplicate -- FROP STAGE COLUMN
DROP stage ; 

ALTER TABLE cleaning_process_duplicate -- FROP DUPLICATE ROW COLUMN
DROP duplicate_row;

UPDATE cleaning_process_duplicate -- REPLACE NULL AND BLANK BY 0 IN FUNDS RAISED COLUMN
SET funds_raised_millions = 0
WHERE funds_raised_millions = '' ;

UPDATE cleaning_process_duplicate
SET funds_raised_millions = 0
WHERE funds_raised_millions IS NULL ;

SELECT *
FROM cleaning_process_duplicate
WHERE percentage_laid_off IS NULL OR 
total_laid_off = '' ; 


SELECT COUNT(*)
FROM cleaning_process_duplicate;
