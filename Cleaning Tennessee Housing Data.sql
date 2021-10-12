--Cleaning housing data from Tennessee

SELECT *
FROM Project1..HousingData


--Formatting date appropriately

SELECT SaleDate, CONVERT(date, SaleDate)
FROM Project1..HousingData

UPDATE Project1..HousingData
SET SaleDate = CONVERT(date, SaleDate)


-- Property data

SELECT *
FROM Project1..HousingData
WHERE PropertyAddress is NULL


-- Joining the table with itself in order to see which parcel id's have null address values

SELECT t1.ParcelID, t2.ParcelID, t1.PropertyAddress, t2.PropertyAddress, ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM Project1..HousingData t1
JOIN Project1..HousingData t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ]<> t2.[UniqueID ]
WHERE t1.PropertyAddress is NULL



-- Updating the table so that any null addresses are replaced with the appropriate address, ISNULL will take t1 addresses which are null and substitute t2 addresses


UPDATE t1
SET PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM Project1..HousingData t1
JOIN Project1..HousingData t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ]<> t2.[UniqueID ]
WHERE t1.PropertyAddress is NULL


-- Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM Project1..HousingData


-- We are selecting a substring within the column PropertyAddress which starts at the first position, and is separated by a comma
-- The same logic is applied for the second column we create except it is starting at the comma and ends where the string PropertyAddress does
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +1 , LEN(PropertyAddress)) as City
FROM Project1..HousingData

-- Creating columns to add to the table which is then updated
ALTER TABLE Project1..HousingData
ADD true_address NVARCHAR(255)

UPDATE Project1..HousingData
SET true_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


ALTER TABLE Project1..HousingData
ADD true_city NVARCHAR(255)

UPDATE Project1..HousingData
SET true_city = SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
FROM Project1..HousingData

SELECT OwnerAddress
FROM Project1..HousingData

--PARSENAME looks for periods as delimiters so we will change our commas to periods

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as owner_address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as owner_city,  
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as owner_state
FROM Project1..HousingData 
WHERE OwnerAddress is not NULL

ALTER TABLE Project1..HousingData
ADD owner_address NVARCHAR(255)

UPDATE Project1..HousingData
SET owner_address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Project1..HousingData
ADD owner_city NVARCHAR(255)

UPDATE Project1..HousingData
SET owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Project1..HousingData
ADD owner_state NVARCHAR(255)

UPDATE Project1..HousingData
SET owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Checking
SELECT *
FROM Project1..HousingData


--Deleting the columns that are no longer needed due to updating the table previously

SELECT *
FROM Project1..HousingData
WHERE OwnerName is not NULL

ALTER TABLE Project1..HousingData
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict