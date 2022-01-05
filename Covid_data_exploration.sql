/*
Covid Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- CHAPTER 1
-- Analyzing total cases vs. total deaths

SELECT [location], [date], total_cases, total_deaths, CAST(total_deaths as float)/CAST(total_cases as float)*100 AS death_percentage
FROM SQLTutorial..CovidDeaths
-- WHERE [location] LIKE 'Spain'
ORDER BY 1, 2


-- Infection rates in Spain

SELECT [location], [date], total_cases, population, CAST(total_cases AS float)/CAST(population AS float)*100 AS infection_percentage
FROM SQLTutorial..CovidDeaths
WHERE [location] LIKE 'Spain'
ORDER BY 1, 2


-- Highest infetion rate per country

SELECT [location], population, MAX(total_cases) AS highest_infection_rate, CAST(MAX(total_cases) AS float)/CAST(population AS float)*100 AS infection_rate
FROM SQLTutorial..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location], population
ORDER BY infection_rate DESC


-- Analyzing highest death count per population

SELECT [location], population, MAX(total_deaths) AS highest_death_count, CAST(MAX(total_deaths) AS float)/CAST(population AS float)*100 AS death_rate
FROM SQLTutorial..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location], population
ORDER BY highest_death_count DESC


-- Analyzing highest death count by continent

SELECT continent, SUM(new_deaths) as highest_death_count, AVG(population) AS average_population
FROM SQLTutorial..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC


-- Gobal development of Covid cases and deaths per day

SELECT date, SUM(new_cases) AS total_cases_global, SUM(new_deaths) AS total_deaths_global, CAST(SUM(new_deaths) AS float)/CAST(SUM(new_cases) AS float)*100 AS death_rate_global
FROM SQLTutorial..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1


-- Gobal development of Covid cases and deaths total

SELECT SUM(new_cases) AS total_cases_global, SUM(new_deaths) AS total_deaths_global, CAST(SUM(new_deaths) AS float) / CAST(SUM(new_cases) AS float)*100 AS death_percentage
FROM SQLTutorial..CovidDeaths
WHERE continent IS NOT NULL

-- CHAPTER 2: Using CTE and Joins
-- Comparing total population vs. vaccinations

WITH PeopleVaccinated (continent, location, date, population, people_vaccinated, total_vaccinations)
AS (
SELECT cdea.continent, cdea.[location], cdea.[date], cdea.population, cvac.people_vaccinated, SUM(CAST(cvac.people_vaccinated AS bigint)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.Date) AS total_vaccinations
FROM SQLTutorial..CovidDeaths cdea
JOIN SQLTutorial..CovidVacs cvac
    ON cdea.date = cvac.date 
    AND cdea.location = cvac.location
)
SELECT *, CONVERT(float, people_vaccinated)/CONVERT(float, population)*100 AS people_vaccination_rate
FROM PeopleVaccinated
WHERE location LIKE 'Germany'
ORDER BY 2, 3


-- CHAPTER 3: TEMP Table

DROP TABLE IF EXISTS #PeopleVaccinated
CREATE TABLE #PeopleVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population float,
    people_vaccinated float,
    total_vaccinations FLOAT
)
INSERT INTO #PeopleVaccinated
SELECT cdea.continent, cdea.[location], cdea.[date], cdea.population, cvac.people_vaccinated, SUM(CAST(cvac.people_vaccinated AS bigint)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.Date) AS total_vaccinations
FROM SQLTutorial..CovidDeaths cdea
JOIN SQLTutorial..CovidVacs cvac
    ON cdea.date = cvac.date 
    AND cdea.location = cvac.location

SELECT *, people_vaccinated / population * 100 AS people_vaccination_rate
FROM #PeopleVaccinated
WHERE location LIKE 'Germany'
ORDER BY 2, 3


-- CHAPTER 4: Views

DROP VIEW IF EXISTS PeopleVaccinatedGlobally
CREATE VIEW PeopleVaccinatedGlobally AS
SELECT cdea.continent, cdea.[location], cdea.[date], cdea.population, cvac.people_vaccinated, SUM(CAST(cvac.people_vaccinated AS bigint)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) AS total_vaccinations
FROM SQLTutorial..CovidDeaths cdea
JOIN SQLTutorial..CovidVacs cvac
    ON cdea.date = cvac.date 
    AND cdea.location = cvac.location
WHERE cdea.continent IS NOT NULL

SELECT *
FROM PeopleVaccinatedGlobally
ORDER BY 2,3
