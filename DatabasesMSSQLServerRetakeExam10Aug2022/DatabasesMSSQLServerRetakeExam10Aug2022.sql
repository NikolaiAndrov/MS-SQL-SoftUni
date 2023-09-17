-- P01
CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Locations
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Municipality VARCHAR(50),
	Province VARCHAR(50)
)

CREATE TABLE Sites
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	LocationId INT FOREIGN KEY REFERENCES Locations(Id) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	Establishment VARCHAR(15)
)

CREATE TABLE Tourists
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Age INT CHECK(Age >= 0 AND Age <= 120) NOT NULL,
	PhoneNumber VARCHAR(20) NOT NULL,
	Nationality VARCHAR(30) NOT NULL,
	Reward VARCHAR(20)
)

CREATE TABLE SitesTourists
(
	TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
	SiteId INT FOREIGN KEY REFERENCES Sites(Id) NOT NULL,
	PRIMARY KEY(TouristId, SiteId)
)

CREATE TABLE BonusPrizes
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE TouristsBonusPrizes
(
	TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
	BonusPrizeId INT FOREIGN KEY REFERENCES BonusPrizes(Id) NOT NULL,
	PRIMARY KEY(TouristId, BonusPrizeId)
)

-- P02
INSERT INTO Tourists([Name], Age, PhoneNumber, Nationality, Reward)
	VALUES
	('Borislava Kazakova', 52, '+359896354244', 'Bulgaria', NULL),
	('Peter Bosh', 48, '+447911844141', 'UK', NULL),
	('Martin Smith', 29, '+353863818592', 'Ireland', 'Bronze badge'),
	('Svilen Dobrev', 49, '+359986584786', 'Bulgaria', 'Silver badge'),
	('Kremena Popova', 38, '+359893298604', 'Bulgaria', NULL)

INSERT INTO Sites([Name], LocationId, CategoryId, Establishment)
	VALUES
	('Ustra fortress', 90, 7, 'X'),
	('Karlanovo Pyramids', 65, 7, NULL),
	('The Tomb of Tsar Sevt', 63, 8, 'V BC'),
	('Sinite Kamani Natural Park', 17, 1, NULL),
	('St. Petka of Bulgaria � Rupite', 92, 6, '1994')

-- P03
UPDATE
	Sites
	SET Establishment = '(not defined)'
	WHERE Establishment IS NULL

-- P04
DELETE  
	FROM TouristsBonusPrizes
	WHERE BonusPrizeId = (
							SELECT Id
								FROM BonusPrizes
								WHERE [Name] = 'Sleeping bag'
						 )


DELETE 
	FROM BonusPrizes
	WHERE [Name] = 'Sleeping bag'

-- P05
SELECT 
	[Name],
	Age,
	PhoneNumber,
	Nationality
	FROM Tourists
	ORDER BY Nationality, Age DESC, [Name]

-- P06
SELECT 
	s.Name AS [Site],
	l.Name AS [Location],
	s.Establishment,
	c.Name AS Category
	FROM Sites AS s
	JOIN Locations AS l
	ON s.LocationId = l.Id
	JOIN Categories AS c
	ON s.CategoryId = c.Id
	ORDER BY c.Name DESC, l.Name, s.Name

-- P07
SELECT 
	l.Province,
	l.Municipality,
	l.Name AS [Location],
	COUNT(s.Id) AS CountOfSites
	FROM Locations AS l
	JOIN Sites AS s
	ON s.LocationId = l.Id
	WHERE l.Province = 'Sofia'
	GROUP BY l.Province, l.Municipality, l.Name
	ORDER BY CountOfSites DESC, l.Name

-- P08
SELECT 
	s.Name AS [Site],
	l.Name AS [Location],
	l.Municipality,
	l.Province,
	s.Establishment
	FROM Sites AS s
	JOIN Locations AS l
	ON s.LocationId = l.Id
	WHERE LEFT(l.Name, 1) NOT IN ('B', 'M', 'D')
	AND s.Establishment LIKE '%BC%'
	ORDER BY s.Name

-- P09
SELECT 
	t.Name,
	t.Age,
	t.PhoneNumber,
	t.Nationality,
	ISNULL(bp.Name, '(no bonus prize)') AS Reward
	FROM Tourists AS t
	LEFT JOIN TouristsBonusPrizes AS tbp
	ON t.Id = tbp.TouristId
	LEFT JOIN BonusPrizes AS bp
	ON tbp.BonusPrizeId = bp.Id
	ORDER BY t.Name	

-- P10
SELECT 
	DISTINCT
	SUBSTRING(t.Name, CHARINDEX(' ', t.Name), LEN(t.Name)) AS LastName,
	t.Nationality,
	t.Age,
	t.PhoneNumber	
	FROM Tourists AS t
	JOIN SitesTourists AS st
	ON t.Id = st.TouristId
	JOIN Sites AS s
	ON st.SiteId = s.Id
	JOIN Categories AS c
	ON s.CategoryId = c.Id
	WHERE c.Name = 'History and archaeology'
	ORDER BY LastName

-- P11
CREATE FUNCTION udf_GetTouristsCountOnATouristSite (@Site VARCHAR(100))
RETURNS INT
AS
BEGIN

DECLARE @count INT = (
SELECT COUNT(t.Id) 
	FROM Sites AS s
	LEFT JOIN SitesTourists AS st
	ON s.Id = st.SiteId
	LEFT JOIN Tourists AS t
	ON st.TouristId = t.Id
	WHERE s.Name = @Site
	GROUP BY s.Name
)

RETURN @count
END

-- P12
CREATE PROCEDURE usp_AnnualRewardLottery(@TouristName VARCHAR(50))
AS
BEGIN

SELECT
	t.Name,
	CASE	
		WHEN COUNT(s.Id) >= 100 THEN 'Gold badge'
		WHEN COUNT(s.Id) >= 50 THEN 'Silver badge'
		WHEN COUNT(s.Id) >= 25 THEN 'Bronze badge'
	END AS Reward
	FROM Tourists AS t
	JOIN SitesTourists AS st
	ON st.TouristId = t.Id
	JOIN Sites AS s
	ON st.SiteId = s.Id
	WHERE t.Name = @TouristName
	GROUP BY t.Name

END