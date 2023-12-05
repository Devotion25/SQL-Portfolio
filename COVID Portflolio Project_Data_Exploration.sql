Select *
From project..CovidDeaths$
where continent is not null
order by 3,4


--Select *
--From project..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From project..CovidDeaths$
where continent is not null
order by 1,2

--Looking for total cases vs total death

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From project..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2


Select location, date, total_cases, new_cases, total_deaths, population, (total_cases/population)*100 as DeathPercentage
From project..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2 

--Looking at countries with highest infection rate compared to population


Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectionPerecentage 
From project..CovidDeaths$
--where location like '%states%'
Group by Location, population
order by InfectionPerecentage desc

--Number of people that died

Select continent, MAX(cast(total_cases as int)) as TotalDeathsCount
From project..CovidDeaths$
where continent is not null
--where location like '%states%'
Group by continent
order by TotalDeathsCount desc

-- Break by contintent 
Select location, MAX(cast(total_cases as int)) as TotalDeathsCount
From project..CovidDeaths$
where continent is  null
--where location like '%states%'
Group by location
order by TotalDeathsCount desc


--Breaking Global number

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))* 100 as DeathPercentage
From project..CovidDeaths$
--group by date 
order by 1,2


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From project..CovidDeaths$ dea
Join
project..CovidVaccinations$ vac
on dea.location= vac.location
and dea.date =vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_vaaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From project..CovidDeaths$ dea
Join
project..CovidVaccinations$ vac
on dea.location= vac.location
and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
select*, ( RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
from PopvsVac 


-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
( 
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From project..CovidDeaths$ dea
Join
project..CovidVaccinations$ vac
on dea.location= vac.location
and dea.date =vac.date
--where dea.continent is not null
--order by 2,3

select*, ( RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
from #PercentPopulationVaccinated


-- creating view to store data for later vaccinations
 
 Create View PercentVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From project..CovidDeaths$ dea
Join project..CovidVaccinations$ vac
on dea.location= vac.location
and dea.date =vac.date
where dea.continent is not null
--order by 2,3

