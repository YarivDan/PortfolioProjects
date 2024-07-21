

/*

Introduction:

Data cleaning plays a major rule in any project of data analysis.
fixing inaccuracies, inconsistencies, and errors, are all actions that ensure data integrity & reliablety. 
In the current project, I will use data-cleaning techniques in datase titled "Nashville_Housing_Data_for_Cleaning". 


Skills that been used:  

Joins, CTE's, Temporay Tables, Windows Functions, Aggregate Functions, String function, Converting Data Types, Data Manipulation Operations.  

Note: 

In this project, i've used Data Manipulation Operations (DMO) such as: "UPDATE", "DELETE", "ALTER TABLE" and more.
It was for the sake of learning and practice. 
	
*/



---------------------------------------------------------------------- Part 1: Standardize date format in column "SaleDate" ---------------------------------------------------------------------- 



/*

Task description:

The values in column "SaleDate", are represented in "DATETIME" format.
All values been converted to "DATE" format.  
It's been done to demonstrate skills and abilities.  

*/



-- Stage 1-> Creating new column for upcoming updates.

ALTER TABLE Nashville_Housing_Data_for_Cleaning

ADD SaleDateConverted DATE



-- Stage 2-> Converting permanently data type from "DATATIME" to "DATE", in column "SaleDateConverted".

UPDATE Nashville_Housing_Data_for_Cleaning

SET SaleDateConverted = CAST(SaleDate AS DATE) 



-- Stage 3-> Testing if changes that being done, matching the desired results.
-----------> Querying data in format "DATETIME", expecting for values in "DATE" data type.

SELECT SaleDateConverted  

FROM Nashville_Housing_Data_for_Cleaning



---------------------------------------------------------------------- Part 2: Populate null values in column "PropertyAddress" ---------------------------------------------------------------------- 



/*

Task description:

In column "PropertyAddress", there are 29 null values.
Incomplete inforamation can be misleading for readers. 
To properly process and analyze data, it's essential complete missing values.

*/



-- Stage 1-> Looking for null values in column "PropertyAddress".

SELECT COUNT(*)

FROM Nashville_Housing_Data_for_Cleaning

WHERE PropertyAddress IS NULL



-- Stage 2-> Replace null values in column "PropertyAddress", with populated ones.
-----------> In column "PropertyAddress", idententical values have common "ParcelID" serial number.
-----------> In column "PropertyAddress", i've matched null values with populated ones. it's been done by using "Self-Join" procedure.

SELECT
	 a.ParcelID,
	 a.PropertyAddress,
	 b.ParcelID, 
     b.PropertyAddress, 
     ISNULL(a.PropertyAddress, b.PropertyAddress)
	 

FROM Nashville_Housing_Data_for_Cleaning AS a

JOIN Nashville_Housing_Data_for_Cleaning AS b 
	 ON a.ParcelID = b.ParcelID

WHERE
	a.PropertyAddress IS NULL 
	AND a.UniqueID <> b.UniqueID
    


-- Stage 3-> Populate permanently, null values in "PropertyAddress" column.

UPDATE a

SET PropertyAddress
	= ISNULL(a.PropertyAddress, b.PropertyAddress)

FROM Nashville_Housing_Data_for_Cleaning AS a

JOIN Nashville_Housing_Data_for_Cleaning AS b 
	 ON a.ParcelID = b.ParcelID

WHERE a.[PropertyAddress] IS NULL 
	  AND a.UniqueID <> b.UniqueID 



-- Stage 4-> Testing if the changes that being done, matching the desired results.
-----------> Looking for null values in column "PropertyAddress",  expecting for empty columns.

SELECT COUNT(*)

FROM Nashville_Housing_Data_for_Cleaning

WHERE PropertyAddress IS NULL



---------------------------------------------------------------------- Part 3: Braking down column "PropertyAddress" to substrings ---------------------------------------------------------------------- 



/*

Task description:

In column "PropertyAddress", there are two substrings (Adress, city), concatenated to one piece.
Querying each substring individually, requires breaking down the whole string to it's components.

*/



