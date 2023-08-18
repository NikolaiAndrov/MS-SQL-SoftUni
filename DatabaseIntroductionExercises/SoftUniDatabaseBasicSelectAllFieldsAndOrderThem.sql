CREATE DATABASE SoftUniDatabase

USE SoftUniDatabase

CREATE TABLE Towns
	(
		Id INT PRIMARY KEY IDENTITY,
		[Name] NVARCHAR(50) NOT NULL, 
	)

INSERT INTO Towns
	VALUES
	('Sofia'),
	('Plovdiv'),
	('Varna'),
	('Burgas')

CREATE TABLE Addresses
	(
		Id INT PRIMARY KEY IDENTITY,
		AddressText NVARCHAR(150) NOT NULL,
		TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL
	)


INSERT INTO Addresses
	VALUES
	('Some Street N100' , 1),
	('Some Street N100' , 2),
	('Some Street N100' , 3),
	('Some Street N100' , 4)

CREATE TABLE Departments
	(
		Id INT PRIMARY KEY IDENTITY,
		[Name] NVARCHAR(100)
	)

INSERT INTO Departments
	VALUES
	('Engineering'),
	('Sales'),
	('Marketing'),
	('Software Development'),
	('Quality Assurance')

CREATE TABLE Employees
	(
		Id INT PRIMARY KEY IDENTITY,
		FirstName NVARCHAR(50) NOT NULL,
		MiddleName NVARCHAR(50) NOT NULL,
		LastName NVARCHAR(50) NOT NULL,
		JobTitle NVARCHAR(50) NOT NULL,
		DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL,
		HireDate DATETIME2 NOT NULL,
		Salary DECIMAL(18,2) NOT NULL,
		AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL
	)


INSERT INTO Employees (FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary, AddressId)
	VALUES
	('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500.00, 1),
	('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000.00, 2),
	('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016-08-28', 525.25, 3),
	('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '2007-12-09', 3000.00, 4),
	('Peter', 'Pan', 'Pan', 'Intern', 3, '2016-08-28', 599.88, 1)


SELECT * FROM Towns
	ORDER BY Name

SELECT * FROM Departments
	ORDER BY Name

SELECT * FROM Employees
	ORDER BY Salary DESC