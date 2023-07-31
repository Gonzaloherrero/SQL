
SELECT *
FROM CovidDeaths$
ORDER BY 3,4



-- DATA TO STAR

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1, 2



--TOTAL CASES VS TOTAL DEATHS - PROBABILITY OF DEATH IF YOU CONTRACT COVID BY COUNTRY.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
FROM CovidDeaths$
WHERE location like 'Argentina'
ORDER BY 1, 2



-- CASES VS POPULATION - PROBABILITY OF CONTAGION

SELECT location, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM CovidDeaths$
WHERE location like 'Argentina'
ORDER BY 1, 2



-- CASES VS POPULATION - COUNTRIES WITH THE HIGHEST INFECTION RATE.

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM CovidDeaths$
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC



-- HIGHEST AMOUNT OF DEATHS BY COUNTRY.

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC



--HIGHEST AMOUNT OF DEATHS BY CONTINENT.

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS.

-- TOTAL DEATHS VS TOTAL CASES - PERCENTAGE OF DEATHS PER DAY.

SELECT date, SUM (new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathsPercentage
FROM CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2



-- UNION OF TABLES - DEATHS AND VACCINATIONS

--TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3 



-- TOTAL POPULATION VS VACCINATIONS - SUMMARY DAY BY DAY.

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3 



-- CTE.

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac



-- TEMP TABLE.

DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- CREATE A VIEW.

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