-- Stage 1-> Split column "PropertyAddress", into two individual pieces (Address, City).
-----------> Using "String" function, to split column's name with delimiter separator.
-----------> In this case, the string function also removes the comma delimiter.

SELECT  
	 PropertyAddress, 
	 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS PropertySplitAddress, 
	 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropertySplitCity

FROM Nashville_Housing_Data_for_Cleaning



-- Stage 2-> Creating two new columns for later updates: "PropertySplitAddress" & "PropertySplitCity".
-----------> Later, I will delete the unused column "PropertyAddress". 

ALTER TABLE Nashville_Housing_Data_for_Cleaning

ADD PropertySplitAddress NVARCHAR (255),
ADD PropertySplitCity NVARCHAR (255)



-- Stage 3-> Populate data in columns: "PropertySplitAddress" & "PropertySplitCity".

UPDATE Nashville_Housing_Data_for_Cleaning

SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



-- Stage 4-> Testing if the changes that being done, matching the desired results
-----------> Expecting for substrings without delimiters.

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity

FROM Nashville_Housing_Data_for_Cleaning



---------------------------------------------------------------------- Part 4: Braking down column "OwnerAddress" to substrings ---------------------------------------------------------------------- 



/*

Task description:

In column "OwnerAddress", there are three substrings (Adress, city, state), concatenated to one piece.
Querying each substring individually, requires breaking down the whole string to it's components.

*/



-- Stage 1-> Split column "OwnerAddress", into three individual components (Adress, city, state).
-----------> Using "String" function, to repalce and separate delimiters.
-----------> Replace old delimiter (",") with new one (".").

SELECT 
	 OwnerAddress,
	 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
	 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
	 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState

FROM Nashville_Housing_Data_for_Cleaning

WHERE [OwnerAddress] IS NOT NULL



-- Stage 2-> Creating three new columns for later updates: "OwnerSplitAddress", "OwnerSplitCity", "OwnerSplitState".

ALTER TABLE Nashville_Housing_Data_for_Cleaning

ADD OwnerSplitAddress NVARCHAR(255),
ADD OwnerSplitCity NVARCHAR(255),
ADD OwnerSplitState NVARCHAR(255)



-- Stage 3-> Populate data in columns: "OwnerSplitAddress", "OwnerSplitCity", "OwnerSplitState".

UPDATE Nashville_Housing_Data_for_Cleaning

SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 



-- Stage 4-> Testing if the changes that being done, matching the desired results
-----------> Expecting for substrings without delimiters.

SELECT 
	 OwnerAddress, 
	 OwnerSplitAddress, 
	 OwnerSplitCity, 
	 OwnerSplitState

FROM Nashville_Housing_Data_for_Cleaning



---------------------------------------------------------------------- Part 5: Convert values in column "SoldAsVacant" ---------------------------------------------------------------------- 



/*

Task description:

The number of assests that been sold as "Vacant" (i.e., free of any occupants),
represented in column "SoldAsVacant". Desired values are: "Yes" and "No". 
the query ensure there are no additional values, other than the desired ones.

*/



-- Stage 1-> Looking for distinct values, other than "Yes" & "No".

SELECT 
	 DISTINCT(SoldAsVacant) AS Distinct_Values, 
	 COUNT(SoldAsVacant) AS Values_Count

FROM  Nashville_Housing_Data_for_Cleaning

GROUP BY SoldAsVacant



-- Stage 2-> Using "CASE-WHEN" function, to convert "Y" to "Yes" and "N" to "No".

SELECT 
	 SoldAsVacant,
	 CASE 
		 WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	     ELSE SoldAsVacant
	 END 

FROM Nashville_Housing_Data_for_Cleaning
 


-- Stage 3-> Change permanently values in column "SoldAsVacant".


UPDATE Nashville_Housing_Data_for_Cleaning

SET 
  SoldAsVacant =   
  CASE 
	  WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
  END 



