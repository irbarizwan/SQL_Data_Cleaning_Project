-- change column name
ALTER TABLE housingdata
CHANGE COLUMN `ï»¿UniqueID` UniqueID INT;

-- create table

CREATE TABLE staging_housing_data AS
SELECT * FROM housingdata;

-- check data

SELECT * FROM staging_housing_data
ORDER BY UniqueID;

-- check unique id

SELECT *
FROM staging_housing_data
WHERE UniqueID IN (
    SELECT UniqueID
    FROM staging_data
    GROUP BY UniqueID
    HAVING COUNT(*) > 1
);

-- preview unique id data

SELECT t1.*
FROM staging_housing_data t1
JOIN staging_housing_data t2
ON t1.ParcelID = t2.ParcelID
AND t1.UniqueID > t2.UniqueID;

-- delete duplicate data

DELETE t1
FROM staging_housing_data t1
JOIN staging_housing_data t2
ON t1.ParcelID = t2.ParcelID
AND t1.UniqueID > t2.UniqueID;

-- standarize the table

UPDATE staging_housing_data
SET SoldAsVacant = 
    CASE 
        WHEN SoldAsVacant IN ('Y', 'Yes') THEN 'Yes'
        WHEN SoldAsVacant IN ('N', 'No') THEN 'No'
        ELSE SoldAsVacant
    END;
    -- check missing values

SELECT *
FROM staging_housing_data
WHERE PropertyAddress IS NULL;

-- preview split the address column
    SELECT 
    PropertyAddress,
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City
FROM staging_housing_data;

-- add new column

ALTER TABLE staging_housing_data
ADD PropertyStreet VARCHAR(255),
ADD PropertyCity VARCHAR(255);

-- update column

UPDATE staging_housing_data
SET 
    PropertyStreet = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1),
    PropertyCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);
    
-- check updated data
    
    SELECT PropertyAddress, PropertyStreet, PropertyCity
FROM staging_housing_data;


-- check data
SELECT SaleDate
FROM staging_housing_data;

-- update date
UPDATE staging_housing_data
SET SaleDate = STR_TO_DATE(SaleDate, '%e-%b-%y')
WHERE SaleDate IS NOT NULL;



-- validation 

SELECT COUNT(*) FROM staging_housing_data;

SELECT COUNT(DISTINCT UniqueID) FROM staging_housing_data;

BEGIN;
-- your changes
ROLLBACK; -- if something goes wrong


