--Testing 1,2... is this thing on?
SELECT *
FROM Project1..CovidDeaths
ORDER BY 3,4;

--Base data

SELECT location, date, population, new_cases, total_cases, total_deaths
FROM Project1..CovidDeaths
ORDER BY 1,2;


--Covid deaths in the U.S.A.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percent_covid_deaths
FROM Project1..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2;


-- What percentage of the population is infected with Covid in the U.S.A.?

SELECT location, date, population, total_cases, (total_cases/population)*100 as percent_covid_infections
FROM Project1..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2;


--What is the rate of infection for other countries?

SELECT location, population, MAX(total_cases) as total_infections,  Max((total_cases/population))*100 as total_percent_infections
FROM Project1..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;


--What countries have the most deaths from Covid?

SELECT location, population, MAX(cast(total_deaths as int)) as total_covid_deaths
FROM Project1..CovidDeaths
WHERE continent is not NULL 
GROUP BY location, population
ORDER BY 3 DESC; 



--Which continents have the highest amount of deaths from Covid?

SELECT continent, MAX(cast(total_deaths as int)) as deaths_per_continent
FROM Project1..CovidDeaths
WHERE continent is not NULL 
GROUP BY continent
ORDER BY 2 DESC;


--What are the worldwide Covid cases and deaths for each day?

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as mortality_rate
FROM Project1..CovidDeaths
WHERE continent is not NULL 
GROUP BY date
ORDER BY 1,2;


-- Which countries have the highest number of vaccinations and when were the vaccinations given?

SELECT death.location, death.date, death.population, death.continent, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as total_vaccinations
FROM Project1..CovidDeaths death
JOIN Project1..CovidVaccination vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent is not NULL AND vac.new_vaccinations is not NULL
ORDER BY 1,2;


-- Temp table, What percentage of each country has been vaccinated?
DROP TABLE IF EXISTS #percent_vaccinated
CREATE TABLE #percent_vaccinated
(location nvarchar(255),
date datetime,
population float,
continent nvarchar(255),
new_vaccinations numeric,
total_vaccinations numeric)

INSERT INTO #percent_vaccinated
SELECT death.location, death.date, death.population, death.continent, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as total_vaccinations
FROM Project1..CovidDeaths death
JOIN Project1..CovidVaccination vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent is not NULL

SELECT *, (total_vaccinations/population)*100 as percent_pop_vaccinated
FROM #percent_vaccinated