SELECT *
    INTO Employees2
    FROM Employees
    WHERE Salary > 30000 


DELETE FROM Employees2
    WHERE ManagerID = 42

UPDATE Employees2
    SET Salary += 5000
    WHERE DepartmentID = 1


SELECT 
    DepartmentID,
    AVG(Salary) AS AverageSalary
    FROM Employees2
    GROUP BY DepartmentID