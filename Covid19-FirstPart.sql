-- Select Data
SELECT * 
FROM CovidDeaths cd 
order by 3,4

-- Select Data that we are going to use
SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths cd 
order by 1,2

-- looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases,  total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float))*100 as DeathPrecentage  
FROM CovidDeaths cd 
WHERE location like '%states%'
-- AND continent IS NOT NULL 
order by 1,2

-- looking at total cases vs population
-- Shows what precentage of population got covid over the years
SELECT Location, date, total_cases, population, (CAST(total_cases AS float) / CAST(population AS float))*100 as PopulationInfectedPrecentage  
FROM CovidDeaths cd 
WHERE location like '%states%'
-- AND continent IS NOT NULL 
order by 1,2

-- Looking at Countries with highest Infection Rate compared to population
SELECT Location, population, MAX(CAST(total_cases AS float)) AS HighestInfectionCount, MAX((CAST(total_cases AS float) / CAST(population AS float))*100) as PopulationInfectedPrecentage
FROM CovidDeaths cd 
-- WHERE location like '%states%'
-- AND continent IS NOT NULL
GROUP BY Location, population
order by PopulationInfectedPrecentage DESC 

-- Showing continents with the highest death count per population
SELECT continent, population, MAX(CAST(total_deaths AS float)) AS HighestDeathsCount
FROM CovidDeaths cd 
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
order by HighestDeathsCount DESC 

-- Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(CAST(total_deaths AS float)) / SUM(CAST(total_cases AS float)))*100 as DeathPrecentage
FROM CovidDeaths cd 
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date 
order by 1,2



-- Looking at total population vs vaccination
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS INTEGER)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date 
WHERE cd.continent IS NOT NULL AND cd.continent <> '' 
-- ORDER BY 2,3
)
SELECT *, (CAST(RollingPeopleVaccinated AS float)/CAST(population AS float))*100
FROM PopvsVac

-- Create TEMP TABLE

CREATE TEMPORARY TABLE IF NOT EXISTS PercentPopulationVaccinated (
  Continent VARCHAR(255),
  Location VARCHAR(255),
  Date DATETIME,
  Population NUMERIC,
  New_Vaccinated NUMERIC,
  RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS INTEGER)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date 
-- WHERE cd.continent IS NOT NULL AND cd.continent <> '' 

SELECT *, (CAST(RollingPeopleVaccinated AS float)/CAST(population AS float))*100
FROM PercentPopulationVaccinated



-- Creating View to Store data for later visualization:
Create View PercentPopulationVaccinated as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS INTEGER)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date 
WHERE cd.continent IS NOT NULL AND cd.continent <> '' 
-- order by 2, 3


SELECT *
FROM PercentPopulationVaccinated 