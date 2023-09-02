SELECT TOP(10)
    FirstName,
    LastName,
    DepartmentID
    FROM Employees
    AS e 
    WHERE e.Salary > (

                        SELECT 
                            AVG(Salary) AS AvgSalary
                            FROM Employees
                            AS InternalE
                            WHERE e.DepartmentID = InternalE.DepartmentID
                            GROUP BY DepartmentID

                     ) 