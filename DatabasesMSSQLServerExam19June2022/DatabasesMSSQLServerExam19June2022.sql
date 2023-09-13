-- P01
CREATE TABLE Owners
	(
		Id INT PRIMARY KEY IDENTITY,
		[Name] VARCHAR(50) NOT NULL,
		PhoneNumber VARCHAR(15) NOT NULL,
		[Address] VARCHAR(50)
	)

CREATE TABLE AnimalTypes
	(
		Id INT PRIMARY KEY IDENTITY,
		AnimalType VARCHAR(30) NOT NULL
	)

CREATE TABLE Cages
	(
		Id INT PRIMARY KEY IDENTITY,
		AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
	)

CREATE TABLE Animals
	(
		Id INT PRIMARY KEY IDENTITY,
		[Name] VARCHAR(30) NOT NULL,
		BirthDate DATE NOT NULL,
		OwnerId INT FOREIGN KEY REFERENCES Owners(Id),
		AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
	)

CREATE TABLE AnimalsCages
	(
		CageId INT FOREIGN KEY REFERENCES Cages(Id) NOT NULL,
		AnimalId INT FOREIGN KEY REFERENCES Animals(Id) NOT NULL
		PRIMARY KEY (CageId, AnimalId)
	)

CREATE TABLE VolunteersDepartments
	(
		Id INT PRIMARY KEY IDENTITY,
		DepartmentName VARCHAR(30) NOT NULL
	)

CREATE TABLE Volunteers
	( 
		Id INT PRIMARY KEY IDENTITY,
		[Name] VARCHAR(50) NOT NULL,
		PhoneNumber VARCHAR(15) NOT NULL,
		[Address] VARCHAR(50),
		AnimalId INT FOREIGN KEY REFERENCES Animals(Id),
		DepartmentId INT FOREIGN KEY REFERENCES VolunteersDepartments(Id) NOT NULL
	)

-- P02
INSERT INTO Volunteers([Name], PhoneNumber, [Address], AnimalId, DepartmentId) 
	VALUES
	('Anita Kostova', '0896365412', 'Sofia, 5 Rosa str.', 15, 1),
	('Dimitur Stoev', '0877564223', NULL, 42, 4),
	('Kalina Evtimova', '0896321112', 'Silistra, 21 Breza str.', 9, 7),
	('Stoyan Tomov', '0898564100', 'Montana, 1 Bor str.', 18, 8),
	('Boryana Mileva', '0888112233', NULL, 31, 5)

INSERT INTO Animals([Name], BirthDate, OwnerId, AnimalTypeId)
	VALUES
	('Giraffe', '2018-09-21', 21, 1),
	('Harpy Eagle', '2015-04-17', 15, 3),
	('Hamadryas Baboon', '2017-11-02', NULL, 1),
	('Tuatara', '2021-06-30', 2, 4)

-- P03
UPDATE Animals
	SET OwnerId = (
						SELECT Id 
							FROM Owners
							WHERE [Name] = 'Kaloqn Stoqnov'
				  )
	WHERE OwnerId IS NULL

-- P04
DELETE FROM Volunteers
	WHERE DepartmentId = (
							SELECT Id 
								FROM VolunteersDepartments
								WHERE DepartmentName = 'Education program assistant'
						 ) 

DELETE FROM VolunteersDepartments
	WHERE DepartmentName = 'Education program assistant'

-- P05
SELECT [Name], PhoneNumber, [Address], AnimalId, DepartmentId 
	FROM Volunteers
	ORDER BY [Name],
	AnimalId

-- P06
SELECT 
	a.Name,
	aty.AnimalType,
	FORMAT(BirthDate, 'dd.MM.yyyy') AS BirthDate
	FROM Animals AS a
	JOIN AnimalTypes AS aty
	ON a.AnimalTypeId = aty.Id
	ORDER BY a.Name

-- P07
SELECT TOP(5)
	o.Name,
	COUNT(a.OwnerId) AS CountOfAnimals
	FROM Owners AS o
	LEFT JOIN Animals AS a
	ON o.Id = a.OwnerId
	GROUP BY o.Name
	ORDER BY CountOfAnimals DESC,
	o.Name

-- P08
SELECT 
	CONCAT(o.Name, '-', a.Name) AS OwnersAnimals,
	PhoneNumber,
	ac.CageId
	FROM Owners AS o
	JOIN Animals AS a
	ON o.Id = a.OwnerId
	JOIN AnimalTypes AS aty
	ON a.AnimalTypeId = aty.Id
	JOIN AnimalsCages AS ac
	ON a.Id = ac.AnimalId
	WHERE aty.AnimalType = 'Mammals'
	ORDER BY o.Name, a.Name DESC

-- P09
SELECT 
	[Name],
	PhoneNumber,
	TRIM(SUBSTRING(Address, CHARINDEX(',', Address) + 1, LEN(Address))) AS [Address]
	FROM Volunteers AS v
	JOIN VolunteersDepartments AS vd
	ON v.DepartmentId = vd.Id 
	WHERE Address LIKE '%Sofia%' 
	AND vd.DepartmentName = 'Education program assistant'
	ORDER BY [Name]

-- P10
SELECT 
	a.Name,
	DATEPART(YEAR ,BirthDate) AS BirthYear,
	aty.AnimalType
	FROM Animals AS a
	JOIN AnimalTypes AS aty
	ON a.AnimalTypeId = aty.Id
	WHERE OwnerId IS NULL
	AND aty.AnimalType != 'Birds'
	AND 2022 - DATEPART(YEAR ,BirthDate) < 5
	ORDER BY a.Name

-- P11
CREATE FUNCTION udf_GetVolunteersCountFromADepartment(@VolunteersDepartment VARCHAR(30))
RETURNS INT
AS
BEGIN 
DECLARE @count INT = (

						SELECT COUNT(*)
							FROM (
									SELECT DepartmentName
										FROM Volunteers AS v
										JOIN VolunteersDepartments AS vd
										ON v.DepartmentId = vd.Id
										WHERE DepartmentName = @VolunteersDepartment
								 )	AS CountSubquery	
					  )

RETURN @count
END

-- P12
CREATE PROCEDURE usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(30))
AS
BEGIN 

SELECT 
	a.Name,
	ISNULL(o.Name, 'For adoption') AS OwnersName
	FROM Animals AS a
	LEFT JOIN Owners AS o
	ON a.OwnerId = o.Id
	WHERE a.Name = @AnimalName

END