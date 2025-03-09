select *
from NashvilleHousing

--Standardising Date format

select SaleDateConverted, CONVERT(Date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate);


--Populate Property Address data(Null values)

Select * 
from NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress, ISNULL(n1.PropertyAddress,n2.PropertyAddress) 
from NashvilleHousing n1
JOIN NashvilleHousing n2
	ON n1.ParcelID = n2.ParcelID
	AND n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is null

Update n1
SET PropertyAddress = ISNULL(n1.PropertyAddress,n2.PropertyAddress)
FROM NashvilleHousing n1 
JOIN NashvilleHousing n2 
	ON n1.ParcelID = n2.ParcelID
	AND n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is null


--Breaking out Address into individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

select * from NashvilleHousing


-- For owner address

select OwnerAddress
from NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant
Order by 2

Select SoldAsVacant,
	case when SoldAsVacant ='Y' then'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
	end

From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = case when SoldAsVacant ='Y' then'Yes'
						 when SoldAsVacant = 'N' then 'No'
						 else SoldAsVacant
					end


--Remove Duplicates

with RowNumCte as(
select * ,
	ROW_NUMBER() over(
	Partition by	ParcelId,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by 
						UniqueId		
	)as row_num

From NashvilleHousing
--Order by ParcelID
)
Delete 
from RowNumCte
Where row_num >1


--Delete Unused Columns

Alter table NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table NashvilleHousing
Drop column SaleDate




















