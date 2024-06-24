# SQL_NashvilleData_Cleaning
This project documents how to get the Nashville dataset into SQL Server and cleaning the data to make it ready for analysis.

## Import the data into your SQL Server using the SQL Import and Export Wizard.
From SSMS object explorer, right click on the database you want to use, go to Task > Import data and follow the prompts to select the source file and destination and load the data. Refresh the database after the import is completed to be able to see the new table added.

## Run select statement to see the data

## Converting sale date format using the CONVERT Function.

select SaleDate, CONVERT(Date,SaleDate)As Date from Nashville_Data;

alter table Nashville_Data --add a new column to the table
add SaleDateConv Date;

Update Nashville_Data
set SaleDateConv=CONVERT(Date,SaleDate);

## Removing null from property address column
Here, a self join is done to compare the address where Parcel ID is same and UniqueID is different where Property address is null.


## Breaking property address into address, city, state

Select PropertyAddress from Nashville_Data

Select PropertyAddress,
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as PropAddress,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as PropCity
from Nashville_Data

## Breaking down Owner address
The Owner address column is broken down using the Parsename/Replace function

## Clean 'SoldAsVacant' column to Yes/No 
Using a Case statement, replace 'Y' and 'N' with 'Yes' and 'No'.

## Removing duplicate records
With the Window function Rownumber() and CTE, delete rows with multiple rows that suggest duplicates.

## Remove unnecessary columns
Optimise the table by removing unwanted columns. 

Select *
from Nashville_Data

alter table Nashville_Data
drop column SaleDate, PropertyAddress, OwnerAddress, TaxDistrict;
