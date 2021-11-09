Select *
From Covid_Data_Exploration..covidmuertes
order by 3, 4

Select *
From Covid_Data_Exploration..covidvacunas
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population 
from Covid_Data_Exploration..covidmuertes
order by 1, 2
--casos vs muertes 
--Posibilidades de muerte al contraer covid-19 en Argentina
select location, date, total_cases,population,  total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Covid_Data_Exploration..covidmuertes
Where location like '%argentina%'
order by 1, 2

--tasas de infección, comparando con población total
select location, population, MAX(total_cases) as MaxInfectados, MAX((total_cases/population)*100) as mayporcentaje
from Covid_Data_Exploration..covidmuertes
group by location, population
order by mayporcentaje desc

--muertes por continente
Select location, MAX(cast(total_deaths as int)) as muertes_totales
from Covid_Data_Exploration..covidmuertes
where continent is null
group by location
order by muertes_totales desc


--totales global
Select date, SUM(new_cases) as daily_infected, SUM(cast(new_deaths as int))
from Covid_Data_Exploration..covidmuertes
where continent is not null
group by date
order by 1

--CTE para calcular con partición
With PopVsVac (continent, Location,  Date, Population, new_vaccinations, vacunadosroll)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as vacunadosroll
From Covid_Data_Exploration..covidvacunas vac
Join Covid_Data_Exploration..covidmuertes dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *
from PopVsVac

--Temp Table
DROP Table if exists #PorcentajeVacunados
Create Table #PorcentajeVacunados
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VacunadosRoll numeric
)

Insert into #PorcentajeVacunados
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as VacunadosRoll
From Covid_Data_Exploration..Covidmuertes dea
Join Covid_Data_Exploration..Covidvacunas vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (VacunadosRoll/Population)*100 as Vacunadosporcentaje
From #PorcentajeVacunados

--Visualización
Create View PorcentajeVacunadosVIEW as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as VacunadosRoll
From Covid_Data_Exploration..Covidmuertes dea
Join Covid_Data_Exploration..Covidvacunas vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
