SELECT *
FROM House_DT

--Changing data type
UPDATE House_DT
SET saledate = convert(DATE, saledate)
FROM House_DT

SELECT saledate
FROM House_DT

--Filling in empty property address
SELECT a.ParcelID
	,b.PropertyAddress
	,a.ParcelID
	,b.PropertyAddress
FROM House_DT a
JOIN House_DT b ON a.parcelid = b.parcelid
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

SELECT *
FROM House_DT a
JOIN House_DT b ON a.parcelid = b.parcelid
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
	AND b.PropertyAddress IS NOT NULL

UPDATE a
SET a.PropertyAddress = b.PropertyAddress
FROM House_DT a
JOIN House_DT b ON a.parcelid = b.parcelid
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
	AND b.PropertyAddress IS NOT NULL

--Check and add columns for address and city
SELECT SUBSTRING(propertyaddress, 1, charindex(',', PropertyAddress) - 1) AS PropertySplitAddress
	,SUBSTRING(propertyaddress, charindex(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropertySplitCity
FROM house_dt

ALTER TABLE house_dt ADD PropertySplitAddress NVARCHAR(255)
	,PropertySplitCity NVARCHAR(255)

UPDATE House_DT
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, charindex(',', PropertyAddress) - 1)
	,PropertySplitCity = SUBSTRING(propertyaddress, charindex(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT TOP 10 *
FROM House_DT

SELECT PARSENAME(replace(OwnerAddress, ',', '.'), 3) AS try
	,PARSENAME(replace(OwnerAddress, ',', '.'), 2) AS try
	,PARSENAME(replace(OwnerAddress, ',', '.'), 1) AS try
FROM House_DT

ALTER TABLE house_dt ADD OwnerSplitAddress NVARCHAR(255)
	,OwnerSplitCity NVARCHAR(255)
	,OwnerSplitState NVARCHAR(255)

UPDATE House_DT
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)
	,OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)
	,OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

--Checking Sold AsVacant column
SELECT DISTINCT soldasvacant
	,count(*)
FROM House_DT
GROUP BY SoldAsVacant

SELECT SoldAsVacant
	,CASE 
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		WHEN SoldAsVacant = 'N'
			THEN 'No'
		ELSE SoldAsVacant
		END
FROM House_DT

UPDATE House_DT
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		WHEN SoldAsVacant = 'N'
			THEN 'No'
		ELSE SoldAsVacant
		END
--Checking duplicates
WITH dup_cte AS (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY parcelid
				,propertyaddress
				,saledate
				,saleprice
				,legalreference ORDER BY uniqueid
				) AS dup
		FROM House_DT
		)

DELETE
FROM dup_cte
WHERE dup > 1
	--order by ParcelID
