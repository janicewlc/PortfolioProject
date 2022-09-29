

SELECT *
FROM ProjectHKCovidData..VaccinationRateByAge


UPDATE ProjectHKCovidData..VaccinationRateByAge
SET 
    "Age Group" = 'Aged 80 and above'
WHERE
    "Age Group" = '80 and above'


SELECT [Age Group], sex, SUM([Sinovac 1st dose]) AS Sinovac1stCount, SUM([Sinovac 2nd dose]) AS Sinovac2ndCount, SUM([Sinovac 3rd dose]) AS Sinovac3rdCount,
	   SUM([Sinovac 4th dose]) AS Sinovac4thCount, SUM([BioNTech 1st dose]) AS BioNTech1stCount, SUM([BioNTech 2nd dose]) AS BioNTech2ndCount,
	   SUM([BioNTech 3rd dose]) AS BioNTech3rdCount, SUM([BioNTech 4th dose]) AS BioNTech4thCount
FROM ProjectHKCovidData..VaccinationRateByAge
GROUP BY [Age Group], sex
ORDER BY [Age Group]


SELECT [Age Group], Sex, SUM([Sinovac 1st dose]) AS Sinovac1stCount, SUM([BioNTech 1st dose]) AS BioNTech1stCount, SUM([Sinovac 1st dose]+[BioNTech 1st dose]) AS TotalPopulationWith1stDose
FROM ProjectHKCovidData..VaccinationRateByAge
GROUP BY [Age Group], Sex
ORDER BY [Age Group]


WITH Vaccination_Population (AgeGroup, Sex, Sinovac1stCount, BioNTech1stCount)
AS(
SELECT [Age Group], Sex, SUM([Sinovac 1st dose]) AS Sinovac1stCount, SUM([BioNTech 1st dose]) AS BioNTech1stCount
FROM ProjectHKCovidData..VaccinationRateByAge
GROUP BY [Age Group], Sex
)
SELECT *, (Sinovac1stCount+BioNTech1stCount) AS TotalPopulationWith1stDose
FROM Vaccination_Population
ORDER BY AgeGroup, Sex


DROP TABLE IF EXISTS #MaleVaccinationPopulation
CREATE TABLE #MaleVaccinationPopulation
(
AgeGroup nvarchar(255),
M_Sinovac1stCount numeric,
M_BioNTech1stCount numeric,
M_1stDoseVaccinated numeric,
)

INSERT INTO #MaleVaccinationPopulation
SELECT [Age Group], SUM([Sinovac 1st dose]), SUM([BioNTech 1st dose]), SUM([Sinovac 1st dose]+[BioNTech 1st dose]) AS TotalPopulationWith1stDose
FROM ProjectHKCovidData..VaccinationRateByAge
WHERE Sex = 'M'
GROUP BY [Age Group]
ORDER BY [Age Group]



SELECT *
FROM #MaleVaccinationPopulation
ORDER BY AgeGroup



DROP TABLE IF EXISTS #FemaleVaccinationPopulation
CREATE TABLE #FemaleVaccinationPopulation
(
AgeGroup nvarchar(255),
F_Sinovac1stCount numeric,
F_BioNTech1stCount numeric,
F_1stDoseVaccinated numeric,
)

INSERT INTO #FemaleVaccinationPopulation
SELECT [Age Group], SUM([Sinovac 1st dose]), SUM([BioNTech 1st dose]), SUM([Sinovac 1st dose]+[BioNTech 1st dose]) AS TotalPopulationWith1stDose
FROM ProjectHKCovidData..VaccinationRateByAge
WHERE Sex = 'F'
GROUP BY [Age Group]
ORDER BY [Age Group]

SELECT *
FROM #FemaleVaccinationPopulation
ORDER BY AgeGroup



DROP TABLE IF EXISTS #1stDoseVaccinePopulation
CREATE TABLE #1stDoseVaccinePopulation
(
AgeGroup nvarchar(255),
Sinovac1stCount numeric,
BioNTech1stCount numeric,
[1stDoseVaccinated] numeric,
)

INSERT INTO #1stDoseVaccinePopulation
SELECT [Age Group], SUM([Sinovac 1st dose]), SUM([BioNTech 1st dose]), SUM([Sinovac 1st dose]+[BioNTech 1st dose]) AS TotalPopulationWith1stDose
FROM ProjectHKCovidData..VaccinationRateByAge
GROUP BY [Age Group]
ORDER BY [Age Group]


SELECT *
FROM #1stDoseVaccinePopulation
ORDER BY AgeGroup

SELECT Sex, SUM([Sinovac 1st dose]) AS Sinovac1stCount, SUM([BioNTech 1st dose]) AS BioNTech1stCount, SUM([Sinovac 1st dose]+[BioNTech 1st dose]) AS TotalPopulationWith1stDose
FROM ProjectHKCovidData..VaccinationRateByAge
GROUP BY Sex

SELECT 
 m.AgeGroup, m.M_1stDoseVaccinated, m.M_BioNTech1stCount, m.M_Sinovac1stCount, f.F_1stDoseVaccinated, f.F_BioNTech1stCount, f.F_Sinovac1stCount, [1st].[1stDoseVaccinated], [1st].BioNTech1stCount, [1st].Sinovac1stCount
  FROM (#MaleVaccinationPopulation m
   JOIN #FemaleVaccinationPopulation f 
    ON m.AgeGroup = f.AgeGroup)
	JOIN #1stDoseVaccinePopulation [1st]
	ON m.AgeGroup = [1st].AgeGroup
ORDER BY AgeGroup