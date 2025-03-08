--select location, date, total_cases,new_cases, total_deaths, population
--from CovidDeathssssss
--order by 1,2

--Breaking down by cnotinent

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
	from CovidDeathssssss
	where total_cases is not null and total_cases !=0  and continent is not null
	group by continent
	order by TotalDeathCount desc

--SHOWS the ration of total deaths to total cases as a percentage // likelyhood of dying if you contract covid in your country.

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as [Percentage]
from CovidDeathssssss
where total_cases is not null and total_cases !=0 and location like '%india%'
order by 1,2

--Shows how much of the county's population got infected

	select location, date, total_cases, Population, (total_cases/Population)*100 as [Percentage]
	from CovidDeathssssss
	where total_cases is not null and total_cases !=0 and location like '%india%'
	order by 1,2

--Looking at the countries with highest infection rate compared to population

select location, Population,MAX(total_cases) as HighestInfectionCount, MAX(total_cases/Population)*100 as [Percentage]
	from CovidDeathssssss
	where total_cases is not null and total_cases !=0 
	group by Location, Population
	order by 1,2

--Showing Countries with the highest death count per population (Mortality rate)

select location,MAX(cast(total_deaths as int)) as TotalDeathCount 
	from CovidDeathssssss
	where total_cases is not null and total_cases !=0 and continent is  null
	group by Location
	order by TotalDeathCount desc

	--continents with the highest death count per population.

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
	from CovidDeathssssss
	where total_cases is not null and total_cases !=0 and continent is not null
	group by continent
	order by TotalDeathCount desc
	

--Global numbers

select  date, sum(new_cases) as newCases, sum(new_deaths) as newDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeathssssss
where  new_cases!=0 and continent is not null
group by date
order by 1,2


--From Vaccinations

select * 
From CovidDeathssssss CD
JOIN CovidVaccinations CV ON CD.location = CV.location and CD.date = cv.date

--looking at Total Population and Vaccinations

select CD.continent, cd.location, cd.population, CV.new_vaccinations, 
		SUM(cast(cv.new_vaccinations as bigint) ) 
		over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
From CovidDeathssssss CD
JOIN CovidVaccinations CV 
		ON CD.location = CV.location 
		and CD.date = cv.date
		where cd.continent is not null
order by 2,3


--using CTE

with PopVsVaccination(Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
	select CD.continent, cd.location, cd.date, cd.population, CV.new_vaccinations, 
		SUM(cast(cv.new_vaccinations as bigint) ) 
		over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
	From CovidDeathssssss CD
	JOIN CovidVaccinations CV 
			ON CD.location = CV.location 
			and CD.date = cv.date
			where cd.continent is not null
)

select *, (RollingPeopleVaccinated/Population)*100
from PopVsVaccination


--Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent varchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select CD.continent, cd.location, cd.date, cd.population, CV.new_vaccinations, 
		SUM(cast(cv.new_vaccinations as bigint) ) 
		over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
	From CovidDeathssssss CD
	JOIN CovidVaccinations CV 
			ON CD.location = CV.location 
			and CD.date = cv.date
			where cd.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as 
select CD.continent, cd.location, cd.date, cd.population, CV.new_vaccinations, 
	SUM(cast(cv.new_vaccinations as bigint) ) 
	over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
From CovidDeathssssss CD
JOIN CovidVaccinations CV 
		ON CD.location = CV.location 
		and CD.date = cv.date
where cd.continent is not null

select * 
from PercentPopulationVaccinated
