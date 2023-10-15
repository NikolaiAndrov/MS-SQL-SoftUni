--P01
CREATE TABLE Countries
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Destinations
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	CountryId INT FOREIGN KEY REFERENCES Countries(Id) NOT NULL
)

CREATE TABLE Rooms
(
	Id INT PRIMARY KEY IDENTITY,
	[Type] VARCHAR(40) NOT NULL,
	Price DECIMAL(18,2) NOT NULL,
	BedCount INT CHECK(BedCount > 0 AND BedCount <= 10) NOT NULL
)

CREATE TABLE Hotels
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	DestinationId INT FOREIGN KEY REFERENCES Destinations(Id) NOT NULL
)

CREATE TABLE Tourists
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(80) NOT NULL,
	PhoneNumber VARCHAR(20) NOT NULL,
	Email VARCHAR(80),
	CountryId INT FOREIGN KEY REFERENCES Countries(Id) NOT NULL
)

CREATE TABLE Bookings
(
	Id INT PRIMARY KEY IDENTITY,
	ArrivalDate DATETIME2 NOT NULL,
	DepartureDate DATETIME2 NOT NULL,
	AdultsCount INT CHECK(AdultsCount >= 1 AND AdultsCount <= 10) NOT NULL,
	ChildrenCount INT CHECK(ChildrenCount >= 0 AND ChildrenCount <= 9) NOT NULL,
	TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
	HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL,
	RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL
)

CREATE TABLE HotelsRooms
(
	HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL,
	RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
	PRIMARY KEY(HotelId, RoomId)
)

--P02
INSERT INTO Tourists
	VALUES
	('John Rivers', '653-551-1555', 'john.rivers@example.com', 6),
	('Adeline Aglaé', '122-654-8726', 'adeline.aglae@example.com', 2),
	('Sergio Ramirez', '233-465-2876', 's.ramirez@example.com', 3),
	('Johan Müller', '322-876-9826', 'j.muller@example.com', 7),
	('Eden Smith', '551-874-2234', 'eden.smith@example.com', 6)

INSERT INTO Bookings
	VALUES
	('2024-03-01', '2024-03-11', 1, 0, 21, 3, 5),
	('2023-12-28', '2024-01-06', 2, 1, 22, 13, 3),
	('2023-11-15', '2023-11-20', 1, 2, 23, 19, 7),
	('2023-12-05', '2023-12-09', 4, 0, 24, 6, 4),
	('2024-05-01', '2024-05-07', 6, 0, 25, 14, 6)

--P03
UPDATE Bookings
	SET DepartureDate = DATEADD(DAY, 1, DepartureDate)
	WHERE DepartureDate >= '2023-01-01' AND DepartureDate  <= '2023-12-31'

UPDATE Tourists
	SET Email = NULL
	WHERE [Name] LIKE '%MA%'

--P04 
DELETE 
	FROM Bookings
	WHERE TouristId IN (
							SELECT Id
								FROM Tourists
								WHERE [Name] LIKE '%Smith%'
					   )

DELETE 
	FROM Tourists
	WHERE [Name] LIKE '%Smith%'

--P05
SELECT 
	CONVERT(VARCHAR(10), b.ArrivalDate) AS ArrivalDate,
	b.AdultsCount,
	b.ChildrenCount
	FROM Bookings AS b
	JOIN Rooms AS r
	ON b.RoomId = r.Id
	ORDER BY r.Price DESC, b.ArrivalDate ASC

--P06
SELECT 
	h.Id,
	h.Name
	FROM Hotels AS h
	JOIN HotelsRooms AS hr
	ON h.Id = hr.HotelId
	JOIN Rooms AS r
	ON r.Id = hr.RoomId
	JOIN Bookings AS b
	ON h.Id = b.HotelId
	WHERE r.Type = 'VIP Apartment'
	GROUP BY h.Name, h.Id
	ORDER BY COUNT(h.Id) DESC

--P07
SELECT 
	t.Id,
	t.Name,
	t.PhoneNumber
	FROM Tourists AS t
	LEFT JOIN Bookings AS b
	ON t.Id = b.TouristId
	WHERE b.Id IS NULL
	ORDER BY t.Name

--P08
SELECT TOP(10)
	h.Name AS HotelName,
	d.Name AS DestinationName,
	c.Name AS CountryName
	FROM Bookings AS b
	JOIN Hotels AS h
	ON h.Id = b.HotelId
	JOIN Destinations AS d
	ON h.DestinationId = d.Id
	JOIN Countries AS c
	ON c.Id = d.CountryId
	WHERE b.ArrivalDate < '2023-12-31' AND h.Id % 2 != 0
	ORDER BY c.Name, b.ArrivalDate

--P09
SELECT 
	h.Name AS HotelName,
	r.Price AS RoomPrice
	FROM Tourists AS t
	JOIN Bookings AS b
	ON t.Id = b.TouristId
	JOIN Hotels AS h
	ON h.Id = b.HotelId
	JOIN Rooms AS r
	ON r.Id = b.RoomId
	WHERE t.Name NOT LIKE '%EZ'
	ORDER BY r.Price DESC

--P10
SELECT 
	h.Name AS HotelName,
	SUM(r.Price * DATEDIFF(DAY, b.ArrivalDate, b.DepartureDate)) AS HotelRevenue
	FROM Bookings AS b
	JOIN Hotels AS h
	ON h.Id = b.HotelId
	JOIN Rooms AS r
	ON r.Id = b.RoomId
	GROUP BY h.Name
	ORDER BY HotelRevenue DESC

--P11
CREATE FUNCTION udf_RoomsWithTourists(@name VARCHAR(40))
RETURNS INT
AS
BEGIN

DECLARE @count INT = (
SELECT 
	SUM(b.ChildrenCount) + SUM(b.AdultsCount)
	FROM Rooms AS r
	JOIN Bookings AS b
	ON r.Id = b.RoomId
	WHERE r.Type = @name
)

RETURN @count

END

--P12
CREATE PROCEDURE usp_SearchByCountry(@country NVARCHAR(50))
AS
BEGIN

SELECT 
	t.Name,
	t.PhoneNumber,
	t.Email,
	COUNT(b.Id) AS CountOfBookings
	FROM Tourists AS t
	JOIN Bookings AS b
	ON t.Id = b.TouristId
	JOIN Countries AS c
	ON t.CountryId = c.Id
	WHERE c.Name = @country
	GROUP BY t.Name, t.PhoneNumber, t.Email
	ORDER BY t.Name, CountOfBookings DESC

END