
select *
From [portfolio project]..coviddeath
Where continent is not null
order by 3,4

--select *
--from [portfolio project]..covidvaccination
--order by 3,4

--select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [portfolio project]..coviddeath
order by 1,2

--Looking at total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From [portfolio project]..coviddeath
where location like '%states%'
order by 1,2


--Looking at the total cases vs population
--Shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [portfolio project]..coviddeath
--where location like '%states%'
order by 1,2

--Looking at countries with highest Infection Rate compared to population
Select location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From [portfolio project]..coviddeath
--where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--showing countinents with the highest death count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [portfolio project]..coviddeath
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers


--Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
-- (new_deaths as int))/sum(new_cases)*100 as Deathpercentage 
--From [portfolio project]..CovidDeath
--where continent is not null
--group by date 
--order by 1,2


Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from [portfolio project]..CovidDeath
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from [portfolio project]..CovidDeath dea
join [portfolio project]..CovidVaccinations$ vac
  on  dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3


  --	USE CTE
  with popvsVac (Continent, Location, Date, Population, New_vaccinations, Rollingpeoplevaccinated)
  as
  (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from [portfolio project]..CovidDeath dea
join [portfolio project]..CovidVaccinations$ vac
  on  dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  )
select *, (Rollingpeoplevaccinated/Population)*100
from popvsVac 

--Temp Table
Drop Table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)

--TEMP TABLE

Insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from [portfolio project]..CovidDeath dea
join [portfolio project]..CovidVaccinations$ vac
  on  dea.location = vac.location
  and dea.date = vac.date
  --where dea.continent is not null
  --order by 2,3
  select *, (rollingpeoplevaccinated/Population)*100
  from #percentpopulationvaccinated


 --Creating view(for the 1st time) to store data for later visualizations
 
 create view percentpopulationvaccinated as
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from [portfolio project]..CovidDeath dea
join [portfolio project]..CovidVaccinations$ vac
  on  dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3

 select *
 from percentpopulationvaccinated