-- Stage 4-> Testing if the changes that being done, matching the desired results.
-----------> Expecting for only two values in column "SoldAsVacant": "Yes" & "No".

SELECT 
	 DISTINCT(SoldAsVacant) AS Distinct_Values, 
	 COUNT(SoldAsVacant) AS Values_Count

FROM Nashville_Housing_Data_for_Cleaning

GROUP BY SoldAsVacant



---------------------------------------------------------------------- Part 6: Find and remove duplicate values ---------------------------------------------------------------------- 



/*

Task description: 

Presence of duplicate values in data storage, can cause three main problems: 

1. increasing storage requirements.
2. Leading to inaccurate data analysis.
3. creating inconsistent results. 

Remove duplicate values is essential for maintaining data integrity, improving performance, and ensuring data consistency.

*/



-- Stage 1-> Find duplicates by Using window function 
-----------> Group by identical values, indicates for duplications.


SELECT *, 
	 ROW_NUMBER () 
	 OVER (PARTITION BY
		   ParcelID,
		   PropertyAddress,
		   SaleDate,
		   SalePrice, 
		   LegalReference
	 ORDER BY (UniqueID ) AS RowNum

FROM Nashville_Housing_Data_for_Cleaning



-- Stage 2-> Creating Common Table Expession (CTE).
-----------> If a certain value in column "RowNum" is greater than "1" , it means the value has duplications.

WITH DuplicateValues AS
(
SELECT *, 
	 ROW_NUMBER () 
	 OVER (PARTITION BY
		   ParcelID,
		   PropertyAddress,
		   SaleDate,
		   SalePrice, 
		   LegalReference
	 ORDER BY (UniqueID) AS RowNum

FROM Nashville_Housing_Data_for_Cleaning
)

SELECT *

FROM DuplicateValues

WHERE RowNum > 1

ORDER BY PropertyAddress



-- Stage 3-> Delete duplicate values.
-----------> "ORDER BY" clause has no meaning, when appears in CTE's parentheses.

WITH DuplicateValues AS
(
SELECT *, 
	 ROW_NUMBER () 
	 OVER (PARTITION BY
		   ParcelID,
		   PropertyAddress,
		   SaleDate,
		   SalePrice, 
		   LegalReference
	 ORDER BY (UniqueID) AS RowNum
FROM Nashville_Housing_Data_for_Cleaning
)

DELETE

FROM  DuplicateValues

WHERE RowNum > 1



-- Stage 4 -> Testing if the changes that being done, matching the desired results 
------------> Looking for values greater than "1" in column "RowNum", expecting for nulls.

WITH DuplicatesValues AS
(
SELECT *, 
	 ROW_NUMBER () 
	 OVER (PARTITION BY
		   ParcelID,
		   PropertyAddress,
		   SaleDate,
		   SalePrice, 
		   LegalReference
	 ORDER BY (UniqueID) AS RowNum
FROM Nashville_Housing_Data_for_Cleaning
)

SELECT *
FROM  DuplicatesValues
WHERE RowNum > 1



---------------------------------------------------------------------- Part 8: Delete unused columns ---------------------------------------------------------------------- 



/*

Task description:

Columns "PropertyAddress" & "OwnerAddress", broke down to substrings.
Column "SaleDate" been converted to another format. it's data displayed in column "SaleDateConverted".
Data in column "TaxDistrict" is irrelevant,.
All four columns mentioned, are irrelevant and need to be deleted.

*/



-- Stage 1-> Delete unused columns.

ALTER TABLE Nashville_Housing_Data_for_Cleaning
DROP COLUMN 
		  PropertyAddress, 
		  SaleDate, 
		  OwnerAddress, 
		  TaxDistrict



-- Stage 2-> Looking after columns that been deleted, expecting for error notification: "Invalid object".

SELECT 
	 PropertyAddress, 
	 SaleDate, 
     OwnerAddress, 
     TaxDistrict

FROM Nashville_Housing_Data_for_Cleaning



---------------------------------------------------------------------- End ----------------------------------------------------------------------

