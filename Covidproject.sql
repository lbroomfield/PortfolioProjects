Select *
From CovidDeaths
where continent is not null
Order by 3,4

Select *
From CovidVaccinations
where continent is not null
Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
where continent is not null
Order by 1,2


-- Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
where location like '%states%'
and continent is not null
Order by 1,2


-- Looking at total cases vs population

Select location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
where location like '%states%'
Order by 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

-- Showing the countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Showing continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
Order by 1,2

-- Looking at total population vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order by 2, 3

-- using cte 
-- 
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- using temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Create a view

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 