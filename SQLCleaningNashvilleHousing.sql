Select *
From PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------
-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--------------------------------------------------------------------
-- Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing

------------------------------------------------
--Where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL
---------------------------------------------------------------------------
-- Breaking out Address into Individual Columns 
-- using the SUBSTRING function (Address, City)

Select PropertyAddress
From PortfolioProject..NashvilleHousing
-------------------------------------------------------------------------
--Where PropertyAddress is NULL
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City

From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
-------------------------------------------------------------------------------------------------------------
-- Check and see the new populated columns at the end of table

Select *
From PortfolioProject..NashvilleHousing
-------------------------------------------------------------------------
-- Now to break out owners address using PARSENAME (Address, City, State)

Select OwnerAddress
From PortfolioProject..NashvilleHousing
--------------------------------------------------------------------------
-- PARSENAME

Select 
PARSENAME(REPLACE(Owneraddress, ',', '.'), 3) as OwnerAddressSplit
, PARSENAME(REPLACE(Owneraddress, ',', '.'), 2) as OwnerCitySplit
, PARSENAME(REPLACE(Owneraddress, ',', '.'), 1) as OwnerStateSplit
From PortfolioProject..NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerAddressSplit Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(Owneraddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerCitySplit Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerCitySplit = PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerStateSplit Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerStateSplit = PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)

------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" Lot

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing


Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END 
-----------------------------------------------------------------------
-- Remove Duplicates using a CTE

WITH RowNumCTE as(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					ParcelID
					) row_num
From PortfolioProject..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1

--------------------------------------------------------------
-- Delete some unused columns

Select *
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate