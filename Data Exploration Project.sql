
Select *
FROM PortofolioProject.dbo.[Covid Data (Vacination)]
where total_tests is not null
order by 3,4

-- Select Data that we are go to be using

--Select location,date,total_cases,new_cases,total_deaths,population
--FROM PortofolioProject.dbo.[Covid Data (Death)]
--ORDER BY 1,2

-- Looking at Total Case vs Total Death
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases,total_deaths, (cast(total_deaths as float) / cast(total_cases as float))*100 AS Deathpercentage
FROM PortofolioProject.dbo.[Covid Data (Death)]
WHERE location LIKE 'Indonesia'
and continent is not null
Order by 1

-------- THIS IS COVID DEATH --------

-- Looking at Total Case vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population,total_cases, (cast(total_cases as decimal) / cast(population as decimal))*100 AS PercentPopulationInfected
FROM PortofolioProject.dbo.[Covid Data (Death)]
WHERE location LIKE 'Indonesia'
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(NULLIF(CONVERT(decimal, total_cases),0)) as HighestInfectionCount, 
MAX((NULLIF(CONVERT(decimal, total_cases),0) / NULLIF(CONVERT(decimal, population), 0)))*100 AS PercentPopulationInfected
FROM PortofolioProject.dbo.[Covid Data (Death)]
Group by location, population
Order by 4 DEsc

-- Looking at Countries with the Highest Death Count per Population
SELECT location, population, MAX(NULLIF(CONVERT(decimal, total_cases),0)) as HighestInfectionCount,
MAX(cast(total_deaths as int)) as HighestDeathCount,
MAX((cast(total_deaths as decimal) / cast(population as decimal))*100) AS Deathpercentage
FROM PortofolioProject.dbo.[Covid Data (Death)]
where continent is not null
GROUP BY location, population
Order by 4 DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT


SELECT location, population, MAX(NULLIF(CONVERT(decimal, total_cases),0)) as HighestInfectionCount,
MAX(cast(total_deaths as int)) as HighestDeathCount,
MAX((cast(total_deaths as decimal) / cast(population as decimal))*100) AS Deathpercentage
FROM PortofolioProject.dbo.[Covid Data (Death)]
where continent is not null
GROUP BY location, population
Order by 4 DESC

Select location, continent, max(cast(total_cases as decimal)) as Total_Pop
from PortofolioProject..[Covid Data (Death)]
where continent like 'North%'
group by location, continent

SELECT continent ,sum(Total_Pop) as Population, sum(Total_Cas) as Cases,  sum(Total_Dea) as Death, (sum(Total_Dea)/sum(Total_Pop)*100) as DeathPercentage
FROM 
	(
	Select location, continent, max(population) as Total_Pop, max(cast(total_cases as decimal)) as Total_Cas, MAX(cast(total_deaths as decimal)) as Total_Dea
	from PortofolioProject..[Covid Data (Death)]
	where continent is not null
	group by location, continent
	) a
Group by continent
Order by 2 desc


-------- THIS IS COVID TEST / VACC --------

Select *
from PortofolioProject..[Covid Data (Vacination)]
where location like 'Indonesia'
order by 3,4

SELECT Dea.location,Dea.date , new_cases, Vac.new_tests, 
(cast(new_cases as decimal)/cast(new_tests as decimal))*100 as PositifRate
FROM PortofolioProject..[Covid Data (Death)] as Dea
join PortofolioProject..[Covid Data (Vacination)] AS Vac
	on Dea.location = Vac.location and Dea.date = Vac.date
WHERE Dea.location like 'United States'
order by 1,2

-- 
SELECT *, (b.RollingPeopleVacination/b.Population)*100
FROM (
	Select dea.continent, dea.location, dea.date, dea.population as Population, vac.new_vaccinations,
	SUM(convert(decimal, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVacination
	--,(RollingPeopleVacination/dea.population)*100
	FROM PortofolioProject..[Covid Data (Death)] dea
	Join PortofolioProject..[Covid Data (Vacination)] vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.location like 'Indonesia'
	) b
