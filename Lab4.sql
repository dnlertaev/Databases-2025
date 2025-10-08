-- Create tables
CREATE TABLE employees (
 employee_id SERIAL PRIMARY KEY,
 first_name VARCHAR(50),
 last_name VARCHAR(50),
 department VARCHAR(50),
 salary NUMERIC(10,2),
 hire_date DATE,
 manager_id INTEGER,
 email VARCHAR(100)
);
CREATE TABLE projects (
 project_id SERIAL PRIMARY KEY,
 project_name VARCHAR(100),
 budget NUMERIC(12,2),
 start_date DATE,
 end_date DATE,
 status VARCHAR(20)
);
CREATE TABLE assignments (
 assignment_id SERIAL PRIMARY KEY,
 employee_id INTEGER REFERENCES employees(employee_id),
 project_id INTEGER REFERENCES projects(project_id),
 hours_worked NUMERIC(5,1),
 assignment_date DATE
);
-- Insert sample data
INSERT INTO employees (first_name, last_name, department,
salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
'lisa.a@company.com');
INSERT INTO projects (project_name, budget, start_date,
end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30',
'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');
INSERT INTO assignments (employee_id, project_id,
hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');

-- Task 1.1
SELECT
  e.employee_id,
  CONCAT(e.first_name, ' ', e.last_name) AS full_name,
  e.department,
  e.salary
FROM employees e;

-- Task 1.2
SELECT DISTINCT department
FROM employees
WHERE department IS NOT NULL;

-- Task 1.3
SELECT
  p.project_id,
  p.project_name,
  p.budget,
  CASE
    WHEN p.budget > 150000 THEN 'Large'
    WHEN p.budget BETWEEN 100000 AND 150000 THEN 'Medium'
    ELSE 'Small'
  END AS budget_category
FROM projects p;

-- Task 1.4
SELECT
  CONCAT(first_name, ' ', last_name) AS full_name,
  COALESCE(email, 'No email provided') AS email_shown
FROM employees;

-- Task 2.1
SELECT *
FROM employees
WHERE hire_date > DATE '2020-01-01';

-- Task 2.2
SELECT *
FROM employees
WHERE salary BETWEEN 60000 AND 70000;

-- Task 2.3
SELECT *
FROM employees
WHERE last_name ILIKE 'S%' OR last_name ILIKE 'J%';

-- Task 2.4
SELECT *
FROM employees
WHERE manager_id IS NOT NULL
  AND department = 'IT';

-- Task 3.1
SELECT
  CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS name_upper,
  LENGTH(last_name) AS last_name_len,
  SUBSTRING(email FROM 1 FOR 3) AS email_prefix
FROM employees;

-- Task 3.2
SELECT
  CONCAT(first_name, ' ', last_name) AS full_name,
  salary AS annual_salary,
  ROUND(salary / 12.0, 2) AS monthly_salary,
  ROUND(salary * 0.10, 2) AS raise_10pct
FROM employees;

-- Task 3.3
SELECT
  FORMAT(
    'Project: %s - Budget: $%s - Status: %s',
    project_name,
    TO_CHAR(budget, 'FM999,999,999,990.00'),
    status
  ) AS project_summary
FROM projects;

-- Task 3.4
SELECT
  CONCAT(first_name, ' ', last_name) AS full_name,
  EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date))::int AS years_with_company
FROM employees;

-- Task 4.1
SELECT
  department,
  AVG(salary)::numeric(12,2) AS avg_salary
FROM employees
GROUP BY department;

-- Task 4.2
SELECT
  p.project_id,
  p.project_name,
  COALESCE(SUM(a.hours_worked), 0) AS total_hours
FROM projects p
LEFT JOIN assignments a ON a.project_id = p.project_id
GROUP BY p.project_id, p.project_name
ORDER BY p.project_id;

-- Task 4.3
SELECT
  department,
  COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;

-- Task 4.4
SELECT
  MAX(salary) AS max_salary,
  MIN(salary) AS min_salary,
  SUM(salary) AS total_payroll
