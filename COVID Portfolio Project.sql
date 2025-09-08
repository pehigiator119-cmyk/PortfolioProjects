select *
from [PortfolioProject ].dbo.CovidDeaths
WHERE continent is not null
order by 3,4

--select *
--from [PortfolioProject ].dbo.CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from [PortfolioProject ]..CovidDeaths
WHERE continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [PortfolioProject ]..CovidDeaths
WHERE location like '%Nigeria%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- shows what percentage of Population got Covid

select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
from [PortfolioProject ]..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
order by 1,2


-- Looking at countries with highest infection rate compared to population.

select Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/Population)*100 as 
  PercentPopulationInfected
from [PortfolioProject ]..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY location, population 
order by PercentPopulationInfected desc

--Showing counties with the highest death count per population.

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [PortfolioProject ]..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY location 
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT




-- Showing contients with the highest death count per population.

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [PortfolioProject ]..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc


-- Global numbers.

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as
  DeathPercentage
from [PortfolioProject ]..CovidDeaths
--WHERE location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2


-- looking at total population vs vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ].dbo.CovidVaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USING CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ].dbo.CovidVaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(225),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ].dbo.CovidVaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- CREATING VIEW TO STORE DATA FOR LATER VISUALLISATIONS (TABLEAU)

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ].dbo.CovidVaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
From PercentPopulationVaccinated