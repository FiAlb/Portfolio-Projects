select *
From PortafolioProject..CovidDeaths
Where continent is not null
order by 3,4

--select *
--From PortafolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are ging to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortafolioProject..CovidDeaths
order by 1,2

--Looking at the Total Cases vs. Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercetange
From PortafolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2


--Looking at the Total Cases vs Population
--Shows what % of population got covid

Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From PortafolioProject..CovidDeaths
--Where Location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rates compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortafolioProject..CovidDeaths
--Where Location like '%states%'
group by Location, Population
order by PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortafolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
group by Location
order by TotalDeathCount DESC


-- Lets break things down by continent (using Location because with continent does not add up correctly-see 2nd example)

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortafolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is null
group by location
order by TotalDeathCount DESC


--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortafolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount DESC


--Global numbers

--filter the globar numbers of deaths per day
Select date, SUM(new_cases)--, total_deaths, (Total_deaths/total_cases)*100 as DeathPercetange
From PortafolioProject..CovidDeaths
Where continent is not null
group by date
order by 1,2

--SUM function works in colummn that are float. In case it is not (ej.nvarchar), cast as int is neccesary

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercetange
From PortafolioProject..CovidDeaths
Where continent is not null
--group By date
order by 1,2



--Looking at Total Population vs Vaccinations

select *
From PortafolioProject..CovidDeaths dea --dea ist table alias um zeit zu sparen
join PortafolioProject..CovidVaccinations vac --same with vac
	on dea.location=vac.location
	and dea.date=vac.date


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
,
From PortafolioProject..CovidDeaths dea
join PortafolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortafolioProject..CovidDeaths dea
join PortafolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacinnations numeric,
RollingPeopleVaccinated numeric
)

Insert  into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortafolioProject..CovidDeaths dea
join PortafolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortafolioProject..CovidDeaths dea
join PortafolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated