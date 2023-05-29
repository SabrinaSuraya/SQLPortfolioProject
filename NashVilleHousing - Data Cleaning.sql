SELECT * 
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing

--Stardize Date format

SELECT SaleDateConverted, CONVERT(Date,SaleDate) 
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing

Update [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
ADD SaleDateConverted Date;

Update [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address data ( The Property Address is null but can be replaced with other PropertyAddress if teh ParcelID is same)
SELECT *
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
--WHERE Propertyaddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing a
JOIN [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID --<> is not equal, chech repetion in parcelID but not in unique id
WHERE a.PropertyAddress IS NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing a
JOIN [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID --<> is not equal, chech repetion in parcelID but not in unique id
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Column (Address, City, State)
SELECT PropertyAddress
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
--WHERE Propertyaddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) AS Address
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing


ALTER TABLE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))

SELECT * 
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing

SELECT OwnerAddress 
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing

ALTER TABLE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT * 
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing

--Change Y and N  to Yes and No in "Sold as Vacant" field
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						  WHEN SoldAsVacant = 'N' THEN 'No'
						  ELSE SoldAsVacant
						  END
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing

UPDATE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						  WHEN SoldAsVacant = 'N' THEN 'No'
						  ELSE SoldAsVacant
						  END

--Remove duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) row_num

FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
--Order by ParcelID
)

SELECT * -- DELETE First (delete the duplicate)
FROM RowNumCTE
WHERE row_num > 1
--Order by PropertyAddress

--Delete Unused Column
SELECT * 
FROM [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing

ALTER TABLE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio 2 - Data Cleaning - NashVilleHousing].dbo.NashVilleHousing
DROP COLUMN SaleDate
