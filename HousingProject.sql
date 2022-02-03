/*
Cleaning Data in SQL queries
*/

Select *
From NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted, Convert(Date, SaleDate)
From NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Adress

Select PropertyAddress
From NashvilleHousing
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

-- Breaking address into individual columns

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Select OwnerAddress
from NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress,',','.'), 3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

-- Change Y and N to Yes and No in the Sold as Vacant field

Select Distinct (SoldAsVacant), Count (SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHousing

-- Remove Duplicates

Select *
From NashvilleHousing

With RowNumCTE As(
Select *,
	Row_Number() Over( 
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID) row_num
From NashvilleHousing)
Delete*
From RowNumCTE
Where row_num >1
Order by PropertyAddress

--Delete Unused Columns(usually done on views)

Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, PropertyAddress

Alter Table NashvilleHousing
Drop Column SaleDate
