-- Data Cleaning Project

SELECT *
FROM DataCleaningProject..HouseSales


SELECT Convert(date,SaleDate), SaleDate, SaleDateConverted
FROM DataCleaningProject..HouseSales

--- Standarize Date Format (to standarize the date format only to YYYY-MM-DD)

-- In this Standarize
-- First thing is to add new column called 'SaleDateConverted' as "date" data
-- Then, fill the 'SaleDateConverted' data with 'Convert(date,SaleDate)'
-- Finally, the 'SaleDateConverted' will be filled with new datatype of 'SaleDate'

-- This is not work because the 'SaleDate' is already "date" dataype. So, it need to create a new column data
UPDATE DataCleaningProject..HouseSales
SET SaleDate = Convert(date,SaleDate)

-- First thing is to add new column called 'SaleDateConverted' as "date" data
ALTER TABLE HouseSales
Add SaleDateConverted date;
-- Finally, the 'SaleDateConverted' will be filled with new datatype of 'SaleDate'
UPDATE HouseSales
SET SaleDateConverted = Convert(date,SaleDate)

--- Populate Property Address Data (to fill the null address data in "PropertyAddress" with existing data from another looklike column (with same ParcelID or Owner Address)

-- First, try to find the null "PropertyAddress" data
-- I am trying to find the "PropertyAddress" which has the same "ParcelID" with the null "PropertyAddress" 
-- Now we have to compare (the null data) and (the "PropertyAddress" which has the same "ParcelID" with the null "PropertyAddress"). only to make sure all null data can be fill with the new address
-- Finally, after comparing, Update the null data with the comparing


-- First, try to find the null "PropertyAddress" data
-- We found 29 Data with null "PropertyAddress"

SELECT [UniqueID ], ParcelID, PropertyAddress
FROM DataCleaningProject..HouseSales
WHERE PropertyAddress is null
ORDER BY 1

-- I am trying to find the "PropertyAddress" which has the same "ParcelID" with the null "PropertyAddress" 
-- We found 30 data, but 1 duplicate

Select  A.[UniqueID ], A.[PropertyAddress], A.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM (SELECT [UniqueID ], ParcelID, PropertyAddress
FROM DataCleaningProject..HouseSales
WHERE PropertyAddress is null) A
JOIn DataCleaningProject..HouseSales B
	on A.ParcelID = B.ParcelID
WHERE B.PropertyAddress is not null

-- Now we have to compare (the null data) and (the "PropertyAddress" which has the same "ParcelID" with the null "PropertyAddress"). only to make sure all null data can be fill with the new address

Select *
from (SELECT [UniqueID ], ParcelID, PropertyAddress
FROM DataCleaningProject..HouseSales
WHERE PropertyAddress is null) A
Full outer JOIn (Select DISTINCT A.[UniqueID ], A.ParcelID, B.PropertyAddress
		from (SELECT [UniqueID ], ParcelID, PropertyAddress
		FROM DataCleaningProject..HouseSales
		WHERE PropertyAddress is null) A
		JOIn DataCleaningProject..HouseSales B
			on A.ParcelID = B.ParcelID
		WHERE B.PropertyAddress is not null
		GROUP BY A.[UniqueID ], A.ParcelID, B.PropertyAddress) B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] = B. [UniqueID ]

-- Finally, after comparing, Update the null data with the comparing

UPDATE A
SET PropertyAddress = B.PropertyAddress
FROM (SELECT [UniqueID ], ParcelID, PropertyAddress
FROM DataCleaningProject..HouseSales
WHERE PropertyAddress is null) A
JOIn DataCleaningProject..HouseSales B
	on A.ParcelID = B.ParcelID
WHERE B.PropertyAddress is not null

-- Breaking out address into individual Columns (Address, City, State)

-- We need to look at the data first, what is the data format?

SELECT PropertyAddress
FROM DataCleaningProject..HouseSales

-- We see the data is formatted "Address, City"
-- Now, its time to seperate it with "SUBSTRING"
-- SUBSTRING function work like SUBSTRING(ColumnName, string positing where you want to start the substring, how many string that you want to take(this can be unlimited))
-- The code below use CHARINDEX and LEN fucntion to help SUBSTRING function
-- These codes returns a int, like CHARINDEX return the position of the "," and LEN to calculate how many the string lenght