FROM employees;

-- Task 5.1 (UNION)
-- Show employee_id, full_name, salary
SELECT
  e.employee_id,
  CONCAT(e.first_name, ' ', e.last_name) AS full_name,
  e.salary
FROM employees e
WHERE e.salary > 65000

UNION

SELECT
  e.employee_id,
  CONCAT(e.first_name, ' ', e.last_name) AS full_name,
  e.salary
FROM employees e
WHERE e.hire_date > DATE '2020-01-01'
ORDER BY employee_id;

-- Task 5.2 (INTERSECT): IT AND salary > 65000
SELECT employee_id
FROM employees
WHERE department = 'IT'

INTERSECT

SELECT employee_id
FROM employees
WHERE salary > 65000;

-- Task 5.3 (EXCEPT): employees NOT assigned to any projects
SELECT e.employee_id
FROM employees e

EXCEPT

SELECT a.employee_id
FROM assignments a
ORDER BY employee_id;

-- Task 6.1 (EXISTS): employees with at least one assignment
SELECT e.*
FROM employees e
WHERE EXISTS (
  SELECT 1
  FROM assignments a
  WHERE a.employee_id = e.employee_id
);

-- Task 6.2 (IN): employees working on 'Active' projects
SELECT DISTINCT e.*
FROM employees e
WHERE e.employee_id IN (
  SELECT a.employee_id
  FROM assignments a
  WHERE a.project_id IN (
    SELECT p.project_id
    FROM projects p
    WHERE p.status = 'Active'
  )
);

-- Task 6.3 (ANY): salary > ANY salary in Sales dept
SELECT e.*
FROM employees e
WHERE e.salary > ANY (
  SELECT salary
  FROM employees
  WHERE department = 'Sales'
);

-- Task 7.1:
-- name, department, avg hours across assignments, rank within dept by salary
WITH emp_hours AS (
  SELECT
    a.employee_id,
    AVG(a.hours_worked) AS avg_hours
  FROM assignments a
  GROUP BY a.employee_id
)
SELECT
  e.employee_id,
  CONCAT(e.first_name, ' ', e.last_name) AS full_name,
  e.department,
  COALESCE(h.avg_hours, 0) AS avg_hours,
  RANK() OVER (PARTITION BY e.department ORDER BY e.salary DESC) AS salary_rank_in_dept
FROM employees e
LEFT JOIN emp_hours h ON h.employee_id = e.employee_id
ORDER BY e.department, salary_rank_in_dept, e.employee_id;

-- Task 7.2:
-- projects with total hours > 150; show project name, total hours, number of employees
SELECT
  p.project_name,
  SUM(a.hours_worked) AS total_hours,
  COUNT(DISTINCT a.employee_id) AS employee_count
FROM projects p
JOIN assignments a ON a.project_id = p.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150
ORDER BY total_hours DESC;

-- Task 7.3:
-- departments: total employees, avg salary, highest paid employee name
-- (Use GREATEST/LEAST somewhere: demo comparing avg to simple band)
WITH dept_stats AS (
  SELECT
    department,
    COUNT(*) AS total_employees,
    AVG(salary)::numeric(12,2) AS avg_salary,
    MAX(salary) AS max_salary
  FROM employees
  GROUP BY department
),
highest_paid AS (
  SELECT DISTINCT ON (department)
    department,
    CONCAT(first_name, ' ', last_name) AS highest_paid_name,
    salary
  FROM employees
  ORDER BY department, salary DESC, last_name, first_name
)
SELECT
  ds.department,
  ds.total_employees,
  ds.avg_salary,
  hp.highest_paid_name,
  -- illustrative use of GREATEST/LEAST to band avg salary into a clamped range
  GREATEST(50000, LEAST(ds.avg_salary, 150000)) AS avg_salary_clamped
FROM dept_stats ds
JOIN highest_paid hp USING (department)
ORDER BY ds.department;

