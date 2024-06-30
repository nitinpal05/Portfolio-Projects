
--Cleaning data in SQL Queries

select * 
FROM [Portfolio_project].[dbo].[Housing_data]


----------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

select saledate,convert(date,saledate)
FROM [Portfolio_project].[dbo].[Housing_data]

update [Housing_data]
set saledate=convert(date,saledate)

Alter table [Housing_data]
add SaleDateConverted date;

update [Housing_data]
set SaleDateConverted=convert(date,saleDate)


----------------------------------------------------------------------------------------------------------------
-- Identifying Null Values
select *
FROM [Portfolio_project].[dbo].[Housing_data]
	where PropertyAddress is null


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio_project].[dbo].[Housing_data] a
join  [Portfolio_project].[dbo].[Housing_data] b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ] <>b.[UniqueID ]
	where a.PropertyAddress is null



Update a
	set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM [Portfolio_project].[dbo].[Housing_data] a
	join [Portfolio_project].[dbo].[Housing_data] b
		on a.parcelid=b.parcelid and a.[UniqueID ]<>b.[UniqueID ]
		where a.PropertyAddress is null



-----------------------------------------------------------------------------------------------------------------
-- Breaking out into individual columns

select PropertyAddress
FROM [Portfolio_project].[dbo].[Housing_data]


select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 ,LEN(PropertyAddress)) as ADDRESS
FROM [Portfolio_project].[dbo].[Housing_data]


alter table [Housing_data]
add propertysplitaddress Nvarchar(255);

update [Housing_data]
set propertysplitaddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) 


alter table [Housing_data]
add propertysplitcity Nvarchar(255);


update [Housing_data]
set propertysplitcity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 ,LEN(PropertyAddress)) 


select OwnerAddress
FROM [Portfolio_project].[dbo].[Housing_data]


select 
PARSENAME(replace(owneraddress,',','.'),3) 
,PARSENAME(replace(owneraddress,',','.'),2)
,PARSENAME(replace(owneraddress,',','.'),1)
FROM [Portfolio_project].[dbo].[Housing_data]


alter table [Housing_data]
add ownersplitaddress Nvarchar(255);

update [Housing_data]
set ownersplitaddress=PARSENAME(replace(owneraddress,',','.'),3) 


alter table [Housing_data]
add ownersplitcity Nvarchar(255);


update [Housing_data]
set ownersplitcity=PARSENAME(replace(owneraddress,',','.'),2) 


alter table [Housing_data]
add ownersplitcode Nvarchar(255);


update [Housing_data]
set ownersplitcode=PARSENAME(replace(owneraddress,',','.'),1) 


select distinct (SoldAsVacant),count(soldasvacant)
from Housing_data
	group by SoldAsVacant
	order by 2



select soldasvacant,
case
	when soldasvacant='Y' then 'YES'
	when soldasvacant='N' then 'NO'
	else soldasvacant 
	end
	from Housing_data


update Housing_data
set SoldAsVacant= case 
	when soldasvacant='Y' then 'YES'
	when soldasvacant='N' then 'NO'
	else soldasvacant 
	end




--------------------------------------------------------------------------------------------------
--Remove duplicates
	with dup as(
		select *,
		ROW_NUMBER() over(partition by ParcelId,PropertyAddress,salePrice,saleDate,LegalReference 
		order by uniqueId) as row_num
		from Housing_data)

	select *
	from dup
	where row_num>1





------------------------------------------------------------------------------------------------------------------
-- Delete Unused column

select * from Housing_data



alter table housing_data
drop column ownerAddress,Taxdistrict,PropertyAddress


Alter table housing_data
drop column saledate