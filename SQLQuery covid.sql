--select *
--from covid.dbo.CovidDeaths;

SELECT
location, date, total_cases_per_million, total_deaths, population
FROM covid.dbo.CovidDeaths
ORDER BY 1,2;

--Looking at total cases vs total deaths

SELECT 
location, date, total_cases_per_million, total_deaths, population, 
[DeathPercentage]= ( CAST(total_deaths AS FLOAT)/total_cases_per_million)*100
FROM covid.dbo.CovidDeaths
WHERE location LIKE '%A'

--Looking at countries with highest infection rate compared to population

SELECT
location,population ,MAX(total_cases_per_million) AS [Highest Infection], MAX(total_cases_per_million/population)*100 AS [Percentage Highest Infection], total_deaths 
FROM covid.dbo.CovidDeaths
GROUP BY location,population,total_deaths
 HAVING total_deaths=MAX(total_deaths)
ORDER BY [Percentage Highest Infection] DESC

--showing countries with highest death count per popultion
SELECT 
location,
[Highest Death per Population]= MAX (CAST(total_deaths AS INT))
FROM covid.dbo.CovidDeaths
WHERE (total_deaths IS NOT NULL AND continent IS NOT NULL)
GROUP BY location,total_deaths
ORDER BY [Highest Death per Population] DESC;

--continent breakdown
SELECT DISTINCT
continent,
[Highest Death per Population]= SUM (CAST(total_deaths AS INT))
FROM covid.dbo.CovidDeaths
WHERE (total_deaths IS NOT NULL AND continent IS NOT NULL)
GROUP BY continent
ORDER BY [Highest Death per Population] DESC;

--new cases

SELECT 
--date,
continent,
new_cases as [new Death Total]
FROM covid.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY continent,new_cases
 
ORDER BY new_cases DESC


SELECT 
D.continent,D.location, D.date,D.population, V.new_vaccinations
FROM covid.dbo.CovidDeaths D
JOIN covid.dbo.CovidVaccinations V
	ON (D.location=V.location
	AND D.date = V.date)
WHERE D.continent IS NOT NULL 
	AND V.new_vaccinations IS NOT NULL
ORDER BY 1,2,3;

SELECT 
D.continent,D.location, D.date,D.population, V.new_vaccinations,
SUM (CONVERT (INT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location) AS [Rolling People Vaccinated]
FROM covid.dbo.CovidDeaths D
JOIN covid.dbo.CovidVaccinations V
	ON (D.location=V.location
	AND D.date = V.date)
WHERE D.continent IS NOT NULL 
	AND V.new_vaccinations IS NOT NULL
ORDER BY 1,2,3;
-- use CTE


WITH t1 (Continent,Location, Date,Population,New_vaccinations,[Rolling People Vaccinated])
AS 

(SELECT 
D.continent,D.location, D.date,D.population, V.new_vaccinations,
SUM (CONVERT (INT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location,D.date) AS [Rolling People Vaccinated]

FROM covid.dbo.CovidDeaths D
JOIN covid.dbo.CovidVaccinations V
	ON (D.location=V.location
	AND D.date = V.date)
WHERE D.continent IS NOT NULL 
--ORDER BY 1,2,3
)
SELECT Continent, COUNT(*) AS [Count per Continent]
FROM t1
GROUP BY Continent

--TEMP TABLE
CREATE TABLE #RollingPop
(
continent nvarchar(255),
location nvarchar(255),
date Datetime,
population FLOAT,
new_vaccinations nvarchar(255),
[Rolling People Vaccinated] numeric
)

INSERT INTO #RollingPop

SELECT 
D.continent,D.location, D.date,D.population, V.new_vaccinations,
SUM (CONVERT (INT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location,D.date) AS [Rolling People Vaccinated]

FROM covid.dbo.CovidDeaths D
JOIN covid.dbo.CovidVaccinations V
	ON (D.location=V.location
	AND D.date = V.date)
WHERE D.continent IS NOT NULL 
--ORDER BY 1,2,3


SELECT *
FROM #RollingPop

-- creating view for visualization
CREATE VIEW RollinPop AS

WITH t1 (Continent,Location, Date,Population,New_vaccinations,[Rolling People Vaccinated])
AS 

(SELECT 
D.continent,D.location, D.date,D.population, V.new_vaccinations,
SUM (CONVERT (INT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location,D.date) AS [Rolling People Vaccinated]

FROM covid.dbo.CovidDeaths D
JOIN covid.dbo.CovidVaccinations V
	ON (D.location=V.location
	AND D.date = V.date)
WHERE D.continent IS NOT NULL 
--ORDER BY 1,2,3
)
SELECT Continent, COUNT(*) AS [Count per Continent]
FROM t1
GROUP BY Continent

