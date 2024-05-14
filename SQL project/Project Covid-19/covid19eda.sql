-- Covid-19 Data Exploration Analysis
-- Pre-view coviddeaths table
SELECT *
FROM coviddeaths;

-- Change date data type and format
UPDATE coviddeaths
SET `date` = DATE_FORMAT(STR_TO_DATE(`date`, '%d/%m/%Y'), '%Y-%m-%d');
-- rename column code
ALTER TABLE coviddeaths
RENAME COLUMN  ๏ปฟiso_code TO iso_code;

-- Pre-view covidvaccinations table 
SELECT ROW_NUMBER() OVER()
FROM covidvaccinations
;

-- Change date data type and format
UPDATE covidvaccinations
SET `date` = DATE_FORMAT(STR_TO_DATE(`date`, '%d/%m/%Y'), '%Y-%m-%d');
-- rename column code
ALTER TABLE covidvaccinations
RENAME COLUMN  ๏ปฟiso_code TO iso_code;

SELECT continent, location, `date`, population, total_cases, total_deaths
FROM coviddeaths;

-- Daily confirmed COVID-19 cases by country
SELECT continent, location, MAX(total_cases), SUM(new_cases) AS totalCases, MAX(total_deaths),  SUM(new_deaths) AS TotalDeaths
FROM coviddeaths
WHERE continent != '' AND continent IS NOT NULL
GROUP BY continent, location
;

-- Find the total number of COVID-19 cases worldwide.
SELECT SUM(new_cases) AS Total_cases_over_time,  SUM(new_deaths) AS Deaths_over_time
FROM coviddeaths
WHERE continent != '' AND continent IS NOT NULL;

-- Total cases in each continent
SELECT continent, SUM(new_cases) AS Total_case
FROM coviddeaths
WHERE continent != '' AND continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC
;

-- Daily percentage of deaths by continent.
WITH cte_prep(continent, `date`, TotalCasesPerDay, TotalDeathsPerDay, PercentageOfDeaths)AS
(SELECT continent, `date`, SUM(new_cases), sum(new_deaths), ROUND(sum(new_deaths)/SUM(new_cases), 2)
FROM coviddeaths
WHERE continent != '' AND continent IS NOT NULL
GROUP BY continent, `date`
ORDER BY `date`)
SELECT continent, `date`, TotalCasesPerDay, TotalDeathsPerDay, COALESCE(PercentageOfDeaths, 0) AS PercentageOfDeaths
FROM cte_prep
;

-- Percentage of People Infected within a Population and Death Rate per Confirmed Case
WITH cte_percentage(continent, location, population, total_case, total_death) AS (
SELECT continent, location, MAX(population), MAX(total_cases), SUM(new_deaths)
FROM coviddeaths
WHERE continent != '' AND continent IS NOT NULL
GROUP BY continent, location )
SELECT 
    continent, 
    SUM(population) total_pop, 
    SUM(total_case) total_case, 
    SUM(total_death) total_death, 
    SUM(total_case)/SUM(population) PercentageInfective,
    ROUND(SUM(total_death)/SUM(total_case), 4) PercentageDeath
FROM cte_percentage
GROUP BY continent
;

-- Countries with the Highest Number of Confirmed COVID-19 Cases by Continent
WITH cte_continent AS
(SELECT continent, location, MAX(total_cases) AS total_case
FROM coviddeaths
WHERE continent != '' AND continent IS NOT NULL
GROUP BY continent, location)
, cte_rank AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY continent ORDER BY  total_case DESC) AS rank_case
FROM cte_continent
)
SELECT *
FROM cte_rank
WHERE rank_case = 1
ORDER BY total_case DESC
;

-- Total vaccination in each continent
WITH cte_agg(continent, location, TotalVaccination, TotalFullyVaccinated) AS
(
SELECT continent, location, MAX(CAST(total_vaccinations AS INT)),  MAX(CAST(people_fully_vaccinated AS INT))
FROM CovidVaccinations
WHERE continent != '' AND continent IS NOT NULL
GROUP BY continent, location
)
SELECT continent, SUM(TotalVaccination) AS TotalVaccination, SUM(TotalFullyVaccinated) AS TotalFullyVaccinated
FROM cte_agg
GROUP BY continent
ORDER BY 2 DESC, 3 DESC
;

-- Daily vaccination and Percentage vaccination in each day
WITH cte_join(continent, location, record_date, population, total_vaccinations, people_fully_vaccinated)  AS (
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    CAST(vac.total_vaccinations AS FLOAT),
    CAST(vac.people_fully_vaccinated AS FLOAT)
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
 ON dea.location = vac.location
 	AND dea.date = vac.date )
, cte_agg AS
(
SELECT 
    continent, 
    record_date, 
    SUM(population) AS Pop, 
    SUM(total_vaccinations) AS TotalVaccinated, 
    SUM(people_fully_vaccinated) AS TotalFullyVaccinated, 
    ROUND(SUM(total_vaccinations)/SUM(population)*100, 2) AS PercentageVaccinated
FROM cte_join
WHERE continent is NOT NULL AND continent <> ''
GROUP BY continent, record_date
ORDER BY record_date ASC )
SELECT continent, record_date, pop,
CASE WHEN TotalVaccinated IS NULL THEN 0 ELSE TotalVaccinated END TotalVaccinated,
CASE WHEN TotalFullyVaccinated IS NULL THEN 0 ELSE TotalFullyVaccinated END TotalFullyVaccinated,
CASE WHEN PercentageVaccinated IS NULL THEN 0 ELSE PercentageVaccinated END PercentageVaccinated
FROM cte_agg
;

-- Average %vaccination in each continent
WITH cte_join(continent, location, record_date, population, total_vaccinations, people_fully_vaccinated)  AS (
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    CAST(vac.total_vaccinations AS FLOAT),
    CAST(vac.people_fully_vaccinated AS FLOAT)
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
 ON dea.location = vac.location
 	AND dea.date = vac.date )
, cte_agg(continent, location, populations, total_vaccinations, FullyVaccinated, VaccinationPerPop) AS (
SELECT continent, location, MAX(population), MAX(total_vaccinations), MAX(people_fully_vaccinated), ROUND(MAX(total_vaccinations)/MAX(population), 2)
FROM cte_join
WHERE continent is NOT NULL AND continent <> ''
GROUP BY continent, location)
SELECT 
    continent, 
    SUM(populations) AS Population, 
    SUM(total_vaccinations) AS Total_vaccination, 
    AVG(VaccinationPerPop) AS AvgVaccinationPerPop
FROM cte_agg
GROUP BY continent
ORDER BY 2 DESC, 3 DESC;
