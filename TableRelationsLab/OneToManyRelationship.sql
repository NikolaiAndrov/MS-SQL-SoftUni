CREATE TABLE Manufacturers
	(
		ManufacturerID INT PRIMARY KEY IDENTITY,
		[Name] NVARCHAR(50) NOT NULL,
		EstablishedOn DATE NOT NULL
	)

INSERT INTO Manufacturers ([Name], EstablishedOn)
	VALUES
	('BMW', '1916-03-07'),
	('Tesla', '2003-01-01'),
	('Lada', '1966-05-01')
	

CREATE TABLE Models
	(
		ModelID INT PRIMARY KEY NOT NULL,
		[Name] NVARCHAR(50) NOT NULL,
		ManufacturerID INT REFERENCES Manufacturers(ManufacturerID) NOT NULL
	)

INSERT INTO Models(ModelID, [Name], ManufacturerID)
	VALUES
	(101, 'X1', 1),
	(102, 'i6', 1),
	(103, 'Model S', 2),
	(104, 'Model X', 2),
	(105, 'Model 3', 2),
	(106, 'Nova', 3)