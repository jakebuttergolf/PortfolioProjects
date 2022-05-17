
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccination
Where continent is not null
order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows % of population got Covid

Select location, date, population, total_cases,  (total_cases/population)*100 AS PositivePercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


-- Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS 
	PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
group by Location, Population
order by PercentPopulationInfected desc

-- Looking at the countries with the highest death rate compared to population

Select location, MAX(cast(total_deaths AS bigint)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
group by Location
order by TotalDeathCount desc

-- Lets break things down by continent

Select continent, MAX(cast(total_deaths AS bigint)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers Total

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2

-- Global Numbers by day

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.date) AS RunningTotalVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE for Temp tables

With PopsvsVacs (Continent, Location, date, population, new_vaccinations, RunningTotalVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.date) AS RunningTotalVaccinated
--,(RunningTotalVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RunningTotalVaccinated/population)*100
as running_total_vac_percentage
FROM PopsvsVacs


-- TEMP TABLE with drop table function
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RunningTotalVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.date) AS RunningTotalVaccinated
--,(RunningTotalVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RunningTotalVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.date) AS RunningTotalVaccinated
--,(RunningTotalVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
FROM PercentPopulationVaccinated
