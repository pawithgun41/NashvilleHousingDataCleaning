/*
Cleaning Data in SQL Queries
using PostgreSQL
*/



Select *
From #NashvilleHousing_tmp

--------------------------------------------------------------------------------------------------------------------------

-- change Date Format of SaleDate column

ALTER TABLE #NashvilleHousing_tmp
Add SaleDateConverted Date;

Update #NashvilleHousing_tmp
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
-- manage null value of Property Address column

Select *
From #NashvilleHousing_tmp
order by ParcelID



Select	a.ParcelID, 
		a.PropertyAddress,
		b.ParcelID, 
		b.PropertyAddress, 
		ISNULL(a.PropertyAddress,b.PropertyAddress)
From #NashvilleHousing_tmp a
JOIN #NashvilleHousing_tmp b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From #NashvilleHousing_tmp a
JOIN #NashvilleHousing_tmp b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From #NashvilleHousing_tmp


SELECT	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From #NashvilleHousing_tmp


ALTER TABLE #NashvilleHousing_tmp
Add PropertySplitAddress Nvarchar(255);

Update #NashvilleHousing_tmp
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE #NashvilleHousing_tmp
Add PropertySplitCity Nvarchar(255);

Update #NashvilleHousing_tmp
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From #NashvilleHousing_tmp




Select OwnerAddress
From #NashvilleHousing_tmp


Select	OwnerAddress,
		PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
		PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
		PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From #NashvilleHousing_tmp



ALTER TABLE #NashvilleHousing_tmp
Add OwnerSplitAddress Nvarchar(255);

Update #NashvilleHousing_tmp
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE #NashvilleHousing_tmp
Add OwnerSplitCity Nvarchar(255);

Update #NashvilleHousing_tmp
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE #NashvilleHousing_tmp
Add OwnerSplitState Nvarchar(255);

Update #NashvilleHousing_tmp
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From #NashvilleHousing_tmp




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From #NashvilleHousing_tmp
Group by SoldAsVacant
order by 2



Select	SoldAsVacant,
		(CASE When SoldAsVacant = 'Y' THEN 'Yes'
			  When SoldAsVacant = 'N' THEN 'No'
			  ELSE SoldAsVacant
			  END
		)
From #NashvilleHousing_tmp



Update #NashvilleHousing_tmp
SET SoldAsVacant = (CASE When SoldAsVacant = 'Y' THEN 'Yes'
						 When SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
					     END
				    )



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- extract duplicate

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From #NashvilleHousing_tmp
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From #NashvilleHousing_tmp



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
-- example unused are OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


Select *
From #NashvilleHousing_tmp

ALTER TABLE #NashvilleHousing_tmp
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
