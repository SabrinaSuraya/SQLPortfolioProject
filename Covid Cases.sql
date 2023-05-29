SELECT * 
FROM [Portfolio 1 - COVID Case]..['Covid death$']
ORDER BY 3,4

SELECT * 
FROM [Portfolio 1 - COVID Case]..['Covid Vacine$']
ORDER BY 3,4

-- Alter Table Covid Vaccine total deaths and total cases
ALTER TABLE [Portfolio 1 - Covid Case]..['Covid Vacine$']
ALTER COLUMN total_deaths int

ALTER TABLE [Portfolio 1 - Covid Case]..['Covid Vacine$']
ALTER COLUMN total_cases int


--Data that we used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio 1 - COVID Case]..['Covid Vacine$']
ORDER BY 1,2

-- Total Cases vs Total Deaths (Death Percentage)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio 1 - COVID Case]..['Covid Vacine$']
WHERE location like '%Malaysia%' 
ORDER BY 1,2

-- Total Cases vs Population (Covid PErcentage)
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CovidPercentage
FROM [Portfolio 1 - COVID Case]..['Covid Vacine$']
--WHERE location like '%Malaysia%' 
ORDER BY 1,2


-- Country with Highet Covid Cases per population
SELECT location, population, MAX(total_cases) AS HighestCovidCases, MAX(total_cases/population)*100 AS CovidPercentage
FROM [Portfolio 1 - COVID Case]..['Covid Vacine$']
--WHERE location like '%Malaysia%'
GROUP By location, population
ORDER BY CovidPercentage DESC

--Country with highest Death Per Population
SELECT location, MAX(total_deaths) AS TotalDeaths
FROM [Portfolio 1 - COVID Case]..['Covid Vacine$']
--WHERE location like '%Malaysia%'
WHERE continent IS NOT NULL
GROUP By location
ORDER BY TotalDeaths DESC

--Country with highest Death Per Population by Continent
SELECT continent, MAX(total_deaths) AS TotalDeaths
FROM [Portfolio 1 - COVID Case]..['Covid Vacine$']
--WHERE location like '%Malaysia%'
WHERE continent IS NOT NULL
GROUP By continent
ORDER BY TotalDeaths DESC

--Global number
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeath, (SUM(cast(new_deaths as INT))/SUM(cast(new_cases as INT))*100) AS DeathPercentage
FROM [Portfolio 1 - COVID Case]..['Covid Vacine$']
--WHERE location like '%Malaysia%'
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2

--Total Population vs Vaccinations
SELECT death.continent, death.location, death.date, Vaccine.population, death.new_vaccinations, SUM(CONVERT(int,death.new_vaccinations)) OVER (Partition by Vaccine.location Order by Vaccine.location, Vaccine.date) AS RollingPeopleVaccinated
FROM [Portfolio 1 - COVID Case]..['Covid death$'] death
JOIN [Portfolio 1 - COVID Case]..['Covid Vacine$'] Vaccine
	ON death.location = Vaccine.location
	AND death.date = Vaccine.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopVSVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT death.continent, death.location, death.date, Vaccine.population, death.new_vaccinations, SUM(CONVERT(int,death.new_vaccinations)) OVER (Partition by Vaccine.location Order by Vaccine.location, Vaccine.date) AS RollingPeopleVaccinated
FROM [Portfolio 1 - COVID Case]..['Covid death$'] death
JOIN [Portfolio 1 - COVID Case]..['Covid Vacine$'] Vaccine
	ON death.location = Vaccine.location
	AND death.date = Vaccine.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVSVac

--Temp Table

DROP Table if exists #PercentPopulationVAccinated
CREATE TABLE #PercentPopulationVAccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVAccinated
SELECT death.continent, death.location, death.date, Vaccine.population, death.new_vaccinations, SUM(CONVERT(int,death.new_vaccinations)) OVER (Partition by Vaccine.location Order by Vaccine.location, Vaccine.date) AS RollingPeopleVaccinated
FROM [Portfolio 1 - COVID Case]..['Covid death$'] death
JOIN [Portfolio 1 - COVID Case]..['Covid Vacine$'] Vaccine
	ON death.location = Vaccine.location
	AND death.date = Vaccine.date
--WHERE death.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVAccinated

--Create View to store data for visualisation

CREATE View PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, Vaccine.population, death.new_vaccinations
FROM [Portfolio 1 - COVID Case]..['Covid death$'] death
JOIN [Portfolio 1 - COVID Case]..['Covid Vacine$'] Vaccine
	ON death.location = Vaccine.location
	AND death.date = Vaccine.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated