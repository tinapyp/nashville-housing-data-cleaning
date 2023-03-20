/*
Cleaning Data in SQL
*/

--Overviewing data
SELECT *
FROM 
	PortofolioProject..NashvilleHousing

--------------------------------------------------------------------

/* Standardize Date Format */
-- USING CONVERT
SELECT 
	SaleDate,
	CONVERT(DATE,SaleDate)
FROM 
	PortofolioProject..NashvilleHousing

-- USING CAST
SELECT 
	SaleDate,
	CAST(SaleDate AS DATE)
FROM 
	PortofolioProject..NashvilleHousing

--INSERTING Data to Table
UPDATE PortofolioProject..NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

--OR USING ALTER TABLE TO INSERT DATA

ALTER TABLE NashvilleHousing
ADD SaleDateC Date;

UPDATE NashvilleHousing
SET SaleDateC = CONVERT(DATE,SaleDate)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
--------------------------------------------------------------------

/*  Populate Property Address Data */
--Overviewing data
SELECT *
FROM 
	PortofolioProject..NashvilleHousing
WHERE
	PropertyAddress IS NULL
ORDER BY ParcelID

--- FILLING NULL DATA PropertyAddress from same ParcelId
SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	PortofolioProject..NashvilleHousing a
JOIN
	PortofolioProject..NashvilleHousing b 
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--- INSERTING DATA INTO TABLE
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	PortofolioProject..NashvilleHousing a
JOIN
	PortofolioProject..NashvilleHousing b 
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

--------------------------------------------------------------------

/* Breaking Out Adress into Individual Columns (Address, City, State) */
--Overviewing data
SELECT 
	*
FROM 
	PortofolioProject..NashvilleHousing

--Doing on Property Address Using SUBSTRING
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM 
	PortofolioProject..NashvilleHousing

--INSERTING Data to Table
ALTER TABLE PortofolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortofolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

---
ALTER TABLE PortofolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortofolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

--Doing on Owner Adress
---Overviewing data
SELECT 
	OwnerAddress
FROM 
	PortofolioProject..NashvilleHousing

--Using PARSENAME
SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.') ,3),
	PARSENAME(REPLACE(OwnerAddress,',','.') ,2),
	PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
FROM 
	PortofolioProject..NashvilleHousing

--INSERTING Data to Table
ALTER TABLE PortofolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortofolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') ,3)
---
ALTER TABLE PortofolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortofolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') ,2)
---
ALTER TABLE PortofolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortofolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
--------------------------------------------------------------------
/* Change Y or N to Yes or No in "Sold as Vacant" Field  */
--Overviewing data
SELECT DISTINCT
	SoldAsVacant,
	COUNT(SoldAsVacant)
FROM 
	PortofolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--Change the all value to Yes or No
SELECT 
	SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM 
	PortofolioProject..NashvilleHousing

-- Inserting data to table
UPDATE PortofolioProject..NashvilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

--------------------------------------------------------------------
/* Remove Duplicates */
--Overviewing data
SELECT *
FROM 
	PortofolioProject..NashvilleHousing

-- Using Row_Number to detect duplicate data
WITH CTE_RowNum AS
(
SELECT
	*,
	ROW_NUMBER() OVER(
		PARTITION BY	ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY
							UniqueID
							) AS row_num
FROM 
	PortofolioProject..NashvilleHousing
)
DELETE -- Delete Duplicate Data
FROM 
	CTE_RowNum
WHERE 
	row_num > 1

--------------------------------------------------------------------
/* Delete Unused Columns */
--Overviewing data
SELECT *
FROM 
	PortofolioProject..NashvilleHousing

--Delete Columns
ALTER TABLE PortofolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
--------------------------------------------------------------------
--Overviewing Clean Data
SELECT 
	*
FROM 
	PortofolioProject..NashvilleHousing
ORDER BY
	SaleDate