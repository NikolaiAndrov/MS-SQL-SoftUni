-- P01
CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Addresses
(
	Id INT PRIMARY KEY IDENTITY,
	StreetName NVARCHAR(100) NOT NULL,
	StreetNumber INT NOT NULL,
	Town VARCHAR(30) NOT NULL,
	Country VARCHAR(50) NOT NULL,
	ZIP INT NOT NULL
)

CREATE TABLE Publishers
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) UNIQUE NOT NULL,
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL,
	Website NVARCHAR(40),
	Phone NVARCHAR(20)
)

CREATE TABLE PlayersRanges
(
	Id INT PRIMARY KEY IDENTITY,
	PlayersMin INT NOT NULL,
	PlayersMax INT NOT NULL
)

CREATE TABLE Boardgames
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	YearPublished INT NOT NULL,
	Rating DECIMAL(4,2) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	PublisherId INT FOREIGN KEY REFERENCES Publishers(Id) NOT NULL,
	PlayersRangeId INT FOREIGN KEY REFERENCES PlayersRanges(Id) NOT NULL
)

CREATE TABLE Creators
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Email NVARCHAR(30) NOT NULL
)

CREATE TABLE CreatorsBoardgames
(
	CreatorId INT FOREIGN KEY REFERENCES Creators(Id) NOT NULL,
	BoardgameId INT FOREIGN KEY REFERENCES Boardgames(Id) NOT NULL,
	PRIMARY KEY(CreatorId, BoardgameId)
)

-- P02
INSERT INTO Boardgames([Name], YearPublished, Rating, CategoryId, PublisherId,PlayersRangeId)
	VALUES
	('Deep Blue', 2019, 5.67, 1, 15, 7),
	('Paris', 2016, 9.78, 7, 1, 5),
	('Catan: Starfarers', 2021, 9.87, 7, 13, 6),
	('Bleeding Kansas', 2020, 3.25, 3, 7, 4),
	('One Small Step', 2019, 5.75, 5, 9, 2)

INSERT INTO Publishers([Name], AddressId, Website, Phone)
	VALUES
	('Agman Games', 5, 'www.agmangames.com', '+16546135542'),
	('Amethyst Games', 7, 'www.amethystgames.com', '+15558889992'),
	('BattleBooks', 13, 'www.battlebooks.com', '+12345678907')

-- P03
UPDATE PlayersRanges
	SET PlayersMax += 1
	WHERE PlayersMin = 2 AND PlayersMax = 2

UPDATE Boardgames
	SET [Name] += 'V2'
	WHERE YearPublished >= 2020

-- P04
DELETE 
	FROM CreatorsBoardgames
	WHERE BoardgameId IN (1, 16, 31, 47)

DELETE 
	FROM Boardgames
	WHERE PublisherId IN (1, 16)

DELETE
	FROM Boardgames
	WHERE PublisherId IN (1, 16)

DELETE 
	FROM Publishers
	WHERE AddressId = 5

DELETE 
	FROM Addresses
	WHERE Town LIKE 'L%'

-- P04(2.0)
DELETE
	FROM CreatorsBoardgames
	WHERE BoardgameId IN (
							SELECT Id 
								FROM Boardgames
								WHERE PublisherId IN (
														SELECT Id
															FROM Publishers
															WHERE AddressId IN (
																					SELECT Id
																						FROM Addresses
																						WHERE Town LIKE 'L%'
																           )
										     )
			     )

DELETE 
	FROM Boardgames
	WHERE PublisherId IN (
							SELECT Id
								FROM Publishers
								WHERE AddressId IN (
														SELECT Id
															FROM Addresses
															WHERE Town LIKE 'L%'
										   )
			     )

DELETE 
	FROM Publishers
	WHERE AddressId IN (
							SELECT Id
								FROM Addresses
								WHERE Town LIKE 'L%'
			   )

DELETE 
	FROM Addresses
	WHERE Town LIKE 'L%'
	
-- P05
SELECT 
	[Name],
	Rating
	FROM Boardgames
	ORDER BY YearPublished, [Name] DESC

-- P06
SELECT 
	b.Id,
	b.Name,
	b.YearPublished,
	c.Name
	FROM Boardgames AS b
	JOIN Categories AS c
	ON b.CategoryId = c.Id
	WHERE c.Name IN ('Strategy Games', 'Wargames')
	ORDER BY YearPublished DESC

-- P07
SELECT 
	c.Id,
	CONCAT(c.FirstName, ' ', c.LastName) AS CreatorName,
	c.Email
	FROM Creators AS c
	LEFT JOIN CreatorsBoardgames cb
	ON c.Id = cb.CreatorId
	LEFT JOIN Boardgames AS b
	ON cb.BoardgameId = b.Id
	WHERE b.Id IS NULL

-- p08
SELECT TOP(5)
	b.Name,
	b.Rating,
	c.Name
	FROM Boardgames AS b
	JOIN PlayersRanges AS p
	ON b.PlayersRangeId = p.Id
	JOIN Categories AS c
		on b.CategoryId = c.Id
	WHERE (b.Rating > 7 AND b.Name LIKE '%a%')
	OR (b.Rating > 7.50 AND p.PlayersMin = 2 AND p.PlayersMax = 5)
	ORDER BY b.Name, b.Rating DESC

-- p09
SELECT 
	CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
	c.Email,
	MAX(b.Rating)
	FROM Creators AS c
	JOIN CreatorsBoardgames AS cb
	ON c.Id = cb.CreatorId
	JOIN Boardgames AS b
	ON cb.BoardgameId = b.Id
	WHERE c.Email LIKE '%.com'
	GROUP BY c.FirstName, c.LastName, c.Email
	ORDER BY FullName

-- P10
SELECT 
	c.LastName,
	CEILING(AVG(b.Rating)) AS AverageRating,
	p.Name
	FROM Creators AS c
	JOIN CreatorsBoardgames AS cb
	ON c.Id = cb.CreatorId
	JOIN Boardgames AS b
	ON cb.BoardgameId = b.Id
	JOIN Publishers AS p
	ON b.PublisherId = p.Id
	WHERE p.Name = 'Stonemaier Games'
	GROUP BY c.LastName, p.Name
	ORDER BY AVG(b.Rating) DESC

-- P11
CREATE FUNCTION udf_CreatorWithBoardgames(@name NVARCHAR(30))
RETURNS INT
AS
BEGIN

DECLARE @count INT = (
SELECT COUNT(*)
	FROM Creators AS c
	JOIN CreatorsBoardgames AS cb
	ON c.Id = cb.CreatorId
	JOIN Boardgames AS b
	ON cb.BoardgameId = b.Id
	WHERE c.FirstName = @name
)

RETURN @count

END

-- P12
CREATE PROCEDURE usp_SearchByCategory(@category VARCHAR(50))
AS
BEGIN

SELECT 
	b.Name,
	b.YearPublished,
	b.Rating,
	c.Name AS CategoryName,
	p.Name AS PublisherName,
	CONCAT(pr.PlayersMin, ' ', 'people') AS MinPlayers,
	CONCAT(pr.PlayersMax, ' ', 'people') AS MaxPlayers
	FROM Categories AS c
	JOIN Boardgames AS b
	ON c.Id = b.CategoryId
	JOIN Publishers AS p
	ON b.PublisherId = p.Id
	JOIN PlayersRanges AS pr
	ON pr.Id = b.PlayersRangeId
	WHERE c.Name = @category
	ORDER BY p.Name, b.YearPublished DESC

END
