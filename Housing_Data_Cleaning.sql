
--Cleaning Data with SQL Queries

select * from ProjectDB..HousingData

-- Standardizing Date Format

Select SaleDateConverted, Convert(Date, SaleDate) as NewDate
From ProjectDB..HousingData

Update ProjectDB..HousingData
Set SaleDate= Convert(Date, SaleDate)

Alter Table ProjectDB..HousingData
Add SaleDateConverted Date;

Update ProjectDB..HousingData
Set SaleDateConverted= Convert(Date, SaleDate)

---------------------------------------------------------------------------------------------------------


-- Populate Property Address Data

Select *
From ProjectDB..HousingData
--where PropertyAddress is null;
order by ParcelID;


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.propertyaddress)
From ProjectDB..HousingData a
join ProjectDB..HousingData b
	on a.ParcelID= b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



update a
SET PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
from ProjectDB..HousingData a
Join ProjectDB..HousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------



-- Breaking out Address into Individual Columns (Address, CIty, State)


Select PropertyAddress
from ProjectDB..HousingData
--where PropertyAddress is null
--order by ParcelID


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from ProjectDB..HousingData



Alter Table ProjectDB..HousingData
Add PropertySplitAddress Nvarchar (255);

Update ProjectDB..HousingData
Set PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


Alter Table ProjectDB..HousingData
Add PropertySplitCity Nvarchar (255);

Update ProjectDB..HousingData
Set PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));



Select * from ProjectDB..HousingData




Select OwnerAddress from ProjectDB..HousingData


Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From ProjectDB..HousingData



Alter Table ProjectDB..HousingData
Add OwnerSplitAddress NVARCHAR(255);

update ProjectDB..HousingData
SET OwnerSplitAddress= PARSENAME(Replace(OwnerAddress, ',', '.'), 3);



Alter Table ProjectDB..HousingData
Add OwnerSplitCity NVARCHAR(255);

update ProjectDB..HousingData
SET OwnerSplitCity= PARSENAME(Replace(OwnerAddress, ',', '.'), 2);



Alter Table ProjectDB..HousingData
Add OwnerSplitState NVARCHAR(255);

update ProjectDB..HousingData
SET OwnerSplitState= PARSENAME(Replace(OwnerAddress, ',', '.'), 1);



Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from ProjectDB..HousingData
Group by SoldAsVacant
order by 2


Select SoldAsVacant, 
	CASE when SoldAsVacant='Y' Then 'Yes'
			when SoldAsVacant='N' Then 'No'
		Else SoldAsVacant
	End
From ProjectDB..HousingData
order by SoldAsVacant


Update ProjectDB..HousingData
SET SoldAsVacant= CASE when SoldAsVacant='Y' Then 'Yes'
						when SoldAsVacant='N' Then 'No'
					Else SoldAsVacant
				  End


---------------------------------------------------------------------------------------------------------



-- Remove Duplicates



With RowNumCTE As(
Select *, 
	Row_Number() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
			Order by
				 UniqueID
				 ) row_num
From ProjectDB..HousingData
--order by ParcelID
)
Delete from RowNumCTE 
where row_num > 1
--order by PropertyAddress

---------------------------------------------------------------------------------------------------------


-- Delete Unused Columns


ALTER TABLE ProjectDB..HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select * from ProjectDB..HousingData


