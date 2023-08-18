CREATE TABLE People
	(
		Id INT PRIMARY KEY IDENTITY,
		[Name] NVARCHAR(200) NOT NULL,
		Picture VARBINARY(MAX),
		Height DECIMAL(5,2),
		[Weight] DECIMAL(5,2),
		Gender CHAR(1) NOT NULL,
		Birthdate DATETIME2 NOT NULL,
		Biography NVARCHAR(MAX)
	)

INSERT INTO People ([Name], Picture, Height, [Weight], Gender, Birthdate, Biography)
	VALUES
	('Niki', NULL, 1.75, 76.00, 'm', '06-13-1991', NULL),
	('Kiki', NULL, 1.70, 55.00, 'f', '06-13-1991', NULL),
	('Piki', NULL, 1.75, 80.00, 'm', '06-13-1991', NULL),
	('Viki', NULL, 1.75, 76.00, 'f', '06-13-1991', NULL),
	('Lili', NULL, 1.79, 49.00, 'f', '06-13-1991', NULL)