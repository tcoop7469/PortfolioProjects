select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select *
--from PortfolioProject..CovidVactionations
--order by 3,4

-- Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--total cases vs total deaths
-- show likelihood of dying from covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- looking at total cases vs population
-- show population that got covid

select Location, date, population, total_cases, (total_cases/population)*100 as PercentOfPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared to population


select Location, population, max(total_cases)as HighestIfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by Location, population
order by PercentOfPopulationInfected desc

--Shows with highest death count per population

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENTS

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENTS


--showing continents with highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(
cast(new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(
cast(new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

-- looking at total population vs vaccinations

use PortfolioProject

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollinPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvactionations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


	-- USE CTE

with popvsvac (Continent, Location, date, population, new_vaccinations, RollingPeoploeVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollinPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvactionations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeoploeVaccinated/population)*100
From popvsvac


	--Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollinPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvactionations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visulizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollinPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvactionations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated