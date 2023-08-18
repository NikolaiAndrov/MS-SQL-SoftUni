CREATE DATABASE Movies

USE Movies

CREATE TABLE Directors
	(
		Id INT PRIMARY KEY,
		DirectorName NVARCHAR(100) NOT NULL,
		Notes NVARCHAR(MAX)
	)

INSERT INTO Directors (Id, DirectorName, Notes)
	VALUES
	(1, 'First Director', NULL),
	(2, 'Second Director', NULL),
	(3, 'Third Director', NULL),
	(4, 'Fourth Director', NULL),
	(5, 'Fifth Director', NULL)


CREATE TABLE Genres
	(
		Id INT PRIMARY KEY,
		GenreName NVARCHAR(100) NOT NULL,
		Notes NVARCHAR(MAX)
	)

INSERT INTO Genres (Id, GenreName, Notes)
	VALUES
	(1, 'First Genre', NULL),
	(2, 'Second Genre', NULL),
	(3, 'Third Genre', NULL),
	(4, 'Fourth Genre', NULL),
	(5, 'Fifth Genre', NULL)


CREATE TABLE Categories
	(
		Id INT PRIMARY KEY,
		CategoryName NVARCHAR(100) NOT NULL,
		Notes NVARCHAR(MAX)
	)

INSERT INTO Categories (Id, CategoryName, Notes)
	VALUES
	(1, 'First Category', NULL),
	(2, 'Second Category', NULL),
	(3, 'Third Category', NULL),
	(4, 'Fourth Category', NULL),
	(5, 'Fifth Category', NULL)


CREATE TABLE Movies
	(
		Id INT PRIMARY KEY,
		Title NVARCHAR(100) NOT NULL,
		DirectorId INT NOT NULL,
		CopyrightYear DATE NOT NULL,
		[Length] DECIMAL(18, 2) NOT NULL,
		GenreId INT NOT NULL,
		CategoryId INT NOT NULL,
		Rating TINYINT NOT NULL,
		Notes NVARCHAR(MAX)
	)

INSERT INTO Movies (Id, Title, DirectorId, CopyrightYear, [Length], GenreId, CategoryId, Rating, Notes)
	VALUES
	(1, 'First Title', 1, '2018-08-26', 2.45, 1, 1, 5, NULL),
	(2, 'Second Title', 2, '2018-08-26', 2.45, 2, 2, 5, NULL),
	(3, 'Third Title', 3, '2018-08-26', 2.45, 3, 3, 5, NULL),
	(4, 'Fourth Title', 4, '2018-08-26', 2.45, 4, 4, 5, NULL),
	(5, 'Fifth Title', 5, '2018-08-26', 2.45, 5, 5, 5, NULL)

SELECT * FROM Movies