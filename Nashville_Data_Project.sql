/* SQL DATA CLEANING using Nashville housing prices database */

Select Top 5 * from Nashville_Data

/* Check the information schema to confirm the data type assigned to each column */

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Nashville_Data';

--Converting sale date format using the CONVERT Function.

-- use this to check the data type conversion before altering the table
Select SaleDate, CONVERT(Date,SaleDate)As Date from Nashville_Data; 


alter table Nashville_Data --add a new column to the table
add SaleDateConv Date;

Update Nashville_Data
set SaleDateConv=CONVERT(Date,SaleDate);

--Removing null from property address

select * from Nashville_Data
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From Nashville_Data a
JOIN Nashville_Data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville_Data a
JOIN Nashville_Data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville_Data a
JOIN Nashville_Data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select * from Nashville_Data --check if we still have nulls in PropertyAddress column.
where PropertyAddress is null

--Breaking property address into address, city, state

Select PropertyAddress from Nashville_Data

Select PropertyAddress,
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as PropAddress,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as PropCity
from Nashville_Data

alter table Nashville_Data
add PropAddress nvarchar(255);

Update Nashville_Data
set PropAddress=substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table Nashville_Data
add PropCity nvarchar(255);

Update Nashville_Data
set PropCity=substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select PropertyAddress,PropAddress,PropCity from Nashville_Data


--Breaking down Owner address

Select OwnerAddress from Nashville_Data 

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Nashville_Data

alter table Nashville_Data
add OwnerAdd nvarchar(255);
	

Update Nashville_Data
set OwnerAdd=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

alter table Nashville_Data
add OwnerCity nvarchar(255);

Update Nashville_Data
set OwnerCity=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

alter table Nashville_Data
add OwnerState nvarchar(255);

Update Nashville_Data
set OwnerState=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select * from Nashville_Data

--Clean 'SoldAsVacant' column to Yes/No 

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville_Data
Group by SoldAsVacant
order by 2

Select SoldAsVacant, 
CASE	
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From Nashville_Data

Update Nashville_Data
SET SoldAsVacant = 
CASE 
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

Select distinct(SoldAsVacant),count(SoldAsVacant) from Nashville_Data
group by SoldAsVacant


--Removing duplicate records

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
From Nashville_Data
order by row_num desc;

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) as row_num
From Nashville_Data)
Select *
From RowNumCTE
Where row_num > 1  -- use CTE to extract rows with duplicate record.

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) as row_num
From Nashville_Data)
Delete 
From RowNumCTE
Where row_num > 1

Select count(*)
from Nashville_Data

--Remove unnecessary columns

Select *
from Nashville_Data

alter table Nashville_Data
drop column SaleDate, PropertyAddress,OwnerAddress,TaxDistrict

Select *
from Nashville_Data;