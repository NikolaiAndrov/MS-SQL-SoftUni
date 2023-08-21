CREATE TABLE Students
	(
		StudentID INT PRIMARY KEY IDENTITY,
		[Name] NVARCHAR(50) NOT NULL
	)

INSERT INTO Students ([Name])
	VALUES
	('Mila'),
	('Toni'),
	('Ron')


CREATE TABLE Exams
	(
		ExamID INT PRIMARY KEY NOT NULL,
		[Name] NVARCHAR(50) NOT NULL
	)

INSERT INTO Exams(ExamID, [Name])
	VALUES
	(101, 'SpringMVC'),
	(102, 'Neo4j'),
	(103, 'Oracle 11g')


CREATE TABLE StudentsExams
	(
		StudentID INT REFERENCES Students(StudentID) NOT NULL,
		ExamID INT REFERENCES Exams(ExamID) NOT NULL,
		CONSTRAINT PK_StudentExam
			PRIMARY KEY(StudentID, ExamID)
	)

INSERT INTO StudentsExams(StudentID, ExamID)
	VALUES
	(1, 101),
	(1, 102),
	(2, 101),
	(3, 103),
	(2, 102),
	(2, 103)