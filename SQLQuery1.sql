/****** Script for SelectTopNRows command from SSMS  ******/
select * from [SQL tutotial].dbo.house 

-----------------------------------------------------------------------------------------
-- Standardize date format

select SaleDateConverted 
from [SQL tutotial].dbo.house


alter table house
add SaleDateConverted date 

update house
set SaleDateConverted = convert(Date , SaleDate)

Update house 
set SaleDate = SaleDateConverted
 

------------------------------------------------------------------------------------------
-- Populate Property Address data
select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress ,isnull(b.PropertyAddress , a.PropertyAddress)
from dbo.house a
join dbo.house b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where b.PropertyAddress is null

update b
set b.PropertyAddress = isnull(b.PropertyAddress , a.PropertyAddress)
from dbo.house a
join dbo.house b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where b.PropertyAddress is null

select count  (ParcelID) as count_of_null from dbo.house where  PropertyAddress is null

select ParcelID,LandValue,BuildingValue, TotalValue, YearBuilt , Bedrooms, FullBath, HalfBath 
from dbo.house order by ParcelID 
 

-----------------------------------------------------------------------------------------
-- Seperate PropertyAddress into 2 columns and OwnerAddress into 3
 select SUBSTRING (PropertyAddress, 1 , CHARINDEX(',',PropertyAddress, 1) - 1 ) as StreetName ,
	    SUBSTRING (PropertyAddress,  CHARINDEX(',',PropertyAddress, 1) + 1 , LEN(PropertyAddress)) as City
 from dbo.house


 alter table dbo.house
 add StreetName varchar(200)

 update dbo.house
 set StreetName = SUBSTRING (PropertyAddress, 1 , CHARINDEX(',',PropertyAddress, 1) - 1 )

 alter table dbo.house
 add City varchar(200)

 update dbo.house
 set City  = SUBSTRING (PropertyAddress,  CHARINDEX(',',PropertyAddress, 1) + 1 , LEN(PropertyAddress))
 Select StreetName , City from dbo.house


 
 select 
 Parsename(replace(OwnerAddress, ',' ,'.' ),3) as  a  ,
 Parsename(replace(OwnerAddress, ',' ,'.' ),2) as  b  ,
 Parsename(replace(OwnerAddress, ',' ,'.' ),1) as  c
 from dbo.house order by a DESC
 
 alter table dbo.house
 add OwnerStreet varchar(30)

 update house
 set OwnerStreet = Parsename(replace(OwnerAddress, ',' ,'.' ),3)

  alter table dbo.house
 add OwnerCity  varchar(30)

 update house
 set OwnerCity = Parsename(replace(OwnerAddress, ',' ,'.' ),2)

 alter table dbo.house
 add OwnerState  varchar(30)

 update house
 set OwnerState = Parsename(replace(OwnerAddress, ',' ,'.' ),1)

 select OwnerStreet,OwnerCity, OwnerState from dbo.house order by OwnerStreet DESC
 

 ---------------------------------------------------------------------------------------
 --Change Y/N to Yes/NO in SoldAsVacant
  select distinct(SoldAsVacant), count(SoldAsVacant)
  from dbo.house
  group by SoldAsVacant 
  order by SoldAsVacant

 select SoldAsVacant,
	CASE WHEN SoldAsVacant =  'Y' then 'Yes' 
		 When  SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
	end as SoldAsVacant01
from dbo.house
where SoldAsVacant = 'N' or SoldAsVacant = 'Y'

update house
set SoldAsVacant = Case  WHEN SoldAsVacant =  'Y' then 'Yes' 
		 When  SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		end


-----------------------------------------------------------------------------
--Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From dbo.house
--order by ParcelID
)
delete 
from RowNumCTE
where row_num > 1 


-----------------------------------------------------------------------------
--delete column unnessecery

select * from dbo.house
alter table dbo.house
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate