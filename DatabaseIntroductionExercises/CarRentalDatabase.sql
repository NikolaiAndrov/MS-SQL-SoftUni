CREATE DATABASE CarRental

USE CarRental

CREATE TABLE Categories
	(
		Id INT PRIMARY KEY NOT NULL,
		CategoryName NVARCHAR(50) NOT NULL,
		DailyRate DECIMAL(18,2) NOT NULL,
		WeeklyRate DECIMAL(18,2) NOT NULL,
		MonthlyRate DECIMAL(18,2) NOT NULL,
		WeekendRate DECIMAL(18,2) NOT NULL
	)


INSERT INTO Categories
	VALUES
	(1, 'First Category', 25, 150, 550, 60),
	(2, 'Second Category', 25, 150, 550, 60),
	(3, 'Third Category', 25, 150, 550, 60)


CREATE TABLE Cars
	(
		Id INT PRIMARY KEY NOT NULL,
		PlateNumber NVARCHAR(15) NOT NULL,
		Manufacturer NVARCHAR(50) NOT NULL,
		Model NVARCHAR(50) NOT NULL,
		CarYear SMALLINT NOT NULL,
		CategoryId INT NOT NULL,
		Doors TINYINT NOT NULL,
		Picture NVARCHAR(MAX),
		Condition NVARCHAR(50) NOT NULL,
		Available BIT NOT NULL
	)

INSERT INTO Cars
	VALUES
	(1, 'KH1234AT', 'BMW', '316i', 2000, 1, 4, NULL, 'Good', 1),
	(2, 'KH1254AT', 'BMW', '318i', 2000, 2, 4, NULL, 'Good', 1),
	(3, 'KH1235AT', 'BMW', '330i', 2000, 3, 4, NULL, 'Good', 1)


CREATE TABLE Employees
	(
		Id INT PRIMARY KEY NOT NULL,
		FirstName NVARCHAR(50) NOT NULL,
		LastName NVARCHAR(50) NOT NULL,
		Title NVARCHAR(50) NOT NULL,
		Notes NVARCHAR(MAX)
	)

INSERT INTO Employees
	VALUES 
	(1, 'FirstName', 'LastName', 'Engineer', NULL),
	(2, 'FirstName', 'LastName', 'Engineer', NULL),
	(3, 'FirstName', 'LastName', 'Engineer', NULL)


CREATE TABLE Customers
	(
		Id INT PRIMARY KEY NOT NULL,
		DriverLicenceNumber NVARCHAR(15) NOT NULL,
		FullName NVARCHAR(100) NOT NULL,
		[Address] NVARCHAR(100) NOT NULL,
		City NVARCHAR(50) NOT NULL,
		ZIPCode SMALLINT NOT NULL,
		Notes NVARCHAR(MAX)
	)

INSERT INTO Customers
	VALUES
	(1, '12LDJWJ492JSI', 'FirtsName LastName', 'Yahinovo', 'Dupnitsa', 2622, NULL),
	(2, '32LDJWJ492JSI', 'FirtsName LastName', 'Yahinovo', 'Dupnitsa', 2622, NULL),
	(3, '32LDJWJ492JSI', 'FirtsName LastName', 'Yahinovo', 'Dupnitsa', 2622, NULL)


CREATE TABLE RentalOrders
	(
		Id INT PRIMARY KEY NOT NULL,
		EmployeeId INT NOT NULL,
		CustomerId INT NOT NULL,
		CarId INT NOT NULL,
		TankLevel TINYINT NOT NULL,
		KilometrageStart INT NOT NULL,
		KilometrageEnd INT NOT NULL,
		TotalKilometrage INT NOT NULL,
		StartDate DATETIME2 NOT NULL,
		EndDate DATETIME2 NOT NULL,
		TotalDays SMALLINT NOT NULL,
		RateApplied DECIMAL(18,2) NOT NULL,
		TaxRate DECIMAL(18,2) NOT NULL,
		OrderStatus NVARCHAR(50),
		Notes NVARCHAR(MAX)
	)

INSERT INTO RentalOrders
	VALUES
	(1, 1, 1, 1, 25, 150000, 160000, 10000, '2023-05-15', '2023-06-15', 30, 550, 18.30, 'Normal', NULL),
	(2, 2, 2, 2, 25, 150000, 160000, 10000, '2023-05-15', '2023-06-15', 30, 550, 18.30, 'Normal', NULL),
	(3, 3, 3, 3, 25, 150000, 160000, 10000, '2023-05-15', '2023-06-15', 30, 550, 18.30, 'Normal', NULL)