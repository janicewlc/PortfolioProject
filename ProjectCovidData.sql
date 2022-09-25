--GLOBAL COVID DATA FROM 2020JAN01 TO 2022SEP21

--DEATH DATA

SELECT *
FROM ProjectCovidData..CovidDeaths
ORDER BY 4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectCovidData..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS (PER DAY)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate_per_day
FROM ProjectCovidData..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

--TOTAL CASES VS POPULATION (PER DAY)
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infection_rate_per_day
FROM ProjectCovidData..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

--FINDING COUNTRY WITH HIGHEST INFECTION RATE
SELECT continent, location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS infection_rate
FROM ProjectCovidData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY infection_rate DESC

--ACCUMULATED DEATH COUNT BY COUNTRY
SELECT location, MAX(CAST(total_deaths AS INT)) AS acc_death_count
FROM ProjectCovidData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY acc_death_count DESC

--FINDING COUNTRY WITH HIGHEST DEATH RATE
SELECT location, MAX(total_cases) AS acc_case_count, MAX(CAST(total_deaths AS INT)) AS acc_death_count, MAX((total_deaths/total_cases)*100) AS death_rate
FROM ProjectCovidData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_rate DESC

--ACCUMULATED DEATH COUNT BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS INT)) AS acc_death_count
FROM ProjectCovidData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY acc_death_count DESC


--GLOBAL NUMBERS

--TOTAL CASES (PER DAY)
SELECT date, SUM(new_cases) AS total_case_count, SUM(CONVERT(int, new_deaths))AS total_death_count, SUM(CONVERT(int, new_deaths))/SUM(new_cases) *100 AS death_rate
FROM ProjectCovidData..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--TOTAL CASES
SELECT SUM(new_cases) AS total_case_count, SUM(CONVERT(int, new_deaths))AS total_death_count, SUM(CONVERT(int, new_deaths))/SUM(new_cases) *100 AS death_rate
FROM ProjectCovidData..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--DAILY INFECTION RATE
SELECT continent, location, population, date, total_cases, (total_cases/population)*100 AS infection_rate
FROM ProjectCovidData..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,3


--VACCINATION DATA
SELECT *
FROM ProjectCovidData..CovidVaccinations
ORDER BY 3,4

--JOIN THE 2 DATASET
SELECT *
FROM ProjectCovidData..CovidDeaths dea
JOIN ProjectCovidData..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
ORDER BY 3,4

--VACCINATION VS POPULATION
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS NUMERIC)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cum_vaccinations
FROM ProjectCovidData..CovidDeaths dea
JOIN ProjectCovidData..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
WITH vas_vs_pop (continent, location, date, population, new_vaccinations, cum_vaccinations)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS NUMERIC)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cum_vaccinations
FROM ProjectCovidData..CovidDeaths dea
JOIN ProjectCovidData..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (cum_vaccinations/population)*100 AS vaccination_rate
FROM vas_vs_pop

--FINDING COUNTRY WITH HIGHEST VACCINATION RATE
WITH vas_vs_pop (continent, location, population, new_vaccinations, cum_vaccinations)
AS (
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS NUMERIC)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cum_vaccinations
FROM ProjectCovidData..CovidDeaths dea
JOIN ProjectCovidData..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT location, population, MAX(cum_vaccinations) AS total_vaccination_count, MAX(cum_vaccinations/population)*100 AS vacciation_rate
FROM vas_vs_pop
GROUP BY  location, population
ORDER BY vacciation_rate DESC



--TEMP TABLE
DROP TABLE IF EXISTS #percentage_poplation_vaccinated
CREATE TABLE #percentage_poplation_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Cum_vaccinations numeric,
)

INSERT INTO #percentage_poplation_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS NUMERIC)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cum_vaccinations
FROM ProjectCovidData..CovidDeaths dea
JOIN ProjectCovidData..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (cum_vaccinations/population)*100 AS Vaccination_rate
FROM #percentage_poplation_vaccinated



-- CREATE VIEW TO STORE DATA FOR VISUALIZATION
CREATE VIEW percentage_poplation_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS NUMERIC)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cum_vaccinations
FROM ProjectCovidData..CovidDeaths dea
JOIN ProjectCovidData..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL