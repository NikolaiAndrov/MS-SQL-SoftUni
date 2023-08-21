CREATE TABLE Majors
	(
		MajorID INT PRIMARY KEY IDENTITY,
		[Name] NVARCHAR(50) NOT NULL
	)

CREATE TABLE Students
	(
		StudentID INT PRIMARY KEY IDENTITY,
		StudentNumber INT NOT NULL,
		StudentName NVARCHAR(100) NOT NULL,
		MajorID INT REFERENCES Majors(MajorID)
	)

CREATE TABLE Payments
	(
		PaymentID INT PRIMARY KEY IDENTITY,
		PaymentDate DATE NOT NULL,
		PaymentAmount DECIMAL(18,2) NOT NULL,
		StudentID INT REFERENCES Students(StudentID) NOT NULL
	)

CREATE TABLE Subjects
	(
		SubjectID INT PRIMARY KEY IDENTITY,
		SubjectName NVARCHAR(100) NOT NULL
	)

CREATE TABLE Agenda
	(
		StudentID INT REFERENCES Students(StudentID) NOT NULL,
		SubjectID INT REFERENCES Subjects(SubjectID) NOT NULL
		CONSTRAINT PK_StudentPayment
			PRIMARY KEY(StudentID, SubjectID)
	)