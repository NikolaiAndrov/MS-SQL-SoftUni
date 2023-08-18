CREATE TABLE Users
	(
		Id BIGINT PRIMARY KEY IDENTITY,
		Username VARCHAR(30) NOT NULL,
		[Password] VARCHAR(26) NOT NULL,
		ProfilePicture VARBINARY(MAX) CHECK(LEN(ProfilePicture) >= 900000),
		LastLoginTime DATETIME2,
		IsDeleted BIT
	)

INSERT INTO Users (Username, [Password], ProfilePicture, LastLoginTime, IsDeleted)
	VALUES
	('Niko', '12345', NULL, '06-13-2023', 0),
	('Kiko', '123456', NULL, '09-15-2023', 1),
	('Kiki', '123459', NULL, '06-13-2023', 0),
	('Mitko', '12334568', NULL, '06-13-2023', 0),
	('Nina', '1234555', NULL, '06-13-2023', 1)

ALTER TABLE [Users]
	DROP CONSTRAINT PK__Users__3214EC076D163C76

ALTER TABLE [Users]
	ADD CONSTRAINT IdUsername 
	PRIMARY KEY(Id, Username)

ALTER TABLE [Users] 
	ADD CONSTRAINT CHK_PasswordMinLen 
	CHECK(LEN(Password) >= 5)

ALTER TABLE [Users]
	ADD CONSTRAINT DF_LastLoginTime
	DEFAULT GETDATE() FOR [LastLoginTime]

INSERT INTO [Users] (Username, [Password], IsDeleted)
	VALUES
	('New Test User', 'user12345', 0)

SELECT * FROM Users

ALTER TABLE [Users]
	DROP CONSTRAINT IdUsername

ALTER TABLE [Users]
	ADD CONSTRAINT PK_Id PRIMARY KEY (Id)

ALTER TABLE [Users]
	ADD CONSTRAINT UC_Username UNIQUE (Username)

ALTER TABLE [Users]
	ADD CONSTRAINT CHK_UsernameMinLen
	CHECK(LEN(Username) >= 3)
