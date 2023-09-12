CREATE TRIGGER tr_DeletedEmployees ON Employees FOR DELETE
AS
BEGIN
INSERT INTO Deleted_Employees (FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary FROM deleted
END