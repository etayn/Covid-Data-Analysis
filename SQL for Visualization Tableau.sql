/*
Queries for tableau visualizations
*/


-- Date for first infected per country

with first_infections as (
select distinct(location) as Country,
FIRST_VALUE(date) over(partition by location order by date) as DateFirstInfected
from CovidDeaths
where continent is not null and new_cases > 0
) select Country, DateFirstInfected, count(*) over(partition by DateFirstInfected) as NumberOfCountries
from first_infections
order by DateFirstInfected

-- Percentage of cases and deaths out of total per continent

with world_numbers as (
select location , max(total_cases) as TotalCases , max(cast(total_deaths as float)) as TotalDeaths
from CovidDeaths
where continent is null and location not in ('World','International')
group by location
) select location , round(TotalCases / (select sum(TotalCases) from world_numbers) * 100,2) as CasesPercentage,
		 round(TotalDeaths / (select sum(TotalDeaths) from world_numbers) * 100,2) as DeathsPercentage
from world_numbers

-- World Numbers

select max(total_cases) as TotalCases ,max(cast(total_deaths as int)) as TotalDeaths,
round(max(cast(total_deaths as int))/max(total_cases) * 100,2) as TotalDeathRate
from CovidDeaths
where location = 'World'

--Numbers per country

select location , max(total_cases) as TotalCases , max(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null
group by location
having max(total_cases) is not null and max(cast(total_deaths as int)) is not null
order by location


--Population vaccination rate per country

select location, population , max(cast(people_fully_vaccinated as int)) as TotalVaccinated ,
	   max(cast(people_fully_vaccinated as int)/population)*100 as VaccinationRate
from CovidDeaths
where continent is not null 
group by location, population
order by VaccinationRate desc


-- Time series for deaths and cases for world

select date, total_cases , total_deaths
from CovidDeaths
where location = 'World'
order by date