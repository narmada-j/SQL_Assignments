/*
********************************************************************************************************************
													DDL Commands
 *******************************************************************************************************************
*/
/*
************************
 Table Creation (CREATE) 
 ***********************
*/
-- create a database named  “employee”
CREATE DATABASE Employee;

-- USE CREATED DATABASE
USE Employee;

-- create Table Departments
CREATE TABLE Departments(
department_id INT PRIMARY KEY,
department_name VARCHAR(100)
);
-- show created table structure
DESCRIBE Departments;

-- create Table Location
CREATE TABLE Location(
location_id INT PRIMARY KEY,
location VARCHAR(30)
);
-- show created table structure
DESCRIBE Location;

-- create Table Employees
CREATE TABLE Employees(
employee_id INT PRIMARY KEY,
employee_name VARCHAR(50),
gender ENUM('M','F'),
age INT,
hire_date DATE,
designation VARCHAR(100),
department_id INT,
location_id INT,
salary DECIMAL(10,2),
FOREIGN KEY (department_id) REFERENCES departments(department_id),
FOREIGN KEY (location_id) REFERENCES location(location_id)
);
-- show created table structure
DESCRIBE Employees;

/*
*************************
Table Alteration (ALTER)
*************************
*/
-- Add a new column named "email" to the Employees table 
ALTER TABLE Employees
ADD COLUMN email VARCHAR(100);
-- show created table structure
DESCRIBE Employees;

--  Modify the data type of the "designation" column in the Employees table
ALTER TABLE Employees
MODIFY COLUMN designation VARCHAR(250);
-- show created table structure
DESCRIBE Employees;

--   Drop the “age” column from the Employees table
ALTER TABLE Employees
DROP COLUMN age;
-- show created table structure
DESCRIBE Employees;

--   Rename the “hire_date” column to “date_of_joining”
ALTER TABLE Employees
RENAME COLUMN hire_date TO date_of_joining;
-- show created table structure
DESCRIBE Employees;

/*
*************************
Table Renaming (RENAME)
*************************
*/
--    Rename the "Departments" table to "Departments_Info". 
ALTER TABLE Departments
RENAME TO Departments_Info;
-- show tables in DB
SHOW TABLES;

--   Rename the "Location" table to "Locations".  
RENAME TABLE Location TO Locations;
-- show tables in DB
SHOW TABLES;

/*
****************************
Table Truncation (TRUNCATE)
****************************
*/
--  truncate the Employees table
TRUNCATE TABLE Employees;
-- show tables in DB
SHOW TABLES;

/*
*********************************
Database & Table Dropping (DROP)
*********************************
*/
-- drop the Employees table
DROP TABLE Employees;
-- show tables in DB
SHOW TABLES;

-- derop the “employee” database
DROP DATABASE Employee;
 
 /*
********************************************************************************************************************
													Constraints
 *******************************************************************************************************************
*/
 /*
**********************
  Database Recreation
**********************
*/
-- Drop database if it exists
DROP DATABASE IF EXISTS Employee;

-- Create new database
CREATE DATABASE Employee;

-- Switch to the new database
USE Employee;

 /*
*********************************************
  Departments Table Creation with constraint
*********************************************
*/
-- create Table Departments
CREATE TABLE Departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

-- show created table and its structure
SHOW TABLES;
DESCRIBE Departments;
 
  /*
*********************************************
  Location Table Creation with constraint
*********************************************
*/
-- create Table Location
CREATE TABLE Location(
location_id INT AUTO_INCREMENT PRIMARY KEY,
location VARCHAR(30) NOT NULL UNIQUE
);

-- show created table and its structure
SHOW TABLES;
DESCRIBE Location;

  /*
*********************************************
  Employees Table Creation with constraint
*********************************************
*/
-- create Table Employees
CREATE TABLE Employees(
employee_id INT PRIMARY KEY,
employee_name VARCHAR(50) NOT NULL,
gender ENUM('M','F'),
age INT CHECK(age >= 18),
hire_date DATE DEFAULT(CURRENT_DATE),
designation VARCHAR(100),
department_id INT,
location_id INT,
salary DECIMAL(10,2),
FOREIGN KEY (department_id) REFERENCES departments(department_id),
FOREIGN KEY (location_id) REFERENCES location(location_id)
);

-- show created table and its structure
SHOW TABLES;
DESCRIBE Employees;
