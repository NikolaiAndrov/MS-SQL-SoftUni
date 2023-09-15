-- P01
CREATE TABLE Passengers
(
	Id INT PRIMARY KEY IDENTITY,
	FullName VARCHAR(100) UNIQUE NOT NULL,
	Email VARCHAR(50) UNIQUE NOT NULL 
)

CREATE TABLE Pilots
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) UNIQUE NOT NULL,
	LastName VARCHAR(30) UNIQUE NOT NULL,
	Age TINYINT NOT NULL CHECK(Age >= 21 AND Age <= 62),
	Rating FLOAT CHECK(Rating >= 0.0 AND Rating <= 10.0)
)

CREATE TABLE AircraftTypes
(
	Id INT PRIMARY KEY IDENTITY,
	TypeName VARCHAR(30) UNIQUE NOT NULL
)

CREATE TABLE Aircraft
(
	Id INT PRIMARY KEY IDENTITY,
	Manufacturer VARCHAR(25) NOT NULL,
	Model VARCHAR(30) NOT NULL,
	[Year] INT NOT NULL,
	FlightHours INT,
	Condition CHAR NOT NULL,
	TypeId INT NOT NULL FOREIGN KEY REFERENCES AircraftTypes(Id)
)

CREATE TABLE PilotsAircraft
(
	AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft(Id),
	PilotId INT NOT NULL FOREIGN KEY REFERENCES Pilots(Id),
	PRIMARY KEY(AircraftId, PilotId)
)

CREATE TABLE Airports
(
	Id INT PRIMARY KEY IDENTITY,
	AirportName VARCHAR(70) UNIQUE NOT NULL,
	Country VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE FlightDestinations
(
	Id INT PRIMARY KEY IDENTITY,
	AirportId INT NOT NULL FOREIGN KEY REFERENCES Airports(Id),
	[Start] DATETIME NOT NULL,
	AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft(Id),
	PassengerId INT NOT NULL FOREIGN KEY REFERENCES Passengers(Id),
	TicketPrice DECIMAL(18,2) NOT NULL DEFAULT 15
)

-- P02
INSERT INTO Passengers
	SELECT 
		CONCAT(FirstName, ' ', LastName) AS FullName,
		CONCAT(FirstName, LastName, '@gmail.com') AS Email
		FROM Pilots
		WHERE Id BETWEEN 5 AND 15

-- P03
UPDATE Aircraft
	SET Condition = 'A'
	WHERE Condition IN ('C', 'B')
	AND (FlightHours IS NULL OR FlightHours <= 100)
	AND [Year] >= 2013 

-- P04
DELETE 
	FROM Passengers
	WHERE LEN(FullName) <= 10

-- P05
SELECT 
	Manufacturer,
	Model,
	FlightHours,
	Condition
	FROM Aircraft
	ORDER BY FlightHours DESC

-- P06
SELECT 
	p.FirstName,
	p.LastName,
	a.Manufacturer,
	a.Model,
	a.FlightHours
	FROM PilotsAircraft AS pa
	JOIN Pilots AS p
	ON pa.PilotId = p.Id
	JOIN Aircraft AS a
	ON a.Id = pa.AircraftId
	WHERE a.FlightHours IS NOT NULL AND FlightHours <= 304
	ORDER BY a.FlightHours DESC,
	p.FirstName

-- P07
SELECT TOP(20)
	fd.Id AS DestinationId,
	fd.Start,
	p.FullName,
	a.AirportName,
	fd.TicketPrice
	FROM FlightDestinations AS fd
	JOIN Airports AS a
	ON fd.AirportId = a.Id
	JOIN Passengers AS p
	ON fd.PassengerId = p.Id
	WHERE DATEPART(DAY, fd.Start) % 2 = 0
	ORDER BY fd.TicketPrice DESC,
	a.AirportName

-- P08
SELECT 
	AircraftId,
	ac.Manufacturer,
	ac.FlightHours,
	FlightDestinationsCount,
	AvgPrice
	FROM
	(
		SELECT 
			a.Id AS AircraftId,
			ROUND(AVG(fd.TicketPrice), 2) AS AvgPrice,
			COUNT(fd.Id) AS FlightDestinationsCount
			FROM Aircraft AS a
			JOIN FlightDestinations AS fd
			ON a.Id = fd.AircraftId
			GROUP BY a.Id
			HAVING(COUNT(fd.Id) >= 2)
	) AS Subquery
	JOIN Aircraft AS ac
	ON ac.Id = AircraftId
	ORDER BY FlightDestinationsCount DESC,
	AircraftId

-- P09
SELECT 
	p.FullName,
	COUNT(AircraftId) AS CountOfAircraft,
	SUM(TicketPrice) AS TotalPayed
	FROM Passengers AS p
	JOIN FlightDestinations AS fd
	ON p.Id = fd.PassengerId
	GROUP BY p.FullName
	HAVING(FullName LIKE '_a%') AND COUNT(AircraftId) > 1
	ORDER BY FullName

-- P10
SELECT 
	a.AirportName,
	fd.Start AS DayTime,
	fd.TicketPrice,	
	p.FullName,
	ac.Manufacturer,
	ac.Model
	FROM FlightDestinations AS fd
	JOIN Airports AS a
	ON fd.AirportId = a.Id
	JOIN Passengers AS p
	ON fd.PassengerId = p.Id
	JOIN Aircraft AS ac
	ON fd.AircraftId = ac.Id
	WHERE (DATEPART(HOUR, [Start]) >= DATEPART(HOUR, '6:00') AND DATEPART(HOUR, [Start]) <= DATEPART(HOUR, '20:00')) 
	AND fd.TicketPrice > 2500
	ORDER BY ac.Model

-- P11
CREATE FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(50))
RETURNS INT
AS
BEGIN 

DECLARE @flightsCount INT = (
SELECT COUNT(fd.Id)
	FROM Passengers AS p
 	LEFT JOIN FlightDestinations AS fd
	ON p.Id = fd.PassengerId
	GROUP BY p.Email
	HAVING p.Email = @email
) 

RETURN @flightsCount
END

CREATE PROCEDURE usp_SearchByAirportName @airportName VARCHAR(70)
AS
BEGIN

SELECT 
	ap.AirportName,
	p.FullName,
	CASE
		WHEN fd.TicketPrice <= 400 THEN 'Low'
		WHEN fd.TicketPrice >= 401 AND fd.TicketPrice <= 1500 THEN 'Medium'
		WHEN fd.TicketPrice >= 1501 THEN 'High'
	END AS LevelOfTickerPrice,
	ac.Manufacturer,
	ac.Condition,
	aty.TypeName
	FROM FlightDestinations AS fd
	JOIN Airports AS ap
	ON fd.AirportId = ap.Id
	JOIN Passengers AS p
	ON fd.PassengerId = p.Id
	JOIN Aircraft AS ac
	ON fd.AircraftId = ac.Id
	JOIN AircraftTypes AS aty
	ON ac.TypeId = aty.Id
	WHERE ap.AirportName = @airportName
	ORDER BY ac.Manufacturer, p.FullName

END
