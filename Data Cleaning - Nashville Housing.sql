
--CLEANING DATA.

SELECT *
FROM NashvilleHousing



--STANDARDIZE DATE FORMAT.

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing 
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousing



-- POPULATE PROPERTY ADDRESS DATA.

SELECT *
FROM NashvilleHousing
ORDER BY ParcelId

SELECT NHA.ParcelID, NHA.PropertyAddress, NHB.ParcelID, NHB.PropertyAddress, ISNULL(NHA.PropertyAddress, NHB.PropertyAddress)
FROM NashvilleHousing NHA
JOIN NashvilleHousing NHB
	ON NHA.ParcelID = NHB.ParcelID
	AND NHA.[UniqueID] <> NHB.[UniqueID]
WHERE NHA.PropertyAddress is null

UPDATE NHA
SET PropertyAddress = ISNULL(NHA.PropertyAddress, NHB.PropertyAddress)
FROM NashvilleHousing NHA
JOIN NashvilleHousing NHB
	ON NHA.ParcelID = NHB.ParcelID
	AND NHA.[UniqueID] <> NHB.[UniqueID]
WHERE NHA.PropertyAddress is null



-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing



-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT OwnerAddress
FROM NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousing



-- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD.

SELECT DISTINCT(Soldasvacant), COUNT(Soldasvacant)
FROM NashvilleHousing
GROUP BY Soldasvacant
ORDER BY 2

SELECT Soldasvacant, 
	CASE WHEN Soldasvacant = 'Y' THEN 'Yes'
		WHEN Soldasvacant = 'N' THEN 'No'
		ELSE Soldasvacant
		END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET Soldasvacant = CASE WHEN Soldasvacant = 'Y' THEN 'Yes'
		WHEN Soldasvacant = 'N' THEN 'No'
		ELSE Soldasvacant
		END



-- REMOVE DUPLICATES. 

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER ( PARTITION BY ParcelID,
										  PropertyAddress,
										  SalePrice,
										  SaleDate,
										  LegalReference
							 ORDER BY UniqueID ) row_num 
FROM NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-- DELETE UNUSED COLUMNS.

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

