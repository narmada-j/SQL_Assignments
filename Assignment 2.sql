/*
*********************************************************************************************************************************************
															Querying Data 
*********************************************************************************************************************************************
*/
/*
****************************************
			Dataset Description 
****************************************
*/
use Employee;
-- Describe Tables
DESCRIBE Location;
DESCRIBE Departments;
DESCRIBE Employees;
-- Values in Tables
select * from departments order by department_id;
select * from Location order by location_id;
select * from Employees order by employee_id;

/*
************************************
	 Clauses & Operators 
************************************
*/
-- DISTINCT VALUES:  A query to retrieve distinct salaries from the Employees table.
SELECT DISTINCT salary FROM Employees;

-- ALIAS (AS):  Provide aliases for the "age" and "salary" columns as "Employee_Age" and "Employee_Salary", respectively.  
SELECT age AS Employee_Age, salary AS Employee_Salary
FROM Employees;

-- WHERE CLAUSE & OPERATORS: Retrieve employees with a salary greater than ₹50000 and hired before 2016-01-01.  
SELECT * FROM Employees
WHERE salary > 50000 AND hire_date < '2016-01-01';

 -- WHERE CLAUSE & OPERATORS:	Find the employee whose designation is missing and fill it with "Data Scientist".  
SELECT employee_name, designation FROM Employees
WHERE designation IS NULL  OR designation = '';
SET SQL_SAFE_UPDATES = 0;
UPDATE Employees set designation='Data Scientist'
WHERE designation IS NULL  OR designation = ''; 
SELECT employee_name, designation FROM Employees
WHERE designation = 'Data Scientist';

/*
************************************
	 Sorting and Grouping Data 
************************************
*/
-- ORDER BY:	Find employees sorted by department ID in ascending order and salary in descending order.  
SELECT * FROM Employees 
ORDER BY department_id, salary DESC;

-- LIMIT:	Display the first 5 employees hired in the year 2018. 
SELECT * FROM Employees 
WHERE YEAR(hire_date) = '2018' 
ORDER BY hire_date LIMIT 5;

--  AGGREGATE FUNCTIONS:	Calculate the sum of all salaries in the Finance department.  
SELECT department_id,SUM(salary) FROM Employees
WHERE department_id=1
GROUP BY department_id; 								-- 1 is Finance depatment id

--  AGGREGATE FUNCTIONS:	Find the minimum age among all employees.
SELECT MIN(age) FROM Employees;

-- GROUP BY:	List the maximum salary for each location.  
SELECT location_id,MAX(salary) FROM Employees
GROUP BY location_id;

-- GROUP BY:	Calculate the average salary for each designation containing the word 'Analyst'
SELECT Designation, AVG(salary) FROM Employees
WHERE designation like '%Analyst%'
GROUP BY designation;

-- HAVING:	Find departments with less than 3 employees.  
SELECT department_id,count(department_id) FROM Employees
GROUP BY department_id
HAVING count(department_id) > 3;

-- HAVING:	Find locations with female employees whose average age is below 30.  
SELECT Location_id,AVG(age) AS Avg_Age FROM Employees 
WHERE gender = 'F'
GROUP BY Location_id
HAVING Avg_Age < 30;

/*
************************************
				Joins
************************************
*/
-- INNER JOIN:	List employee names, their designations, and department names where employees are assigned to a department.  
SELECT e.Employee_name, e.Designation, d.Department_name From Employees e
INNER JOIN departments d ON e.department_id = d.department_id;

-- LEFT JOIN:	List all departments along with the total number of employees in each department, including departments with no employees.  
SELECT d.Department_name, COUNT(e.employee_id) AS Total_Employees FROM Departments d
LEFT JOIN Employees e ON d.department_id = e.department_id
GROUP BY d.Department_name;

-- RIGHT JOIN:	Display all locations along with the names of employees assigned to each location. If no employees are assigned to a location, display NULL for employee name. 
SELECT l.Location_name, e.Employee_name  FROM Employees e
RIGHT JOIN location l ON e.location_id = l.location_id;

SELECT l.Location_name, GROUP_CONCAT(e.Employee_name) AS Employee_Name FROM Employees e
RIGHT JOIN location l ON e.location_id = l.location_id
GROUP BY l.Location_name;

-- CROSS JOIN:	Show all possible combinations of departments and locations
SELECT d.Department_name, l.Location_name FROM departments d
CROSS JOIN location l;

-- SELF JOIN:	Show pairs of employees working in the same department, excluding self-pairs.
SELECT e1.Employee_name, e2.Employee_name, e1.Department_id
FROM Employees e1
JOIN Employees e2 ON e1.Department_id = e2.Department_id
AND e1.Employee_id <> e2.Employee_id -- exclude self pairs
ORDER BY e1.Department_id, e1.Employee_id;

/*
************************************
		   Windows function
************************************
*/
-- Write a window function query to rank employees by salary using rank()
SELECT Employee_name, Designation,Salary, RANK() OVER(ORDER BY Salary DESC) AS Emp_Rank
From Employees ORDER BY Emp_Rank;

-- Write a window function query to rank employees by salary within each department using DENSE_RANK() 
SELECT Employee_Name, Designation,Department_Name, Salary, 
DENSE_RANK() OVER(PARTITION BY E.Department_id ORDER BY Salary DESC) AS Emp_Dense_Rank
From Employees E INNER JOIN Departments D on E.Department_id= D.Department_id;

-- Write a window function query, Running total salary by department
SELECT Employee_Name, Designation,Department_Name, Salary, SUM(Salary) OVER(PARTITION BY E.Department_id) AS Tot_Salary
From Employees E INNER JOIN Departments D on E.Department_id= D.Department_id;

-- Another method
SELECT Employee_Name, Designation, Department_Name, Salary,
SUM(Salary) OVER (PARTITION BY E.Department_id ORDER BY Salary ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Tot_Salary
FROM Employees E INNER JOIN Departments D ON E.Department_id = D.Department_id;
