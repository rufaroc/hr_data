Use HR

SELECT *
FROM hr_data

Select termdate
From hr_data
Order by termdate DESC

UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyy-mm-dd')

ALTER TABLE hr_data
ADD new_termdate1 DATE

-- copy converted time values from termdate to new termdate1

UPDATE hr_data
SET new_termdate1 = CASE
	WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1 THEN CAST(termdate AS DATETIME) ELSE NULL END

-- create new collumn age 
ALTER TABLE hr_data
ADD age nvarchar(50)

UPDATE hr_data
SET age = DATEDIFF(YEAR, birthdate, GETDATE())

-- Questions to answer from DATE
-- 1. What's the age distribution in the company?
-- age distribution 
-- age group by gender

-- 2. What's the gender breakdwon in the company?
-- 3. How does gender vary across departments and job titles?
-- 4. What's the race distribution  in the company?
-- 5. What's the average length of employment in the company?
-- 6. Which deparmtent has the highest turnover rate?
-- 7. What is the tenure distribution from each department?
-- 8. How many employees work remotely for each deparment?
-- 9. What's the distribution of employees across different states?
-- 10. How are job titles distributed in the company?
-- 11. How have employee hire conunts varied over time?


-- 1. What's the age distribution in the company?

-- oldest, youngest 

SELECT 
	MIN(age) AS youngest_employee,
	MAX(age) AS oldest_employee
FROM hr_data

-- distribution 

SELECT age
FROM hr_data
ORDER BY age

SELECT age_group,
COUNT(*) AS count
FROM
(SELECT 
	CASE
	WHEN age<= 22 AND age <= 31 THEN '22 to 31'
	WHEN age<= 32 AND age <= 41 THEN '32 to 41'
	WHEN age<= 42 AND age <= 51 THEN '42 to 51'
	ELSE '51+'
	END AS age_group 
FROM hr_data
WHERE new_termdate1 IS NULL
) AS subquery
GROUP BY age_group
ORDER BY age_group

-- age group by gender

SELECT age_group, gender, 
COUNT(*) AS count
FROM
(SELECT 
	CASE
	WHEN age<= 22 AND age <= 31 THEN '22 to 31'
	WHEN age<= 32 AND age <= 41 THEN '32 to 41'
	WHEN age<= 42 AND age <= 51 THEN '42 to 51'
	ELSE '51+'
	END AS age_group, gender 
FROM hr_data
WHERE new_termdate1 IS NULL
) AS subquery
GROUP BY age_group, gender
ORDER BY age_group, gender 


-- 2. What's the gender breakdwon in the company?

SELECT gender,
COUNT(gender) AS count
FROM hr_data
WHERE new_termdate1 IS NULL
GROUP BY gender
ORDER BY gender ASC

-- 3. How does gender vary across departments and job titles?
-- gender in department
SELECT 
gender, 
department, 
COUNT(gender) AS count
FROM hr_data
WHERE new_termdate1 IS NULL
GROUP BY gender, department 
ORDER BY gender ASC

-- gender in department 
SELECT 
gender, 
department,
jobtitle, 
COUNT(gender) AS count
FROM hr_data
WHERE new_termdate1 IS NULL
GROUP BY gender, department, jobtitle 
ORDER BY gender ASC

-- 4. What's the race distribution  in the company?

SELECT 
race, 
COUNT(*) AS count 
FROM hr_data
WHERE new_termdate1 IS NULL
GROUP BY race
ORDER BY count DESC

-- 5. What's the average length of employment in the company?

SELECT 
    AVG(DATEDIFF(year, hire_date, new_termdate1)) AS tenure 
FROM hr_data
WHERE new_termdate1 IS NOT NULL AND new_termdate1 <= GETDATE();


-- 6. Which deparmtent has the highest turnover rate?
-- get total count
-- get total terminated count
-- total/terminated 

SELECT
department, 
total_count, 
terminated_count,
ROUND((CAST(terminated_count AS float)/total_count),2)* 100 AS turnover_rate
FROM
	(SELECT 
	department, 
	COUNT(*) AS total_count,
	SUM(CASE
	WHEN new_termdate1 IS NOT NULL AND new_termdate1 <= GETDATE() THEN 1 ELSE  0
	END 
	) AS terminated_count 
		FROM hr_data 
		GROUP BY department 
	) AS subquery
ORDER BY turnover_rate DESC

-- 7. What is the tenure distribution from each department?

SELECT 
department,
    AVG(DATEDIFF(year, hire_date, new_termdate1)) AS tenure 
FROM hr_data
WHERE new_termdate1 IS NOT NULL AND new_termdate1 <= GETDATE()
GROUP BY department 
ORDER BY tenure DESC

-- 8. How many employees work remotely for each deparment?

SELECT 
location, 
count(*) as count
FROM hr_data
WHERE new_termdate1 IS NULL
GROUP BY location 

-- 9. What's the distribution of employees across different states?

SELECT 
location_state, 
count(*) AS count
FROM hr_data
WHERE new_termdate1 IS NULL
GROUP BY location_state
ORDER BY count 

-- 10. How are job titles distributed in the company?
SELECT 
jobtitle, 
count(*) AS count
FROM hr_data
WHERE new_termdate1 IS NULL
GROUP BY jobtitle
ORDER BY count DESC

-- 11. How have employee hire conunts varied over time?
-- calc hires 
-- calc terminations 
-- hires terminations/hires percentage hire change

SELECT 
	hire_year,
	hires, 
	terminations, 
	hires - terminations AS net_change, 
	ROUND(CAST(hires - terminations AS float)/hires, 2) * 100 AS percent_hire_change
FROM
	(SELECT 
		YEAR(hire_date) AS hire_year,
		count(*) AS hires,
		SUM(CASE
				WHEN new_termdate1 IS NOT NULL AND new_termdate1 <= GETDATE() THEN 1 ELSE 0
				END
				) AS terminations
		FROM hr_data
		GROUP BY YEAR(hire_date)
		) AS subquery 
ORDER BY percent_hire_change ASC

