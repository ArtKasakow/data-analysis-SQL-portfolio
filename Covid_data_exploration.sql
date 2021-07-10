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

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS death_percentage
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL
-- Total percentage of people dying due to Covid is around 2.2% @7/10/2021




-- Total Population vs Vaccinations
-- Displays percentage vaccined (at least one) in population

SELECT dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations,
SUM(CONVERT(INT, vc.new_vaccinations)) OVER (PARTITION BY dt.location ORDER BY dt.location, dt.date) AS rolling_vaccination_count
FROM CovidAnalysis..CovidDeaths dt
JOIN CovidAnalysis..CovidVaccinations vc
	ON dt.location =  vc.location
	AND dt.date = vc.date
WHERE dt.continent IS NOT NULL
ORDER BY 2, 3


-- Using CTE to calculate on Partition By in previous query

WITH VaccinedPopulation (continent, location, date, poplation, new_vaccinations, rolling_vaccination_count) 
AS
(
SELECT dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations,
SUM(CONVERT(INT, vc.new_vaccinations)) OVER (PARTITION BY dt.location ORDER BY dt.location, dt.date) AS rolling_vaccination_count
FROM CovidAnalysis..CovidDeaths dt
JOIN CovidAnalysis..CovidVaccinations vc
	ON dt.location =  vc.location
	AND dt.date = vc.date
WHERE dt.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, rolling_vaccination_count/poplation*100 AS vaccinated_population_percentage
FROM VaccinedPopulation



-- TEMP TABLE
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #VaccinatedPoplulatinPercentage 
CREATE TABLE #VaccinatedPoplulatinPercentage
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccination_count numeric,
)
INSERT INTO #VaccinatedPoplulatinPercentage
SELECT dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations,
SUM(CONVERT(INT, vc.new_vaccinations)) OVER (PARTITION BY dt.location ORDER BY dt.location, dt.date) AS rolling_vaccination_count
FROM CovidAnalysis..CovidDeaths dt
JOIN CovidAnalysis..CovidVaccinations vc
	ON dt.location =  vc.location
	AND dt.date = vc.date
WHERE dt.continent IS NOT NULL
-- ORDER BY 2, 3
SELECT *, rolling_vaccination_count/population*100 AS vaccinated_population_percentage
FROM #VaccinatedPoplulatinPercentage




-- Creating View to store data for later visualizations

CREATE VIEW VaccinatedPoplulatinPercentage AS
SELECT dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations,
SUM(CONVERT(INT, vc.new_vaccinations)) OVER (PARTITION BY dt.location ORDER BY dt.location, dt.date) AS rolling_vaccination_count
FROM CovidAnalysis..CovidDeaths dt
JOIN CovidAnalysis..CovidVaccinations vc
	ON dt.location =  vc.location
	AND dt.date = vc.date
WHERE dt.continent IS NOT NULL
-- ORDER BY 2, 3