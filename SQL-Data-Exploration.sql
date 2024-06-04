
/*

Exploring Data with SQL Queries

Software Used: Microsoft SQl Server Management Studio

*/


--Checking Data


select *
from portfolio_project..covid_deaths
order by 3,4


select *
from portfolio_project..covid_vaccinations
order by 3,4


--------------------------------------------------------------------------------------------------------------------------

-- Select Data that we are going to be start with


Select location, date, total_cases, new_cases, total_deaths, population
From portfolio_project..covid_deaths
Where continent is not null 
order by 1,2


--------------------------------------------------------------------------------------------------------------------------

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you catch covid in India


Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio_project..covid_deaths
Where location like '%India%'
and continent is not null 
order by 1,2


--------------------------------------------------------------------------------------------------------------------------

-- Total Cases vs Population
-- Shows what percentage of population is infected with Covid


Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From portfolio_project..covid_deaths
order by 1,2


--------------------------------------------------------------------------------------------------------------------------

-- Countries with Highest Infection Rate Per Population


Select location, population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolio_project..covid_deaths
Group by location, Population
order by PercentPopulationInfected desc


--------------------------------------------------------------------------------------------------------------------------

-- Countries with Highest Death Count Per Population


Select location, Max(Total_deaths) as TotalDeathCount
From portfolio_project..covid_deaths
Where continent is not null 
Group by location
order by TotalDeathCount desc


--------------------------------------------------------------------------------------------------------------------------

-- Contintents with the highest death count Per Population


Select continent, MAX(total_deaths) as TotalDeathCount
From portfolio_project..covid_deaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--------------------------------------------------------------------------------------------------------------------------

-- GLOBAL NUMBERS


Select SUM(new_cases) as total_cases, SUM(Convert(int,new_deaths)) as total_deaths, SUM(Convert(int,new_deaths))/SUM(new_cases)*100 as DeathPercentage
From portfolio_project..covid_deaths
where continent is not null 
order by 1,2


--------------------------------------------------------------------------------------------------------------------------

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as People_Vaccinated_Over_Time
From portfolio_project..covid_deaths cd
Join portfolio_project..covid_vaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by 2,3


--------------------------------------------------------------------------------------------------------------------------

--Method 1:  Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (continent, location, date, population, new_vaccinations, People_Vaccinated_Over_Time)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as People_Vaccinated_Over_Time
From portfolio_project..covid_deaths cd
Join portfolio_project..covid_vaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
)

Select *, (People_Vaccinated_Over_Time/population)*100 as PercentPopulationVaccinated
From PopvsVac


--------------------------------------------------------------------------------------------------------------------------

-- Method 2: Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date date,
population numeric,
new_vaccinations numeric,
People_Vaccinated_Over_Time numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as People_Vaccinated_Over_Time
From portfolio_project..covid_deaths cd
Join portfolio_project..covid_vaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date



Select *, (People_Vaccinated_Over_Time/population)*100
From #PercentPopulationVaccinated


--------------------------------------------------------------------------------------------------------------------------

-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as People_Vaccinated_Over_Time
From portfolio_project..covid_deaths cd
Join portfolio_project..covid_vaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 

Select * 
From PercentPopulationVaccinated
