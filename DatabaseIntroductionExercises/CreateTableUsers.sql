CREATE TABLE Users
	(
		Id BIGINT PRIMARY KEY IDENTITY,
		Username VARCHAR(30) NOT NULL,
		[Password] VARCHAR(26) NOT NULL,
		ProfilePicture VARBINARY(MAX),
		LastLoginTime DATETIME2,
		IsDeleted BIT
	)

INSERT INTO Users (Username, [Password], ProfilePicture, LastLoginTime, IsDeleted)
	VALUES
	('Niko', '123', NULL, '06-13-2023', 0),
	('Kiko', '1234', NULL, '09-15-2023', 1),
	('Kiki', '12345', NULL, '06-13-2023', 0),
	('Mitko', '1233', NULL, '06-13-2023', 0),
	('Nina', '1234555', NULL, '06-13-2023', 1)

SELECT * FROM Users