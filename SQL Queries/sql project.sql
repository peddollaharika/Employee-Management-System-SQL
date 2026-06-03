-- creating the database
create database EMS;

-- using the database
use EMS;


-- creating the tables
-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

-- observations:It includes Job_ID as Primary Key, and columns like jobdept, name, description, and salaryrange to store department, role, details, and salary range.
select*from JobDepartment ;

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- observations:This table links salary information with job roles using Job_ID foreign key, ensuring data consistency and automatically updating or deleting related records using cascading actions.
select*from SalaryBonus;

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- observation: REFERENCES JobDepartment(Job_ID) → connects employee to a valid job role
-- ON DELETE SET NULL → if a job is deleted, employee’s Job_ID becomes NULL
-- ON UPDATE CASCADE → updates Job_ID automatically if changed in JobDepartment
select*from Employee;

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- observations: This table maintains employee personal and job information, ensuring each employee is linked to a valid job role while preserving data integrity even when job roles are modified or deleted.
select*from Qualification;

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- observations: REFERENCES Employee(emp_ID) → ensures each leave belongs to a valid employee
-- ON DELETE CASCADE → if an employee is deleted, their leave records are also deleted automatically
-- ON UPDATE CASCADE → updates emp_ID automatically if changed in Employee tabl
select*from Leaves;

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- observations: emp_ID → Employee (CASCADE): deletes/updates payroll if employee changes
-- job_ID → JobDepartment (CASCADE): keeps job data consistent
-- salary_ID → SalaryBonus (CASCADE): updates salary changes automatically
-- leave_ID → Leaves (SET NULL): keeps payroll even if leave record is deleted
select*from Payroll;

-- 1. EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?
select count(distinct Emp_ID) from employee;
-- observation: they are 60 unique employes are there in th system

-- Which departments have the highest number of employees?
select jd.jobdept, count(e.Emp_ID)
from employee as e
join JobDepartment as jd
on e.Job_ID=jd.Job_ID
group by jd.jobdept;

-- observations: the finance and it departments has the highest employees(9).

-- What is the average salary per department?
SELECT 
    jd.jobdept,
    AVG(sb.amount) AS average_salary
FROM Employee as e
JOIN JobDepartment as jd ON e.Job_ID = jd.Job_ID
JOIN SalaryBonus as sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;

-- observations: the average salary for every department is between 62k to 84k.

-- Who are the top 5 highest-paid employees?
SELECT 
    e.emp_ID,
    e.firstname,
    e.lastname,
    sb.amount AS salary
FROM Employee as e
JOIN SalaryBonus as sb ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;

-- obdervations: The top 5 highest_paid employees are ingrid, john, grake, hank, kelly.

-- What is the total salary expenditure across the company?
select sum(amount)
from SalaryBonus;

-- observation: the total expenditure across the company is 4321000.

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?
SELECT 
    jobdept,
    COUNT(Job_ID) AS total_roles
FROM JobDepartment
GROUP BY jobdept;

-- observation: the roles of each department is in between 5 to 9.

-- What is the average salary range per department?
select jd.jobdept , avg(sb.amount) as avg_salary
from jobdepartment as jd
join SalaryBonus as sb
on jd.Job_ID= sb.Job_ID
group by jd.jobdept;

-- observations:This query joins JobDepartment and SalaryBonus tables to associate each department with its salary data.
-- It uses AVG() to calculate the average salary for each department after grouping with GROUP BY.
-- The result shows how salary ranges vary across departments, helping in compensation comparison.

-- Which job roles offer the highest salary?
select jd.name, sb.amount
from jobdepartment as jd
join SalaryBonus as sb
on jd.job_ID= sb.job_ID
order by sb.amount desc
limit 1;
-- This query joins JobDepartment and SalaryBonus tables to link each job role with its salary.
-- It sorts the salaries in descending order using ORDER BY to bring the highest-paying roles to the top.
-- The result helps identify which job roles offer the highest salaries in the organization.

-- Which departments have the highest total salary allocation?
select jd.jobdept, sum(sb.amount)
from employee as e
join jobdepartment as jd
on jd.Job_id=e.Job_ID
join SalaryBonus as sb
on jd.Job_ID= sb.Job_ID
group by jd.jobdept
order by sum(sb.amount) desc
limit 1;

-- This query joins Employee, JobDepartment, and SalaryBonus tables to associate each department with employee salaries.
-- It uses SUM() to calculate the total salary allocation per department and GROUP BY to aggregate department-wise.
-- The result highlights which departments receive the highest total salary budget, indicating larger workforce or higher pay levels.

