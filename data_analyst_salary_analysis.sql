select * from salaries;
describe salaries;

-- 1. what are the jobs related to data analysis?
select distinct job_title
from salaries
where job_title like '%data analyst%'
order by job_title;

-- 2. how much the average salary of jobs related to data analysis?
select job_title,
	AVG(salary_in_usd) as avg_salary_usd,
    AVG((salary_in_usd)*15500) as avg_salary_rp
from salaries
where job_title like '%data analyst%'
group by job_title
order by avg_salary_usd desc;

-- 3. what are the experience levels and employment type for the position of data analyst,
-- and how much the average salary received based on those criteria?
select experience_level,
	employment_type,
	AVG(salary_in_usd) as average_salary
from salaries
where job_title = 'data analyst'
group by 1, 2
order by average_salary;

-- 4. which country has the highest average salary for Full-time data analyst position?
select company_location,
	AVG(salary_in_usd) as average_salary
from salaries
where
	job_title = 'data analyst'
    and employment_type = 'FT'
group by company_location
order by average_salary desc
LIMIT 1;

-- 5. how do data analyst salary differ in the US based on company size and remote ratio?
select company_size,
	CASE
		when remote_ratio = 100 then 'Remote Company'
        when remote_ratio = 0 then 'Onsite Company'
        else 'Hybrid Company'
	END as work_company_type,
    COUNT(*) as total_companies,
    AVG(salary_in_usd) as average_salary
from salaries
where company_location = 'US'
	and job_title = 'data analyst'
    and employment_type = 'FT'
group by work_company_type, company_size
order by
	CASE company_size
		when 'S' then 1
        when 'M' then 2
        when 'L' then 3
	END;

-- 6. what is the percentage increase in salary for sata analyst year by year?
select
	company_size, work_year,
    AVG(salary_in_usd) as average_salary,
    LAG(AVG(salary_in_usd), 1, 0)
    OVER (partition by company_size order by work_year) as prev_avg_salary,
    AVG(salary_in_usd) - LAG(AVG(salary_in_usd), 1, 0)
    OVER (partition by company_size order by work_year) as salary_increase,
    ROUND(
		(AVG(salary_in_usd) - LAG(AVG(salary_in_usd), 1, 0)
        OVER (partition by company_size order by work_year))
        / LAG(AVG(salary_in_usd), 1, 0) OVER (partition by company_size order by work_year) * 100, 2
    ) as percent_increase
from salaries
where company_location = 'US'
	and job_title = 'data analyst'
    and employment_type = 'FT'
group by company_size, work_year
order by
	CASE company_size
		when 'S' then 1
        when 'M' then 2
        when 'L' then 3
	END, work_year;