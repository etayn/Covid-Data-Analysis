/* Data Exploration

skills used: CTE's, windows functions, aggregate functions, converting data types

*/

--Total world numbers

select max(total_cases) as TotalCases ,max(cast(total_deaths as int)) as TotalDeaths,
round(max(cast(total_deaths as int))/max(total_cases) * 100,2) as TotalDeathRate
from CovidDeaths
where location = 'World'

-- Average death rate per country
-- Shows likelihoood of dying if you contract the virus in each country

select location as Country ,  avg(cast(total_deaths as int)/total_cases) * 100 as AverageDeathRate
from CovidDeaths
where continent is not null
group by location
order by AverageDeathRate desc


-- Total Percentage of the population that got infected
-- Shows likelihood of getting infected per country

select location,population , max(total_cases) as TotalInfections ,
	   max(total_cases/population) * 100 as PopulationInfectedRate
from CovidDeaths
where continent is not null
group by location,population
order by PopulationInfectedRate desc


-- Total Percentage of the population that died
-- Shows likelihood of dying per country

select location, population,max(cast(total_deaths as int)) as TotalDeaths,
	   max(cast(total_deaths as int)/population) * 100 as PopulationDeathRate
from CovidDeaths
where continent is not null
group by location , population
order by PopulationDeathRate desc


-- Relationship between number of hospital beds and new daily deaths
-- Does higher number of beds affect the death rate

select location, avg(new_cases) as AverageDailyCases ,avg(cast(new_deaths as int)) as AverageDailyDeaths, avg(hospital_beds_per_thousand) as NumberHospitalBeds
from CovidDeaths
where continent is not null 
group by location
having (avg(cast(new_deaths as int))) is not null and (avg(hospital_beds_per_thousand)) is not null
order by 2 desc, 3 desc


-- Relationshio between median age and average death rate per country

select location , median_age,  avg(cast(total_deaths as int)/ total_cases) * 100 as AverageDeathRate 
from CovidDeaths
where continent is not null
group by location, median_age
having (avg(cast(total_deaths as int)/ total_cases) * 100) is not null and median_age is not null
order by median_age desc,AverageDeathRate desc

-- Order of Infected countries
-- Shows the first date which each country had the first infected, and how many countries got the first
-- infected for each day

with first_infections as (
select distinct(location) as Country,
FIRST_VALUE(date) over(partition by location order by date) as DateFirstInfected
from CovidDeaths
where continent is not null and new_cases > 0
) select Country, DateFirstInfected, count(*) over(partition by DateFirstInfected) as NumberOfCountries 
from first_infections
order by DateFirstInfected


-- Average daily tests per country

select location , avg(cast(new_tests as int)) as AverageDailyTests
from CovidDeaths
where continent is not null
group by location
order by 2 desc


-- Lets focus on vaccinations

-- Date of first vaccination per country

select distinct(location) , FIRST_VALUE(date) over (partition by location order by date) as DateFirstVaccination
from CovidDeaths
where cast(new_vaccinations as int) > 0 and continent is not null
order by DateFirstVaccination


-- Vaccination rate for population per country

select location, population , max(cast(people_fully_vaccinated as int)) as TotalVaccinated ,
	   max(cast(people_fully_vaccinated as int)/population)*100 as VaccinationRate
from CovidDeaths
where continent is not null 
group by location, population
order by VaccinationRate desc


-- Total Cases and Deaths timeseries for world

select date, sum(new_cases) over (order by date) as TotalCases , sum(cast(new_deaths as int)) over(order by date) as TotalDeaths
from CovidDeaths
where location = 'World'