-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?
select count(distinct Emp_ID)
from Qualification;
-- This query uses COUNT(DISTINCT Emp_ID) to count unique employees who have at least one qualification recorded.
-- Since an employee can have multiple qualifications, DISTINCT ensures each employee is counted only once.


-- Which positions require the most qualifications?
SELECT 
    Position,
    COUNT(Requirements) AS total_qualifications
FROM Qualification
GROUP BY Position
ORDER BY total_qualifications DESC;

-- Position and counts the number of qualifications required for each role using COUNT().
-- It then sorts the results in descending order using ORDER BY to identify positions with the most qualifications.

-- Which employees have the highest number of qualifications?
SELECT 
    e.emp_ID,
    e.firstname,
    COUNT(q.QualID) AS total_qualifications
FROM Employee as e
JOIN Qualification q ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID, e.firstname
ORDER BY total_qualifications DESC;

-- Employee and Qualification tables to link each employee with their qualifications.
-- It uses COUNT() with GROUP BY to calculate how many qualifications each employee has.


-- 4. LEAVE AND ABSENCE PATTERNS
-- Which year had the most employees taking leaves?leaves
select year(date) as leave_year, 
count(distinct emp_ID) as total_employees
from Leaves
group by leave_year
order by total_employees;
-- the year from leave records and counts the number of employees taking leaves each year.
-- It uses DISTINCT to ensure each employee is counted only once per year.
-- The result identifies the year with the highest employee leave activity.


-- What is the average number of leave days taken by its employees per department?

SELECT 
    jd.jobdept,
    COUNT(l.leave_ID)  / COUNT(DISTINCT e.emp_ID) AS avg_leaves_per_employee
FROM Employee as e
LEFT JOIN Leaves as l ON e.emp_ID = l.emp_ID
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;

-- This query calculates the total number of leaves and divides it by the number of employees in each department.
-- It uses COUNT and DISTINCT to ensure correct employee count.
-- The result gives the average number of leaves taken per employee in each department.

-- Which employees have taken the most leaves?

SELECT 
    e.emp_ID,
    e.firstname,
    COUNT(l.leave_ID) AS total_leaves
FROM Employee e
JOIN Leaves l ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID, e.firstname
ORDER BY total_leaves DESC;

-- This query joins Employee and Leaves tables to include employee names along with leave counts.
-- It groups the data by employee and counts the number of leaves taken.
-- The result shows employee names along with their leave count in descending order.


-- What is the total number of leave days taken company-wide?
SELECT COUNT(*) AS total_leave_days
FROM Leaves;

-- This query counts all leave records in the Leaves table using COUNT(*).
-- Each record represents a leave taken by an employee.
-- The result shows the total number of leave days taken across the entire company.


-- How do leave days correlate with payroll amounts?
SELECT 
    e.emp_ID,
    e.firstname,
    COUNT(l.leave_ID) AS total_leaves,
    p.total_amount
FROM Employee e
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
JOIN Payroll p ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID, e.firstname, p.total_amount
ORDER BY total_leaves DESC;
-- This query joins Employee, Leaves, and Payroll tables to combine leave and salary data.
-- It uses LEFT JOIN to include employees with no leaves and COUNT to calculate leave count.
-- The result helps analyze how leave patterns affect payroll amounts.


-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
SELECT 
    YEAR(date) AS year,
    MONTH(date) AS month,
    SUM(total_amount) AS total_monthly_payroll
FROM Payroll
GROUP BY YEAR(date), MONTH(date)
ORDER BY year, month;
-- This query groups payroll data by year and month using date functions.
-- It calculates total salary paid each month using SUM.
-- The result shows monthly payroll trends across the organization.


-- What is the average bonus given per department?
SELECT 
    jd.jobdept,
    AVG(sb.bonus) AS avg_bonus
FROM JobDepartment as jd
JOIN SalaryBonus as sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;

-- This query joins JobDepartment and SalaryBonus tables to associate each department with bonus values.
-- It uses AVG() to calculate the average bonus for each department.
-- The result helps compare bonus distribution across departments.

-- Which department receives the highest total bonuses?
SELECT 
    jd.jobdept,
    SUM(sb.bonus) AS total_bonus
FROM Employee e
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY total_bonus DESC
LIMIT 1;
-- This query calculates total bonuses for each department using SUM.
-- It joins employee, department, and salary tables for accurate aggregation.
-- The result identifies the department receiving the highest bonus.

-- What is the average value of total_amount after considering leave deductions?
SELECT 
    AVG(total_amount) AS avg_payroll_after_deductions
FROM Payroll;
-- This query calculates the average payroll amount using AVG from the Payroll table.
-- The total_amount already reflects deductions such as leaves.
-- The result shows the average salary paid after adjustments.