/*OverViewing Dataset */
SELECT *
FROM
	CovidProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM
	CovidProject..CovidVaccinations
ORDER BY 3,4
/* */

-- SELECT DATA THAT WE WILL USE
SELECT 
	Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM
	CovidProject..CovidDeaths
WHERE
	continent <> ' '
ORDER BY 1,2

-- Look at Total Case vs Total Death
--- Shows likelihood of dying if you get covid in indonesia
SELECT 
	Location, 
	date, 
	total_cases,
	total_deaths,
	(CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage
FROM 
	CovidProject..CovidDeaths
WHERE
	location LIKE 'Indo%'
	AND 
		continent <> ' '
ORDER BY 1,2

-- Look at Total Case vs Population
--- Shows what percentage of population got covid

SELECT 
	Location, 
	date,
	Population,
	total_cases,
	(CAST(total_cases as float)/CAST(population as float))*100 as PercentPopInfected
FROM 
	CovidProject..CovidDeaths
WHERE
	location LIKE 'Indo%'
	AND 
		continent <> ' '
ORDER BY 1,2


-- Look at Asian Countries with Highest Infection Rate compared to Population
SELECT 
	Location, 
	Population,
	MAX(CAST(total_cases AS INT)) as HighestInfectionCount,
	MAX((CAST(total_cases as float)/CAST(population as float))*100) as PercentPopInfected
FROM 
	CovidProject..CovidDeaths
WHERE
	continent = 'Asia'
GROUP BY Location, Population
ORDER BY PercentPopInfected DESC

-- Showing Countries with Highest Deaths Population
SELECT 
	Location, 
	MAX(CAST(total_deaths as int)) as TotalDeathsCount
FROM 
	CovidProject..CovidDeaths
WHERE 
	continent <> ' '
GROUP BY Location
ORDER BY TotalDeathsCount DESC

-- LET'S BREAK THING DONE BY CONTINENT
SELECT 
	location,
	MAX(CAST(total_deaths as int)) as TotalDeathsCount
FROM 
	CovidProject..CovidDeaths
WHERE
	continent = ' '
	and
		location not like '%income'
GROUP BY location
ORDER BY TotalDeathsCount DESC


--Showing Continent with highest deaths count per population
SELECT 
	continent,
	MAX(CAST(total_deaths as int)) as TotalDeathsCount
FROM 
	CovidProject..CovidDeaths
WHERE
	continent <> ' '
GROUP BY continent
ORDER BY TotalDeathsCount DESC

--- GLOBAL NUMBERS
SELECT 
	date, 
	SUM(new_cases) as GlobalTotalCases,
	SUM(new_deaths) as GlobalTotalDeaths,
	(SUM(new_deaths)/SUM(new_cases))*100 as GlobalTotalDeaths
FROM 
	CovidProject..CovidDeaths
WHERE
		continent <> ' '
		and new_cases <> ' '
		and new_deaths <> ' '
GROUP BY date
ORDER BY 1,2

-- Looking at Total Pop vs Vac
SELECT 
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location
		ORDER BY dea.location, dea.date) as RollingPeopleVaccinated,
	--(RollingPeopleVaccinated/population)*100 -- Need CTE or Temp Table
FROM
	CovidProject..CovidDeaths dea
JOIN
	CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND 
		dea.date = vac.date
WHERE
	dea.continent <> ' '
ORDER BY 2,3

-- USE CTE
WITH PopvsVac AS
(
SELECT 
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location
		ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
	CovidProject..CovidDeaths dea
JOIN
	CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND 
		dea.date = vac.date
WHERE
	dea.continent <> ' '
)
SELECT 
	*,
	(RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population FLOAT,
New_Vaccintaion FLOAT,
RollingPeopleVaccinated FLOAT
)


INSERT INTO #PercentPopVaccinated
SELECT 
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location
		ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
	CovidProject..CovidDeaths dea
JOIN
	CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND 
		dea.date = vac.date
WHERE
	dea.continent <> ' '

SELECT 
	*,
	(RollingPeopleVaccinated/population)*100
FROM #PercentPopVaccinated

-- Creating View to Store Data for later Visualizations
CREATE VIEW PercentPopVaccinated as
SELECT 
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location
		ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
	CovidProject..CovidDeaths dea
JOIN
	CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND 
		dea.date = vac.date
WHERE
	dea.continent <> ' '

SELECT *
FROM
	PercentPopVaccinated