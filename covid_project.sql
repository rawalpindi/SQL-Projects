SELECT *
FROM CovidDeaths
ORDER BY 3
	,4

SELECT *
FROM CovidVaccination
ORDER BY 3
	,4

SELECT location
	,DATE
	,total_cases
	,new_cases
	,total_deaths
FROM CovidDeaths
ORDER BY 1
	,2

--TRUNCATE TABLE coviddeaths

--looking at total case vs total death
SELECT location
	,DATE
	,total_cases
	,total_deaths
	,(convert(FLOAT, total_deaths) / convert(FLOAT, total_cases)) * 100 AS DeathPerc
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1
	,2

SELECT DISTINCT total_deaths
FROM CovidDeaths
ORDER BY total_deaths

--% of population that got covid in the country
SELECT location
	,DATE
	,population
	,total_cases
	,total_deaths
	,(total_cases / population) * 100 AS Perc
FROM CovidDeaths
WHERE location LIKE '%india%'
ORDER BY 1
	,2

--countries with highest infection with respect to population.
SELECT location
	,population
	,max(total_cases) AS HighestInfectionCount
	,max(total_cases / population) * 100 AS PercPopulationIfected
FROM CovidDeaths
--WHERE location LIKE '%india%'
GROUP BY location
	,population
ORDER BY 4

--Countries with highest death with respect to population.
SELECT location
	,max(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- with continet
SELECT continent
	,max(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

SELECT SUM(total_deaths)
FROM CovidDeaths
WHERE continent IN (
		'Europe'
		,'North America'
		,'European Union'
		,'South America'
		,'Asia'
		,'Africa'
		,'Oceania'
		,'International'
		)
GROUP BY location

--order by 2 desc


--Continent with highest deathcounts with respect to population
SELECT continent
	,max(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--Overall Numbers for death percentage
SELECT SUM(new_cases) AS total_cases
	,SUM(cast(new_deaths AS INT)) AS Total_deaths
	,sum(cast(new_deaths AS INT) / SUM(new_cases)) * 100 AS DeathPerc
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1
	,2

SELECT sum(new_deaths / (iif(new_cases = 0, NULL, cast(new_cases AS FLOAT)))) * 100 AS DeathPerc
FROM CovidDeaths
WHERE continent IS NOT NULL

SELECT *
FROM CovidVaccination

SELECT d.continent
	,d.location
	,d.DATE
	,d.population
	,v.new_vaccinations
	,SUM(convert(INT, v.new_vaccinations)) OVER (
		PARTITION BY d.location ORDER BY d.location
			,d.DATE
		) Total_people_vaccinated
FROM CovidDeaths d
JOIN CovidVaccination v ON d.location = v.location
	AND d.DATE = v.DATE
WHERE d.continent IS NOT NULL
ORDER BY 2
	,3
WITH Pop_Vacc(continet, location, DATE, population, new_vaccination, Total_people_vaccinated) AS (
		SELECT d.continent
			,d.location
			,d.DATE
			,d.population
			,v.new_vaccinations
			,SUM(convert(INT, v.new_vaccinations)) OVER (
				PARTITION BY d.location ORDER BY d.location
					,d.DATE
				) Total_people_vaccinated
		FROM CovidDeaths d
		JOIN CovidVaccination v ON d.location = v.location
			AND d.DATE = v.DATE
		WHERE d.continent IS NOT NULL
		)

SELECT *
	,(Total_people_vaccinated / population) * 100 AS Perc_people_vaccinated
FROM Pop_Vacc
WHERE location LIKE '%India&'

--no result from join above for india
SELECT DISTINCT location
FROM CovidDeaths
ORDER BY location

-- Temp Table
DROP TABLE

IF EXISTS #TBL_perc_people_vaccinated
	CREATE TABLE #TBL_perc_people_vaccinated (
		continent NVARCHAR(255)
		,location NVARCHAR(255)
		,DATE DATETIME
		,population BIGINT
		,new_vaccination NUMERIC
		,Total_people_vaccinated NUMERIC
		)

INSERT INTO #TBL_perc_people_vaccinated
SELECT d.continent
	,d.location
	,d.DATE
	,d.population
	,v.new_vaccinations
	,SUM(convert(INT, v.new_vaccinations)) OVER (
		PARTITION BY d.location ORDER BY d.location
			,d.DATE
		) Total_people_vaccinated
FROM CovidDeaths d
JOIN CovidVaccination v ON d.location = v.location
	AND d.DATE = v.DATE
WHERE d.continent IS NOT NULL

SELECT *
	,(Total_people_vaccinated / population) * 100 AS Perc_people_vaccinated
FROM #TBL_perc_people_vaccinated
