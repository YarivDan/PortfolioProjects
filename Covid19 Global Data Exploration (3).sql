


/*

This project explore data related to the COVID-19 pandemic, by using SQL queries. 
The data was taken from World Health Organization (WHO) website, and been gathered between the date 1/1/2020 and 30/4/2021.

The main goal of this project, is to get a valuable insights about the global Infection prevalance, death Counts, and population vaccinations. 

Skills that been used: 

1. Joins. 
2. Common Table Expression (CTE).
3. Temporay Tables. 
4. Windows Functions.
5. Aggregate Functions. 
6. Creating Views. 
7. Converting Data Types.

*/



---------------------------------------------------------------------- Part 1: COVID-19 infection prevalance data ----------------------------------------------------------------------     



/*

Task description:

 presenting national COVID-19 infection cases & infection percentages, is essential to understand the pandemic spread and impact. 
 This section starts with an overview of the "CovidDeaths" table, providing a foundational understanding of the data (Stage 1).
 The scection continues with calculation of the daily national infection percentage (Stage 2). 
 It's getting done by comparing total infection cases to the population size, offering insights 
 into the prevalence of COVID-19 in each country.
 
 The last stage identifies countries with the highest infection rates, examining potential correlations between population size 
 and the expansion of COVID-19 (Stage 3). 

*/


-- Stage 1-> First table to start with: "CovidDeaths". 
-----------> Lets take a brief look at the data.

SELECT *

FROM CovidDeaths

Where continent IS NOT NULL 

ORDER BY location, date 



-- Stage 2-> Calulate daily national infection Percentage.
-----------> Each country has been counted separatly.
-----------> Total infection cases compare to population size.

SELECT 
	 continent,	
	 Location, 
	 date, 
	 population, 
	 total_cases, 
	 (total_cases / population) * 100  AS Infection_Percentage 

FROM CovidDeaths

WHERE continent IS NOT NULL 

order by Location 



-- Stage 3-> looking for countries with the highset infection values.
-----------> Looking for correlation between population size, and COVID-19 expansion.

 
SELECT 
	 continent, 
	 Location, 
	 date, 
	 population, 
	 total_cases, 
	 MAX((total_cases / population) * 100) AS Highest_Infection_Rate  
	 
FROM CovidDeaths

WHERE continent IS NOT NULL

GROUP BY 
	   continent, 
	   Location, 
	   date, 
	   population, 
	   total_cases

ORDER BY Highest_Infection_Rate DESC



---------------------------------------------------------------------- Part 2: COVID-19 deaths prevalance ----------------------------------------------------------------------                    
   
   

/*

Task description:

This section presents an analysis of COVID-19 national death counts, & death percentages. 
Death percentages offer a contextual understanding of the pandemic lethality, relative to the population size (Stages 1-2).
Accurate death counts highlight the severity and impact of the pandemic (Stage 3).


*/

	             
	 
-- Stage 1-> Calulate the Probability of dying in your country.
-----------> Total infection cases Vs total deaths cases.

SELECT 
	 continent, 
	 Location, 
	 date, 
	 total_cases, 
	 total_deaths, 
	 (total_deaths/total_cases) * 100 AS Deaths_Percentage

FROM CovidDeaths

WHERE continent IS NOT NULL 

ORDER BY Deaths_Percentage DESC 



-- Stage 2-> Calculate peaks of deaths count & death Percentage, in each country.  
-----------> Looking for correlation between population size, and COVID-19 mortality rate.
-----------> Using Aggregate & conversion functions.

SELECT 
	 continent, 
	 Location, 
	 date, 
	 population, 
	 MAX(CAST(total_deaths AS NUMERIC)) AS Total_Deaths_Count, 
	 MAX((CAST(total_deaths AS NUMERIC) / population) * 100) AS Deaths_Percentage 

FROM CovidDeaths

WHERE continent IS NOT NULL

GROUP BY 
	   continent, 
	   Location, 
	   date, 
	   population, 
	   total_deaths

ORDER BY Location, Deaths_Percentage  DESC



-- Stage 3-> Calculate deaths count distribution, by continent.

SELECT 
	 continent, 
	 MAX(cast(Total_deaths AS NUMERIC)) AS Total_Death_Count

FROM CovidDeaths

WHERE continent IS NOT NULL 

GROUP BY continent

ORDER BY continent, Total_Death_Count DESC



---------------------------------------------------------------------- Part 3: COVID-19 global numbers- Infection cases & death counts ---------------------------------------------------------------------- 


/*

Task description:

This section presents the daily global numbers, behind the COVID-19 pandemic: 
Total Infection incidents, total death counts, and death percentage (Stage 1).
All three parameters, are an indication for the pandemic severity over time. 

*/


-- Stage 1-> Calculate worldwide total infection cases & total death counts.
-----------> Using aggregate & conversion functions.  

SELECT 
	 SUM(new_cases) AS Total_Infection_Cases, 
	 SUM(cast(new_deaths AS NUMERIC)) AS Total_deaths_Cases,
	 SUM(cast(new_deaths AS NUMERIC)) / SUM(New_Cases) * 100 AS Death_Percentage

FROM CovidDeaths

WHERE continent IS NOT NULL

ORDER BY Total_Infection_Cases, Total_deaths_Cases



---------------------------------------------------------------------- Part 4: COVID-19 vaccinations Vs population size ----------------------------------------------------------------------        



/*

Task description:

This section presents a cumulative count of vaccinated individuals. on each day, in every country (Stage 2).
The queries also track the total number of vaccinated people, and presents it alongside the population size (Stage 3). 
In addition, the percentage of the population that has received the vaccine, are also presented in this section (Stages 2-3).
The data is displayed in formats of CTE, temporary table, and view table (Stages 3-5).

*/



