/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3, 4

--SELECT *
--FROM CovidAnalysis..CovidVaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3, 4

-- Choosing Data for Data Exploration

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Checking Total Deaths vs. Total Cases
-- Displaying probabilty of dying when contracting covid in your country

SELECT location, date, population, total_cases, total_deaths, total_deaths/total_cases*100 AS death_rate
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL
AND location LIKE '%Germany%'
ORDER BY 1, 2


-- Checking Total Cases of Population
-- Display the percentage of people infected with Covid amongst the population

SELECT location, date, population, total_cases, total_cases/population*100 AS infected_population_ratio
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL
AND location LIKE 'Germany'
ORDER BY 1, 2

-- Countries with highest infection rate compared to the population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population*100) AS highest_infection_rate
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL
-- AND location LIKE 'Germany'
GROUP BY location, population
ORDER BY highest_infection_rate DESC


-- Countries with the highest number of deaths

SELECT location, population, MAX(CAST(total_deaths AS int)) AS death_count, MAX(CAST(total_deaths AS int))/population*100 AS death_rate_percentage
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL
-- AND country LIKE 'Germany'
GROUP BY location, population
ORDER BY 3 DESC



-- Exploratory Data Analysis(EDA) on continent level

-- Displaying contintents with the highest death count

SELECT location, MAX(CAST(total_deaths AS int)) AS death_count
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY death_count DESC



-- Checking Global Covid numbers as progression

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as death_rate_percentage
From CovidAnalysis..CovidDeaths
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS rolling_people_vaccinated
FROM CovidAnalysis..CovidDeaths dea
JOIN CovidAnalysis..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3



-- Using CTE to perform Calculation on Partition By in previous query (Reminder to myself: No cap anymore)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_people_vaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (rolling_people_vaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_people_vaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (rolling_people_vaccinated/Population)*100
From #PercentPopulationVaccinated





-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 