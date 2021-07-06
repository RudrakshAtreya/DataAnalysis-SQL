
-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths and Percentage


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
where location like '%India%'
order by 1,2


-- Looking at Total Cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as CasesPerPopulation
From CovidProject..CovidDeaths
where location like '%India%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as
	PercentPopulationInfected
		From CovidProject..CovidDeaths
		Group by Location, Population
		order by PercentPopulationInfected desc;


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
	From CovidProject..CovidDeaths
		where Continent is not NULL
		Group by Location
		order by TotalDeathCount desc;


-- Breaking things down by Continent

-- Showing the Continents with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
	From CovidProject..CovidDeaths
		where Continent is NULL
		Group by location
		order by TotalDeathCount desc;


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
	From CovidProject..CovidDeaths
		where Continent is not NULL
		Group by continent
		order by TotalDeathCount desc;



-- GLOBAL NUMBERS

--Totals on particular Dates

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
		From CovidProject..CovidDeaths
		--where location like '%India%'
		where continent is not NULL
		Group by date
		order by 1,2

--Totals till date

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
--where location like '%India%'
where continent is not NULL
--Group by date
order by 1,2



-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT (int, vac.new_vaccinations)) over (Partition by dea.location) order by dea.location,
	 dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
order by 2,3


-- Looking Total Vaccination without null values (days before vaccination)

select dea.location, dea.date, vac.new_vaccinations, 
	SUM(cast (new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as VaccinationSum
From CovidProject..CovidDeaths dea, CovidProject..CovidVaccinations vac
where dea.location = vac.location
and dea.date = vac.date
and dea.continent is not null
and vac.new_vaccinations is not null
order by 1,2 


-- Using CTE (Common Table Expression)


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT (int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
	 dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as CTE_PercentVac
From PopvsVac



-- Temp Table


Drop Table if exists #PercentPopulationVaccinated

USE CovidProject;
GO
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT (numeric, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
		dea.date) as RollingPeopleVaccinated
	from CovidProject..CovidDeaths dea
	Join CovidProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	--where dea.continent is not Null

Select *, (RollingPeopleVaccinated/Population)*100 as CTE_PercentVac
From #PercentPopulationVaccinated



-- Creating View to Store Data for later Visualizations

drop view if exists PercentPopulationVaccinated


USE CovidProject ;
GO
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT (int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
	 dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
--order by 2,3


Select * 
	from PercentPopulationVaccinated


