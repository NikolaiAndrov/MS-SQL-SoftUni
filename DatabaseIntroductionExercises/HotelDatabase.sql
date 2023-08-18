CREATE DATABASE HotelDatabase

USE HotelDatabase

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
	(1, 'first Name', 'Last Name', 'Engineer', NULL),
	(2, 'first Name', 'Last Name', 'Engineer', NULL),
	(3, 'first Name', 'Last Name', 'Engineer', NULL)


CREATE TABLE Customers
	(
		AccountNumber INT PRIMARY KEY NOT NULL,
		FirstName NVARCHAR(50) NOT NULL,
		LastName NVARCHAR(50) NOT NULL,
		PhoneNumber NVARCHAR(19) NOT NULL,
		EmergencyName NVARCHAR(50),
		EmergencyNumber SMALLINT,
		Notes NVARCHAR(50)
	)

INSERT INTO Customers
	VALUES
	(1, 'first Name', 'Last Name', '+359888888888', NULL, NULL, NULL),
	(2, 'first Name', 'Last Name', '+359888888888', NULL, NULL, NULL),
	(3, 'first Name', 'Last Name', '+359888888888', NULL, NULL, NULL)


CREATE TABLE RoomStatus
	(
		RoomStatus NVARCHAR(50) NOT NULL,
		Notes NVARCHAR(MAX)
	)

INSERT INTO RoomStatus
	VALUES
	('Free', NULL),
	('Busy', NULL),
	('Preparing', NULL)


CREATE TABLE RoomTypes
	(
		RoomType NVARCHAR(50),
		Notes NVARCHAR(MAX)
	)

INSERT INTO RoomTypes
	VALUES
	('Single bed', NULL),
	('Double bed', NULL),
	('Apartment', NULL)
	

CREATE TABLE BedTypes
	(
		BedType NVARCHAR(50),
		Notes NVARCHAR(MAX)
	)

INSERT INTO BedTypes
	VALUES
	('Single bed', NULL),
	('Double bed', NULL),
	('Triple bed', NULL)


CREATE TABLE Rooms
	(
		RoomNumber INT PRIMARY KEY NOT NULL,
		RoomType NVARCHAR(50) NOT NULL,
		BedType NVARCHAR(50) NOT NULL,
		Rate DECIMAL(18,2) NOT NULL,
		RoomStatus NVARCHAR(50) NOT NULL,
		Notes NVARCHAR(MAX)
	)

INSERT INTO Rooms
	VALUES
	(1, 'Single bed', 'Single bed', 50, 'Free', NULL),
	(2, 'Double bed', 'Double bed', 50, 'Free', NULL),
	(3, 'Apartment bed', 'Triple bed', 50, 'Free', NULL)


CREATE TABLE Payments
	(
		Id INT PRIMARY KEY NOT NULL,
		EmployeeId INT NOT NULL,
		PaymentDate DATETIME2 NOT NULL,
		AccountNumber INT NOT NULL,
		FirstDateOccupied DATETIME2 NOT NULL,
		LastDateOccupied DATETIME2 NOT NULL,
		TotalDays SMALLINT NOT NULL,
		AmountCharged DECIMAL(18,2) NOT NULL,
		TaxRate DECIMAL(18,2) NOT NULL,
		TaxAmount DECIMAL(18,2) NOT NULL,
		PaymentTotal DECIMAL(18,2) NOT NULL,
		Notes NVARCHAR(MAX)
	)

INSERT INTO Payments
	VALUES
	(1, 1, '2023-06-01', 1, '2023-06-01', '2023-06-10', 10, 500, 50, 50, 500, NULL),
	(2, 2, '2023-06-01', 2, '2023-06-01', '2023-06-10', 10, 500, 50, 50, 500, NULL),
	(3, 3, '2023-06-01', 3, '2023-06-01', '2023-06-10', 10, 500, 50, 50, 500, NULL)


CREATE TABLE Occupancies
	(
		Id INT PRIMARY KEY NOT NULL,
		EmployeeId INT NOT NULL,
		DateOccupied DATETIME2 NOT NULL,
		AccountNumber INT NOT NULL,
		RoomNumber INT NOT NULL,
		RateApplied DECIMAL(18,2) NOT NULL,
		PhoneCharge DECIMAL(18,2),
		Notes NVARCHAR(MAX)
	)

INSERT INTO Occupancies
	VALUES
	(1, 1, '2023-06-01', 1, 1, 50, NULL, NULL),
	(2, 2, '2023-06-01', 2, 2, 50, NULL, NULL),
	(3, 3, '2023-06-01', 3, 3, 50, NULL, NULL)