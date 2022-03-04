
--Cleaning Data

Select *
From PortfolioProject..NashvilleHousing

--Standardizing Data Format

ALTER Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CAST(SaleDate as Date)

Select SaleDateConverted
From PortfolioProject..NashvilleHousing

--Splitting the date into Day, Month, and Year.

Select 
PARSENAME(REPLACE(SaleDateConverted,'-','.'),1),
PARSENAME(REPLACE(SaleDateConverted,'-','.'),2),
PARSENAME(REPLACE(SaleDateConverted,'-','.'),3)
From PortfolioProject..NashvilleHousing

Select * 
From PortfolioProject..NashvilleHousing
Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDay

ALTER Table NashvilleHousing
Add  SaleDay Nvarchar(255);

Update NashvilleHousing
SET SaleDay = PARSENAME(REPLACE(SaleDateConverted,'-','.'),1)

ALTER Table NashvilleHousing
Add  SaleMonth Nvarchar(255);

Update NashvilleHousing
SET SaleMonth = PARSENAME(REPLACE(SaleDateConverted,'-','.'),2)

ALTER Table NashvilleHousing
Add  SaleYear Nvarchar(255);

Update NashvilleHousing
SET SaleYear = PARSENAME(REPLACE(SaleDateConverted,'-','.'),3)

Select * 
From PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select nopop.ParcelID, nopop.PropertyAddress, pop.ParcelID, pop.PropertyAddress, ISNULL(nopop.PropertyAddress, pop.PropertyAddress)
From PortfolioProject..NashvilleHousing nopop
JOIN PortfolioProject..NashvilleHousing pop
	on nopop.ParcelID = pop.ParcelID
	AND nopop.[UniqueID ] <> pop.[UniqueID ]
Where nopop.PropertyAddress is null

Update nopop
SET PropertyAddress = ISNULL(nopop.PropertyAddress, pop.PropertyAddress)
From PortfolioProject..NashvilleHousing nopop
JOIN PortfolioProject..NashvilleHousing pop
	on nopop.ParcelID = pop.ParcelID
	AND nopop.[UniqueID ] <> pop.[UniqueID ]
Where nopop.PropertyAddress is null
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking Adderess into Individual Columns as (Adddress, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))AS City
From PortfolioProject..NashvilleHousing


ALTER Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER Table NashvilleHousing
Add  PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing


Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing

ALTER Table NashvilleHousing
Add  OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER Table NashvilleHousing
Add  OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER Table NashvilleHousing
Add  OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------
--Assigning Y and N values to Yes and No in "Sold as Vacant" Column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END		
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------------
--Removing Duplicates
With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num
From PortfolioProject..NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--------------------------------------------------------------------------------------
--Deleting Unused Columns

Select * 
From PortfolioProject..NashvilleHousing
Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate
--Drop Column OwnerAddress, TaxDistrict, PropertyAddress
