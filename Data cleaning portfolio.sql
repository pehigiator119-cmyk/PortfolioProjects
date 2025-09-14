

Select *
From [PortfolioProject ]..NashvilleHousing



-- Standardise Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From [PortfolioProject ]..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Addess Data

Select *
From [PortfolioProject ]..NashvilleHousing
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [PortfolioProject ]..NashvilleHousing a
JOIN [PortfolioProject ]..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [PortfolioProject ]..NashvilleHousing a
JOIN [PortfolioProject ]..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From [PortfolioProject ]..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address
,   SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 , lEN(PropertyAddress)) as Address

From [PortfolioProject ]..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 , lEN(PropertyAddress))



Select *
From [PortfolioProject ]..NashvilleHousing



Select OwnerAddress
From [PortfolioProject ]..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)
From [PortfolioProject ]..NashvilleHousing



ALTER TABLE NashvilleHousing  
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant),COUNT(SoldAsVacant)
From [PortfolioProject ]..NashvilleHousing
GROUP BY SoldAsVacant
Order by 2


select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
From [PortfolioProject ]..NashvilleHousing


UPDATE NashvilleHousing
SET  SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END



-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
    ROW_NUMBER () OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference 
                 ORDER BY
                    UniqueID
                    ) row_num

From [PortfolioProject ]..NashvilleHousing
)
Select *
From RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

Select *
From [PortfolioProject ]..NashvilleHousing




-- Delete Unused Columns

Select *
From [PortfolioProject ]..NashvilleHousing

ALTER TABLE [PortfolioProject ]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [PortfolioProject ]..NashvilleHousing
DROP COLUMN SaleDate

