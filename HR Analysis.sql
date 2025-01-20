CREATE DATABASE projects;
USE projects;
SELECT * FROM hr;
ALTER TABLE hr RENAME COLUMN ï»¿id TO emp_id;
ALTER TABLE hr RENAME COLUMN birthdate TO birth_date;
ALTER TABLE hr RENAME COLUMN jobtitle TO job_title;
ALTER TABLE hr RENAME COLUMN termdate TO term_date;
SET sql_safe_updates = 0;
UPDATE hr SET  hire_date = CASE
WHEN hire_date LIKE '%/%' THEN date_format( str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
WHEN hire_date LIKE '%-%' THEN date_format( str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
ELSE NULL
END;
SELECT term_date FROM hr;
ALTER TABLE hr MODIFY COLUMN birth_date date;
ALTER TABLE hr MODIFY COLUMN emp_id VARCHAR(20);
UPDATE hr 
SET term_date = date(str_to_date(term_date,'%Y-%m-%d %H:%i:%s UTC'),'0000-00-00')
WHERE term_date IS NOT NULL AND term_date != '';
SET sql_mode = 'ALLOW_INVALID_DATES'; -- to allow dates to be zero if not there in data as then term_date datatype will not change to date as first row would have diff datatype 
ALTER TABLE hr
MODIFY COLUMN hire_date date;
ALTER TABLE  hr
MODIFY COLUMN term_date date;
DESCRIBE hr;
ALTER TABLE hr ADD COLUMN age INT;
UPDATE hr
SET age = timestampdiff(YEAR, birth_date, CURDATE());
SELECT COUNT(*)  FROM hr;
DELETE FROM hr WHERE age < 18;

-- What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS count
FROM hr 
WHERE term_date = '0000-00-00'
GROUP BY gender;

-- What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) AS ethnicity
FROM hr
Where term_date = '0000-00-00'
GROUP BY race
ORDER BY ethnicity DESC;

-- What is the age distribution of employees in the company?
SELECT  
 min(age) AS youngest,
 max(age) AS oldest 
FROM hr
WHERE term_date = '0000-00-00';
SELECT 
 CASE
	WHEN age >=18 and age <=24 THEN '18-24'
	WHEN age >=25 and age <=34 THEN '25-34'
	WHEN age >=35 and age <=44 THEN '35-44'
	WHEN age >=45 and age <=54 THEN '45-54'
	WHEN age >=55 and age <=64 THEN '55-64'
 ELSE '65+'
END AS age_grp,gender,
count(*)  as count
FROM hr
WHERE term_date = '0000-00-00'
GROUP BY age_grp, gender
ORDER BY age_grp, gender;

-- How many employees work at headquarters vs remote locations?
SELECT location, count(*) AS count
FROM hr
WHERE term_date = '0000-00-00'
GROUP BY location;

-- What is the average length of employment for employees who have been terminated?
SELECT round(avg(datediff(term_date, hire_date)) / 365,0) AS avg_yrs_served
FROM hr
WHERE term_date <= CURDATE() and term_date <> '0000-00-00';

-- How does the gender distribution vary across departments and job titles?
SELECT gender, department, count(*) AS count
FROM hr
WHERE term_date = '0000-00-00'
GROUP BY gender, department
ORDER BY  department;

SELECT gender, job_title, count(*) AS count 
FROM hr
WHERE term_date = '0000-00-00'
GROUP BY gender, job_title
ORDER BY job_title;

-- What is the distribution of jobtitles across the company?
SELECT job_title, count(*) AS count
FROM hr
WHERE term_date = '0000-00-00'
group by job_title
order by count DESC;

-- Which department has the highest turnover rate?
SELECT department,
total_count,
terminated_count,
terminated_count / total_count AS termination_rate
FROM(
SELECT department,
count(*) as total_count,
SUM(CASE
WHEN term_date <> '0000-00-00' and term_date <= curdate() THEN 1 ELSE 0 END
) AS terminated_count
FROM hr
GROUP BY department
) AS subquery
ORDER BY termination_rate DESC;

-- What is the distribution of employees across locations by city and state?
SELECT location_city, count(*) as count 
FROM hr 
WHERE term_date = '0000-00-00' 
GROUP BY location_city
ORDER BY count DESC;

SELECT location_state, count(*) as count 
FROM hr 
WHERE term_date = '0000-00-00' 
GROUP BY location_state
ORDER BY count DESC;

-- How has the company's employee count changed overtime based on the hire and term dates?
SELECT 
	year,
	hires,
	terminates,
	hires - terminates AS net_change,
	round((hires - terminates)- / hires *100, 2) AS net_change_percent
 FROM(
 SELECT year(hire_date) as year,
 count(*) as hires,
 SUM(
 CASE 
 WHEN term_date <> '0000-00-00' and term_date <= curdate() THEN 1 ELSE 0 END
 ) AS terminates
 FROM hr
 GROUP BY YEAR(hire_date)
 ) AS subquery
 ORDER BY year ASC;

-- What is the tenure distrinution for each department?
SELECT department,
round(avg(datediff(term_date, hire_date)/365),0) AS avg_tenure
FROM hr
WHERE term_date <= curdate() AND term_date <> '0000-00-00'
GROUP BY department; 