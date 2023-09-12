CREATE PROCEDURE usp_AssignProject @emloyeeId INT, @projectID INT
AS
BEGIN

BEGIN TRANSACTION

IF @emloyeeId NOT IN (SELECT EmployeeID FROM Employees)
BEGIN
ROLLBACK
RAISERROR('Non existing employee', 16, 1)
RETURN
END

IF @projectID NOT IN (SELECT ProjectID FROM Projects)
BEGIN
ROLLBACK
RAISERROR('Non existing project', 16, 1)
RETURN
END

if (SELECT COUNT(ProjectID) FROM EmployeesProjects WHERE EmployeeID = @emloyeeId) >= 3
BEGIN
ROLLBACK
RAISERROR('The employee has too many projects!', 16, 1)
RETURN
END

INSERT INTO EmployeesProjects(EmployeeID, ProjectID)
VALUES (@emloyeeId, @projectID)

COMMIT
END