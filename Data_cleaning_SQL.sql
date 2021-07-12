/*
Cleaning Data in SQL Queries
*/

SELECT * 
FROM NashvilleHousing..NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM NashvilleHousing..NashvilleHousing

UPDATE NashvilleHousing..NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

-- Use this query if SaleDate won't update propely

ALTER TABLE NashvilleHousing..NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing..NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing..NashvilleHousing



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT nh_1.[UniqueID ], nh_1.ParcelID, nh_1.PropertyAddress, nh_2.[UniqueID ], nh_2.ParcelID, ISNULL(nh_1.PropertyAddress, nh_2.PropertyAddress)
FROM NashvilleHousing..NashvilleHousing nh_1
JOIN NashvilleHousing..NashvilleHousing	nh_2
	ON nh_1.ParcelID = nh_2.ParcelID
	AND nh_1.[UniqueID ] <> nh_2.[UniqueID ]
WHERE nh_1.PropertyAddress IS NULL


UPDATE nh_1
SET PropertyAddress = ISNULL(nh_1.PropertyAddress, nh_2.PropertyAddress)
FROM NashvilleHousing..NashvilleHousing nh_1
JOIN NashvilleHousing..NashvilleHousing	nh_2
	ON nh_1.ParcelID = nh_2.ParcelID
	AND nh_1.[UniqueID ] <> nh_2.[UniqueID ]
WHERE nh_1.PropertyAddress IS NULL



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- For PropertyAddress

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS StreetAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS CityAddress
FROM NashvilleHousing..NashvilleHousing

ALTER TABLE NashvilleHousing..NashvilleHousing
ADD PropertyStreet NVARCHAR(255);

UPDATE NashvilleHousing..NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing..NashvilleHousing
ADD PropertyCity NVARCHAR(255);

UPDATE NashvilleHousing..NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Check the result at the end of the table
SELECT *
FROM NashvilleHousing..NashvilleHousing



-- For OwnerAddress

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing..NashvilleHousing

ALTER TABLE NashvilleHousing..NashvilleHousing
ADD OwnerStreet NVARCHAR(255);

UPDATE NashvilleHousing..NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing..NashvilleHousing
ADD OwnerCity NVARCHAR(255);

UPDATE NashvilleHousing..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing..NashvilleHousing
ADD OwnerState NVARCHAR(255);

UPDATE NashvilleHousing..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Check the result at the end of the table
SELECT *
FROM NashvilleHousing..NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS Count
FROM NashvilleHousing..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant DESC


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing..NashvilleHousing


UPDATE NashvilleHousing..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *, 
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY UniqueID
				   ) row_num
FROM NashvilleHousing..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Once deleted check if any duplicates

WITH RowNumCTE AS (
SELECT *, 
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY UniqueID
				   ) row_num
FROM NashvilleHousing..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



SELECT *
FROM NashvilleHousing..NashvilleHousing


ALTER TABLE NashvilleHousing..NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress