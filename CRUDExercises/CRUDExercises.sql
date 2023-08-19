USE SoftUni
GO


-- PROBLEM 02
SELECT * FROM Departments
GO


-- PROBLEM 03
SELECT Name FROM Departments
GO


-- PROBLEM 04
SELECT FirstName, LastName, Salary FROM Employees
GO


-- PROBLEM 05
SELECT FirstName, MiddleName, LastName FROM Employees
GO


-- PROBLEM 06
SELECT CONCAT(FirstName, '.', LastName, '@', 'softuni.bg')
	AS [Full Email Address]
	FROM Employees
GO


-- PROBLEM 07
SELECT DISTINCT Salary FROM Employees
GO


-- PROBLEM 08
SELECT * 
	FROM Employees
	WHERE JobTitle = 'Sales Representative'
GO


-- PROBLEM 09
SELECT FirstName, LastName, JobTitle
	FROM Employees
	WHERE Salary BETWEEN 20000 AND 30000
GO


-- PROBLEM 10
SELECT CONCAT(FirstName, ' ', MiddleName, ' ', LastName)
	AS [Full Name]
	FROM Employees
	WHERE Salary IN (25000, 14000, 12500, 23600)
GO


-- PROBLEM 11
SELECT FirstName, LastName
	FROM Employees
	WHERE ManagerID IS NULL
GO


-- PROBLEM 12
SELECT FirstName, LastName, Salary
	FROM Employees
	WHERE Salary > 50000
	ORDER BY Salary DESC
GO


-- PROBLEM 13
SELECT TOP (5) FirstName, LastName
	FROM Employees
	ORDER BY Salary DESC
GO


-- PROBLEM 14
SELECT FirstName, LastName
	FROM Employees
	WHERE DepartmentID != 4
GO


-- PROBLEM 15
SELECT *
	FROM Employees
	ORDER BY Salary DESC,
	FirstName ASC,
	LastName DESC,
	MiddleName ASC
GO

-- PROBLEM 16
CREATE VIEW V_EmployeesSalaries AS
	SELECT FirstName, LastName, Salary
	FROM Employees
GO


-- PROBLEM 17
CREATE VIEW V_EmployeeNameJobTitle AS
	SELECT CONCAT(FirstName, ' ', MiddleName, ' ', LastName)
	AS [Full Name],
	JobTitle
	FROM Employees
GO


-- PROBLEM 18
SELECT DISTINCT JobTitle
	FROM Employees
GO


-- PROBLEM 19
SELECT TOP (10) *
	FROM Projects
	ORDER BY StartDate,
	[Name]
GO


-- PROBLEM 20
SELECT TOP (7) FirstName, LastName, HireDate
	FROM Employees
	ORDER BY HireDate DESC
GO


-- PROBLEM 21
SELECT DepartmentID
	FROM Departments
	WHERE [Name] IN ('Engineering', 'Tool Design', 'Marketing', 'Information Services')
GO

UPDATE Employees
	SET Salary *= 1.12
	WHERE DepartmentID IN (1, 2, 4, 11)
	
SELECT Salary
	FROM Employees
GO


-- PROBLEM 22
USE [Geography]
GO

SELECT PeakName
	FROM Peaks
	ORDER BY PeakName 
GO


-- PROBLEM 23
SELECT TOP (30) CountryName, [Population]
	FROM Countries
	WHERE ContinentCode = 'EU'
	ORDER BY [Population] DESC,
	CountryName ASC
GO


-- PROBLEM 24
SELECT CountryName, CountryCode, 
		CASE CurrencyCode
		WHEN 'EUR' THEN 'Euro'
		ELSE 'Not Euro'
		END
		AS Currency
	FROM Countries
	ORDER BY CountryName
GO


-- PROBLEM 25
USE Diablo
GO

SELECT Name
	FROM Characters
	ORDER BY [Name]