Select PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
Substring(PropertyAddress, Charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from DataCleaningProject..HouseSales

-- After the seperation, its time to add new column to the table

ALTER TABLE HouseSales
Add Address nvarchar(255);
ALTER TABLE HouseSales
Add City nvarchar(255);

-- And then, update the data in the new column

UPDATE HouseSales
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
UPDATE HouseSales
SET City = Substring(PropertyAddress, Charindex(',', PropertyAddress)+1, LEN(PropertyAddress))

--- Next, we going to find the State. It's in the OwnerAddress data
-- Instead using function "SUBSTRING", you can use "PARSENAME" to separate words by "." (dot).
-- Here the example of using "PARSENAME"

Select OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 1)
FROM DataCleaningProject..HouseSales
where OwnerAddress is not null

-- After we found the State, we can add new column and update it.

ALTER TABLE HouseSales
Add State nvarchar(255);

UPDATE HouseSales
SET State = PARSENAME(REPLACE(OwnerAddress, ', ', '.'), 1)

--- Change Y and N to Yes and No in "Sold as Vacant" field
-- Lets see the data where SoldAsVacant states 'N' or 'Y'.

Select Distinct(SoldAsVacant)
FROM HouseSales

Select SoldAsVacant,
CASE	when SoldAsVacant = 'Y' then 'Yes' 
		when SoldAsVacant = 'N' then 'No' 
		Else SoldAsVacant 
		END
From HouseSales

Select SoldAsVacant, REPLACE(SoldAsVacant, 'N', 'No'), REPLACE(SoldAsVacant, 'Y', 'Yes')
FROM DataCleaningProject..HouseSales
where SoldAsVacant like 'N' or SoldAsVacant like 'Y'

-- After we found some datas that states 'N' or 'Y'
-- We update the data by using REPLACE or else.

UPDATE HouseSales
SET SoldAsVacant = REPLACE(SoldAsVacant, 'N', 'No')
WHERE SoldAsVacant like 'N'

UPDATE HouseSales
SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant like 'Y'
--where UniqueID like '31123'

update HouseSales
Set SoldAsVacant = CASE	when SoldAsVacant = 'Y' then 'Yes' 
		when SoldAsVacant = 'N' then 'No' 
		Else SoldAsVacant 
		END

--- Remove Duplicates
-- Let's find data that duplicated
-- To find duplicated data, we can use ROW_NUMBER() function.
-- In ROW_NUMBER() function, it's state the row number of a data of the same datas. Also in ROW_NUMBER() function, we can use the variable
-- which we want to use as a key of duplicate

-- example of using ROW_NUMBER() function
SELECT *, ROW_NUMBER() over (PARTITION BY PropertyAddress order by UniqueID) as row
From HouseSales
-- Like the example above, the key of duplicate is PropertyAddress

-- In this querry we going to find the duplicate data that has the same ParcelID, PropertyAddress, SaleDate, SalePrice, and LegalReference
SELECT *, ROW_NUMBER() over (PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference order by UniqueID) as row_num
From HouseSales
--where row_num > 1
-- In the querry above, you'll see the "where" function that's error. This because "where" function is only works with the existing column (row_num) is not existing column.
-- So we can use subquerry.
Select *
FROM (SELECT *, ROW_NUMBER() over (PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference order by UniqueID)  row_num
From HouseSales) a
where a.row_num > 1
order by PropertyAddress
-- or we can use CTE
with CTE_DuplicateData as
(SELECT *, ROW_NUMBER() over (PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference order by UniqueID) row_num
From HouseSales)
select *
FROM CTE_DuplicateData
where row_num > 1
-- After we found the duplicate datas, we delete the data from the table.
with CTE_DuplicateData as
(SELECT *, ROW_NUMBER() over (PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference order by UniqueID) row_num
From HouseSales)
Delete
FROM CTE_DuplicateData
where row_num > 1
-- We only can delete datas with CTE, but subquerry (from)

--- Delete Unused Column
-- We already have so many columns in the table
-- There are columns that not useful for this data. Like SaleDate, PropertyAddress, OwnerAddress, and TaxDistrict.
-- These data unused because we already proces the data into the new one.

Select *
FRom HouseSales

-- After we select column that not used and want to be deleted. We delete those by using function DROP COLUMN

Alter Table DataCleaningProject..HouseSales
DROP COLUMN SaleDate