-- Stage 1-> First table to start with: "CovidVaccinations". 
-----------> Lets take a brief look at the data.

SELECT *

FROM CovidVaccinations

Where continent IS NOT NULL 



-- Stage 2-> Calculate new vaacinated population percantage.
-----------> Counting how many people recived vaccine for the first time.
-----------> Join columne "population" from table "CovidDeaths", to table "CovidVaccinations".

SELECT 
	 Deaths.continent, 
	 Deaths.location, 
	 Deaths.date, 
	 Deaths.population, 
	 Vaccinations.new_vaccinations,
	 SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC)) 
		/ Deaths.population * 100  AS New_Vaccinations_Percentage,
	 SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC )) 
		OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Date, Deaths.location) AS Total_Vaccinated_Population

FROM CovidDeaths AS Deaths

JOIN CovidVaccinations AS Vaccinations
   ON Deaths.location = Vaccinations.location
   AND Deaths.date = Vaccinations.date

WHERE Deaths.continent IS NOT NULL 

GROUP BY Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations

ORDER BY Deaths.location, Deaths.date DESC



-- Stage 3-> Meausre total progress of national vaccination process.
-----------> Counting how many people recived one vaccine or more.
-----------> Using temporary result set (CTE), to calculate column "Total_Vaccinated_Population_Percentage".   
-----------> Using window function ("OVER" clause), dividing countries to separate groups.

WITH Population_Vs_Vaccinations 

(
	Continent, 
	Location, 
	Date, 
	Population, 
	new_vaccinations, 
	Vaccinated_New_Population_Percentage, 
	Total_Vaccinated_Population)  
AS 
(

SELECT 
	 Deaths.continent, 
	 Deaths.location, 
	 Deaths.date, 
	 Deaths.population, 
	 Vaccinations.new_vaccinations,
	 SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC)) 
		/ Deaths.population * 100  AS Vaccinated_New_Population_Percentage,
	 SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC))
		OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Date, Deaths.location) AS Total_Vaccinated_Population

FROM CovidDeaths AS Deaths

 JOIN CovidVaccinations AS Vaccinations
	ON Deaths.location = Vaccinations.location
	AND Deaths.date = Vaccinations.date

WHERE Deaths.continent IS NOT NULL 

GROUP BY 
	   Deaths.continent, 
	   Deaths.location, 
	   Deaths.date, 
	   Deaths.population, 
	   Vaccinations.new_vaccinations
)

SELECT * ,
	 (Total_Vaccinated_Population / Population) * 100 AS Total_Vaccinated_Population_Percentage   

FROM Population_Vs_Vaccinations



-- Stage 4-> Display the data from stage 3, in new temporary table.
-----------> Using clause "DROP TABLE IF EXIST", to ensure there's no additional table with the same name.

DROP TABLE IF EXISTS Vaccinated_People_Percentage

CREATE TABLE Vaccinated_People_Percentage
(
			Continent NVARCHAR (255),
			Location NVARCHAR(255),
			Date DATETIME,
			Population NUMERIC,
			New_vaccinations NUMERIC,
			New_Vaccinations_Percentage NUMERIC,
			Total_Vaccinated_Population NUMERIC
)



-- Stage 5-> Insert data from stage 3, into table "Vaccinated_People_Percentage".

INSERT INTO Vaccinated_People_Percentage

SELECT 
	 Deaths.continent, 
	 Deaths.location, 
	 Deaths.date, 
	 Deaths.population, 
	 Vaccinations.new_vaccinations,
	 SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC)) 
		/ Deaths.population * 100  AS Vaccinated_New_Population_Percentage,
	 SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC)) 
		OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Date, Deaths.location) AS Total_Vaccinated_Population

FROM CovidDeaths AS Deaths

JOIN CovidVaccinations AS Vaccinations
   ON Deaths.location = Vaccinations.location
   AND Deaths.date = Vaccinations.date

WHERE Deaths.continent IS NOT NULL 

GROUP BY 
	   Deaths.continent, 
	   Deaths.location, 
	   Deaths.date, 
	   Deaths.population, 
	   Vaccinations.new_vaccinations

ORDER BY Deaths.location, Deaths.date DESC


SELECT *, 
(Total_Vaccinated_Population/Population) * 100 AS Total_Vaccinated_Population_Percentage  

FROM Vaccinated_People_Percentage



-- Stage 6-> Display the data from stage 3, in "view" table format.
-----------> Ensuring the readers can access table "Vaccinated_People_Percentage", but without changing the data.
-----------> Using clause "DROP VIEW IF EXIST", to ensure there's no additional "VIEW" table with the same name.

DROP VIEW IF EXISTS Vaccinated_People_Percentage

CREATE VIEW Vaccinated_People_Percentage AS 

SELECT 
	 Deaths.continent, 
	 Deaths.location, 
	 Deaths.date, 
	 Deaths.population, 
	 Vaccinations.new_vaccinations,
	 SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC)) 
		/ Deaths.population * 100  AS Vaccinated_New_Population_Percentage,
	 SUM(CAST(Vaccinations.new_vaccinations AS NUMERIC)) 
		OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Date, Deaths.location) AS Total_Vaccinated_Population

FROM CovidDeaths AS Deaths

JOIN CovidVaccinations AS Vaccinations
   ON Deaths.location = Vaccinations.location
   AND Deaths.date = Vaccinations.date

WHERE Deaths.continent IS NOT NULL 

GROUP BY 
	   Deaths.continent, 
	   Deaths.location, 
	   Deaths.date, 
	   Deaths.population, 
	   Vaccinations.new_vaccinations



 ---------------------------------------------------------------------- End ----------------------------------------------------------------------





 