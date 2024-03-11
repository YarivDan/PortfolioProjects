
/*

Covid19 Global Data Exploration 

Skills that been used: Joins, CTE's, Temporay Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM Covid19_Global.dbo.CovidDeaths
Where continent IS NOT NULL 
ORDER BY 3,4 


--First Table to start with: CovidDeaths 

SELECT continent, Location, date, population, total_cases, new_cases, total_deaths
FROM Covid19_Global.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 2,3 DESC


-- Total Cases vs Total Deaths
-- Probability of dying in your country


SELECT  continent, Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Deaths_Percentage
FROM Covid19_Global.dbo.CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY Deaths_Percentage


-- Total cases compare to population size
-- Covid19 population infection percentage


SELECT continent, Location, date, population, total_cases, (total_cases / population) * 100  AS Infection_Percentage 
FROM Covid19_Global.dbo.CovidDeaths
WHERE continent IS NOT NULL 
order by 6  DESC


-- Countries with highest infection rate compared to population
 

SELECT  continent, Location, date, population, total_cases, MAX((total_cases / population) * 100) AS Highest_Infection_Rate   
FROM Covid19_Global.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, Location, date, population, total_cases
ORDER BY  6  DESC


--  Highest ratio between death Count and population


SELECT continent, Location, date, population, MAX(CAST(total_deaths AS NUMERIC)) AS Total_Deaths_Count, 
MAX((CAST(total_deaths AS NUMERIC) / population) * 100) AS Deaths_Percentage 
FROM  Covid19_Global.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, Location, date, population, total_deaths
ORDER BY 6  DESC




-- Distribution of Covid19  mortality by continent

-- Highest death count per population

SELECT continent, MAX(cast(Total_deaths AS NUMERIC)) AS Total_Death_Count
FROM Covid19_Global.dbo.CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY 1,2 DESC


--Global numbers overview


SELECT SUM(new_cases) as Total_Infection_Cases, SUM(cast(new_deaths AS NUMERIC)) AS Total_deaths_Cases,
SUM(cast(new_deaths AS NUMERIC))/SUM(New_Cases)*100 AS Death_Percentage
FROM Covid19_Global.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY  1,2



-- Population vs Vaccinations
-- Number of given new vaccination per day 
-- Percentage of population that has recieved at least one Covid19 vaccine


SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations,
SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC)) / Deaths.population * 100  AS New_Vaccinations_Percentage,
SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC )) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Date, Deaths.location) AS Total_Vaccinated_Population--,
FROM Covid19_Global.dbo.CovidDeaths AS Deaths
INNER JOIN Covid19_Global.dbo.CovidVaccinations AS Vaccinations
	ON Deaths.location = Vaccinations.location
	AND Deaths.date = Vaccinations.date
WHERE Deaths.continent IS NOT NULL 
GROUP BY Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations
ORDER BY 2,3 DESC

 
 -- CTE (Common Table Expression) to calculate "PARTITION BY" in the previous query

WITH Population_Vs_Vaccinations (Continent, Location, Date, Population, New_Vaccinations, Vaccinated_New_Population_Percentage, Total_Vaccinated_Population) AS
(
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations,
SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC)) / Deaths.population * 100  AS Vaccinated_New_Population_Percentage,
SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC)) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Date, Deaths.location) AS Total_Vaccinated_Population
FROM Covid19_Global.dbo.CovidDeaths AS Deaths
INNER JOIN Covid19_Global.dbo.CovidVaccinations AS Vaccinations
	ON Deaths.location = Vaccinations.location
	AND Deaths.date = Vaccinations.date
WHERE Deaths.continent IS NOT NULL 
GROUP BY Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations
--ORDER BY 2,3 DESC
)

SELECT * ,(Total_Vaccinated_Population/Population)*100 AS Total_Vaccinated_Population_Percentage   
FROM  Population_Vs_Vaccinations




-- Temporary table to calculate "PARTITION BY" in previous query

DROP TABLE IF EXISTS Vaccinated_People_Percentage
CREATE TABLE  Vaccinated_People_Percentage

(
Continent NVARCHAR (255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
New_Vaccinations_Percentage  NUMERIC,
Total_Vaccinated_Population NUMERIC
)

INSERT INTO  Vaccinated_People_Percentage
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations,
SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC)) / Deaths.population * 100  AS Vaccinated_New_Population_Percentage,
SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC)) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Date, Deaths.location) AS Total_Vaccinated_Population
FROM Covid19_Global.dbo.CovidDeaths AS Deaths
INNER JOIN Covid19_Global.dbo.CovidVaccinations AS Vaccinations
	ON Deaths.location = Vaccinations.location
	AND Deaths.date = Vaccinations.date
WHERE Deaths.continent IS NOT NULL 
GROUP BY Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations
ORDER BY 2,3 DESC

SELECT *, (Total_Vaccinated_Population/Population) * 100 AS Total_Vaccinated_Population_Percentage   
FROM Vaccinated_People_Percentage



--View data table for later visualizations

DROP VIEW IF EXISTS Vaccinated_People_Percentage
CREATE VIEW Vaccinated_People_Percentage AS 

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations,
SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC)) / Deaths.population * 100  AS Vaccinated_New_Population_Percentage,
SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC)) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Date, Deaths.location) AS Total_Vaccinated_Population
FROM Covid19_Global.dbo.CovidDeaths AS Deaths
INNER JOIN Covid19_Global.dbo.CovidVaccinations AS Vaccinations
	ON Deaths.location = Vaccinations.location
	AND Deaths.date = Vaccinations.date
WHERE Deaths.continent IS NOT NULL 
GROUP BY Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations
--ORDER BY 2,3 DESC
 







 