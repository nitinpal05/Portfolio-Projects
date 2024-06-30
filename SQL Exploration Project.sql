--SELECT *
--  FROM [Portfolio_project].[dbo].[covid-vacination$]
--  order by 3,4

  SELECT *
  FROM [Portfolio_project].[dbo].[Covid_Deaths$]
  where continent is not null
  order by 3,4

  select [location] ,[date],[total_cases],[new_cases],[total_deaths],[population]
  FROM [Portfolio_project].[dbo].[Covid_Deaths$]
  order by 1,2




	--Looking at Total cases vs Total Deaths

      select [location] ,[date],[total_cases],[total_deaths],
     ((cast(total_deaths as float))/ cast(total_cases as float))*100 as Death_Percentage
      FROM [Portfolio_project].[dbo].[Covid_Deaths$]
      where location like '%states%'
      order by 1,2




	  --Total Cases vs Population

     select [location] ,[date],[total_cases],[new_cases],[population],
     (total_deaths/population) *100 as Death_percentage
     FROM [Portfolio_project].[dbo].[Covid_Deaths$]
     order by 1,2




	--Count of active cases by Date
	--shows increased covid cases per day

  select [location] ,[date], sum([new_cases]) 
  over(Partition by Location order by date rows between unbounded preceding and current row ) as Running_activecases
  FROM [Portfolio_project].[dbo].[Covid_Deaths$]


 
 --countries with highest cases

  select [location],[population],max(total_cases) as max_cases
  FROM [Portfolio_project].[dbo].[Covid_Deaths$]
  group by [location],[population]
  order by 1,2



  --Percentage of Population affected by covid

   select [location],[population], MAX(cast(total_cases as int)) as highesinfectioncount ,
   MAX((cast(total_cases as int)/population))*100 as affected_population
   FROM [Portfolio_project].[dbo].[Covid_Deaths$]
  --where location like 'I%A'
   group by [location],[population]
   order by affected_population desc




 -- Countries with Highest Death Count Per Population

  select [location],[population], MAX(cast(total_deaths as int)) as HighesDeathCount 
  -- MAX((cast(total_deaths as int)/population))*100 as affected_population
  FROM [Portfolio_project].[dbo].[Covid_Deaths$]
  --where location like 'I%A'
  where continent is not null
  group by [location],[population]
  order by HighesDeathCount desc




 -- Death count by continent

 select [location], MAX(cast(total_deaths as int)) as HighesDeathCount 
 FROM [Portfolio_project].[dbo].[Covid_Deaths$]
 where continent is null
 group by [location]
 order by HighesDeathCount desc




 --continent with Highest Death Count Per Population

      select continent, MAX(cast(total_deaths as int)) as HighesDeathCount 
      FROM [Portfolio_project].[dbo].[Covid_Deaths$]
      where continent is not null
      group by continent
      order by HighesDeathCount desc




 --Global Numbers

        select sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,
	sum(new_deaths)/sum(new_cases) *100 as Death_percentage
        FROM [Portfolio_project].[dbo].[Covid_Deaths$]
	where continent is not null
	order by 1,2





	--using both tables covid deaths and vaccination

	--looking at total population vs vaccination

	select d.continent,d.location,d.date,d.population,v.new_vaccinations
	from Portfolio_project..Covid_Deaths$ d
	join Portfolio_project..[covid-vacination$] v
	on d.date=v.date 
	and d.location=v.location
	where d.continent is not null
	--group by d.continent,d.location,d.date,d.population,v.new_vaccinations
	order by 2,3





	--new vaccination per day

	select d.continent,d.location,d.date,d.population,v.new_vaccinations,
	sum(convert(bigint,v.new_vaccinations )) over(partition by d.location 
	order by d.date , d.location)  as Rolling_PeopleVaccinated
	from Portfolio_project..Covid_Deaths$ d
	join Portfolio_project..[covid-vacination$] v
	on d.date=v.date 
	and d.location=v.location
	where d.continent is not null --and d.location like 'a%a'
	--group by d.continent,d.location,d.date,d.population,v.new_vaccinations
	order by 2,3




	--Total Population vs vaccination 
	--1.using the common table expression(cte's)

	with cte (continent,location,date,population,new_vaccination,Rolling_PeopleVaccinated) as
	(
	select d.continent,d.location,d.date,d.population,v.new_vaccinations,
	sum(convert(bigint,v.new_vaccinations )) over(partition by d.location 
	order by d.date , d.location)  as Rolling_PeopleVaccinated
	--(population/Rolling_PeopleVaccinated)*100 
	from Portfolio_project..Covid_Deaths$ d
	join Portfolio_project..[covid-vacination$] v
	on d.date=v.date 
	and d.location=v.location
	where d.continent is not null --and d.location like 'a%a'
	--group by d.continent,d.location,d.date,d.population,v.new_vaccinations
	--order by 2,3
	)
	select *,(Rolling_PeopleVaccinated/population)*100  as Rolling_vaccination
	from cte


	--2. using the temp_table

	Drop table if exists #PercentPopulationVaccinated 
	create table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population bigint,
	new_vaccinations bigint,
	Rolling_PeopleVaccinated bigint
	)
	insert into #PercentPopulationVaccinated

	select d.continent,d.location,d.date,d.population,v.new_vaccinations,
	sum(convert(bigint,v.new_vaccinations )) over(partition by d.location 
	order by d.date , d.location)  as Rolling_PeopleVaccinated
	--(population/Rolling_PeopleVaccinated)*100 
	from Portfolio_project..Covid_Deaths$ d
	join Portfolio_project..[covid-vacination$] v
	on d.date=v.date 
	and d.location=v.location
	where d.continent is not null --and d.location like 'a%a'
	--group by d.continent,d.location,d.date,d.population,v.new_vaccinations
	--order by 2,3
	
	select *,(Rolling_PeopleVaccinated/population)*100  as Rolling_vaccination
	from #PercentPopulationVaccinated




	--Creating Views For Visualization
	
	create view GlobalNumbers as
	select sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,
	sum(new_deaths)/sum(new_cases) *100 as Death_percentage
        FROM [Portfolio_project].[dbo].[Covid_Deaths$]
	where continent is not null
	--order by 1,2

	select * from GlobalNumbers


	create view PercentPopulationVaccinated as 
        select d.continent,d.location,d.date,d.population,v.new_vaccinations,
	sum(convert(bigint,v.new_vaccinations )) over(partition by d.location 
	order by d.date , d.location)  as Rolling_PeopleVaccinated
	--(population/Rolling_PeopleVaccinated)*100 
	from Portfolio_project..Covid_Deaths$ d
	join Portfolio_project..[covid-vacination$] v
	on d.date=v.date 
	and d.location=v.location
	where d.continent is not null

	select * from PercentPopulationVaccinated







