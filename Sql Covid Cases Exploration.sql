select *
from CovidDeaths
order by 3,4



--Selecting Data

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Covid Death Percentage

SELECT location, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE total_deaths is not null
ORDER BY 1


--CANADA Covid Cases and Deaths and DeathPercentage

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Canada' and total_deaths is not null
ORDER BY date desc



-- NORTH AMERICA( CANADA and UNITED STATES) CASES 

select continent, location, total_cases, date
FROM CovidDeaths
where continent = 'North America' and location in('Canada', 'United States')


--Overall Cases in the World

SELECT location, MAX(total_cases) AS OverallCases
FROM CovidDeaths
where total_cases is not null
group by location
Order BY 2 desc

-- Highest Cases Rate Comparing to Population(Top 20)

SELECT top 20 location, population, MAX(total_cases) AS OverallhighestCase, MAX((total_cases/population))*100  AS HighestPercent
FROM CovidDeaths
GROUP BY location, population
Order BY 4 desc

--Total_deaths column was varchar, reverted to integar

alter table coviddeaths
alter column total_deaths int


-- Highest Deaths  Comparing to Population(TOP 20)

SELECT top 20 location, population, MAX(total_deaths) AS OverallhighestDeaths
FROM CovidDeaths
where population is not null and total_deaths is not null and continent is not null
group by location, population
Order by 3 desc



-- Highest Deaths Rate Comparing to Population(TOP 20)

SELECT top 20 location, population, MAX(total_deaths) AS OverallhighestDeaths, MAX((total_deaths/population))*100 AS HighestPercent
FROM CovidDeaths
GROUP BY location, population
Order BY 4 desc


--There are continents in location, to remove it

SELECT *
FROM CovidDeaths
Where continent is not null

--NewCases & MinNewCases, alter the column new_cases from float to int with cast

SELECT date, new_cases, MIN(Cast(new_cases as int)) AS MinNewCases
FROM CovidDeaths
where new_cases is not null
Group by date, new_cases
ORDER BY MinNewCases desc

-- Alter the column covdi_deaths from float to int
ALter table coviddeaths
alter column new_cases int


-- Alter the column new_deaths from float to int with alter


Alter table coviddeaths
alter column new_deaths int

-- New Cases and New Deaths in All over the World

SELECT date, SUM(new_cases) as total, SUM(new_deaths) AS newtotal, SUM(new_deaths)/SUM(new_cases)*100 as NewOverallNumbers
FROM CovidDeaths
WHERE continent is not null
group by date
order by 1 desc


-- Overall NewTotalCases and NewtotalDeaths

SELECT  SUM(new_cases) as newtotalcases, SUM(new_deaths) AS newtotaldeaths
FROM CovidDeaths
WHERE continent is not null


--JOIN the two tables(Covid Deaths and Covid Vaccinations) and look Canada's Total Vaccinations

SELECT d.date, d.location, d.population, v.new_vaccinations, v.total_vaccinations, d.total_cases
from CovidDeaths d
JOIN CovidVaccinations  v
On d.location = v.location
and d.date = v.date
WHERE d.location = 'Canada' and v.total_vaccinations is not null



--Total Vaccinations in the Countries

SELECT d.date, d.location, d.population, v.new_vaccinations, v.total_vaccinations, d.total_cases,
MAX(total_vaccinations) OVER (PARTITION by d.location) AS TotalVac
from CovidDeaths d
JOIN CovidVaccinations  v
On d.location = v.location
and d.date = v.date
WHERE d.location is not null and d.continent is not null
ORDER BY 2


-- Total Vaccinations in Canada, and Vac.Rate

SELECT d.date, d.location, d.population, v.new_vaccinations, v.total_vaccinations, d.total_cases,
MAX(total_vaccinations) OVER (PARTITION by d.location) AS TotalVac
from CovidDeaths d
JOIN CovidVaccinations  v
On d.location = v.location
and d.date = v.date
WHERE d.location = 'Canada' and d.location is not null
ORDER BY 2

--Common Table Expression

WITH VacRateCanada (date, location, population, new_vaccinations, total_vaccinations, total_cases, TotalVac)

AS
(SELECT d.date, d.location, d.population, v.new_vaccinations, v.total_vaccinations, d.total_cases,
MAX(total_vaccinations) OVER (PARTITION by d.location) AS TotalVac
from CovidDeaths d
JOIN CovidVaccinations  v
On d.location = v.location
and d.date = v.date
WHERE d.location = 'Canada' and d.location is not null
)
SELECT *, (TotalVac/population)*100 as TotalRate
FROM VacRateCanada


--( This query gives us  how much percent of canadians got vaccinated)



--Temp Table

Create Table #MaxVacCanadians

(
date datetime,
Location nvarchar(255),
population numeric,
new_vaccinations numeric,
total_vaccinations numeric,
total_cases numeric,
TotalVac numeric
)

Insert Into #MaxVacCanadians
SELECT d.date, d.location, d.population, v.new_vaccinations, v.total_vaccinations, d.total_cases,
MAX(total_vaccinations) OVER (PARTITION by d.location) AS TotalVac
from CovidDeaths d
JOIN CovidVaccinations  v
On d.location = v.location
and d.date = v.date
WHERE  d.location= 'Canada' and d.location is not null

SELECT *, (TotalVac/Population)*100 
FROM #MaxVacCanadians

-- To make a change from the Temp Table(I wanna remove the location filter)

DROP Table if exists #MaxVacCanadians

Create Table #MaxVacCanadians

(
date datetime,
Location nvarchar(255),
population numeric,
new_vaccinations numeric,
total_vaccinations numeric,
total_cases numeric,
TotalVac numeric
)

Insert Into #MaxVacCanadians
SELECT d.date, d.location, d.population, v.new_vaccinations, v.total_vaccinations, d.total_cases,
MAX(total_vaccinations) OVER (PARTITION by d.location) AS TotalVac
from CovidDeaths d
JOIN CovidVaccinations  v
On d.location = v.location
and d.date = v.date
WHERE   d.location is not null

SELECT *, (TotalVac/Population)*100 
FROM #MaxVacCanadians


--Creating View for Canada Vac Rate

Create View CanadaPeopleVaccin As
SELECT d.date, d.location, d.population, v.new_vaccinations, v.total_vaccinations, d.total_cases,
MAX(total_vaccinations) OVER (PARTITION by d.location) AS TotalVac
from CovidDeaths d
JOIN CovidVaccinations  v
On d.location = v.location
and d.date = v.date
WHERE d.location = 'Canada' and d.location is not null


--Creating View for All Countries Vac Rate

Create View CountriesPeopleVaccin AS
SELECT d.date, d.location, d.population, v.new_vaccinations, v.total_vaccinations, d.total_cases,
MAX(total_vaccinations) OVER (PARTITION by d.location) AS TotalVac
from CovidDeaths d
JOIN CovidVaccinations  v
On d.location = v.location
and d.date = v.date
WHERE  d.location is not null












