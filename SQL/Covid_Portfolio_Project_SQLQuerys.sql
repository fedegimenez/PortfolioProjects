SELECT * 
FROM CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths
order by 1, 2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location like '%argentina%'

SELECT location, date, total_cases, Population, (total_cases/population)*100 as InfectedPercentage
FROM [Portfolio Project].dbo.CovidDeaths
--WHERE location like '%argentina%'
order by 1, 2



SELECT location, Population, MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
FROM [Portfolio Project].dbo.CovidDeaths
Group by location, Population
order by InfectedPercentage desc


SELECT location, MAX(Total_deaths) as TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
Group by location
order by TotalDeathCount desc

--CONTINENT

SELECT location, MAX(Total_deaths) as TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths
where continent is null 
Group by location
order by TotalDeathCount desc


-- WORLDWIDE

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
--group by date
ORDER BY 1, 2



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidDeaths dea 
JOIN [Portfolio Project].dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidDeaths dea 
JOIN [Portfolio Project].dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PopvsVac


-- Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidDeaths dea 
JOIN [Portfolio Project].dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from #PercentPopulationVaccinated


--CREATING VIEW

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidDeaths dea 
JOIN [Portfolio Project].dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3

 Select *
 from PercentPopulationVaccinated

