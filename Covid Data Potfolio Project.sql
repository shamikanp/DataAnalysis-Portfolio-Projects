Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Selecting Data

Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Total Cases vs Total Deaths
--Shows a rough estimate of dying if you contract covid in the United Kingdom

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%kingdom%'
order by 1,2


--Total Cases vs Population
--Shows a rough percentage of population contracted covid in the United Kingdom

Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
Where location like '%kingdom%'
order by 1,2


--Total Cases vs Total Deaths
--Shows a rough estimate of dying if you contract covid in India

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%India%'
order by 1,2


--Total Cases vs Population
--Shows a rough percentage of population contracted covid in India

Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
Where location like '%India%'
order by 1,2


--Countries with the Highest Infection rate compared to the population
Select location, population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases)/population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by InfectedPopulationPercentage desc


--Countries with the Highest Death rate compared to the population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc


--Breaking down data by Continents

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc



--Continents with the Highest Death Count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc



--Global Numbers

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as TotalDeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as TotalDeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
--Group by date
order by 1,2


-- Total Population vs Vaccinations 

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
order by 2,3


-- Rolling count for new vaccinations

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
order by 2,3

--Using CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Using Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
--Where death.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for Visualization
Drop view IF exists PercentPopulationVaccinated

Create View 
PercentPopulationVaccinated 
as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated


