SELECT TOP(5)
    e.EmployeeID,
    e.FirstName,
    p.Name
    FROM EmployeesProjects
    AS ep 
    JOIN Employees
    AS e 
    ON ep.EmployeeID = e.EmployeeID
    JOIN Projects
    AS p 
    ON p.ProjectID = ep.ProjectID
    WHERE p.StartDate > '2002-08-13' AND
    p.EndDate IS NULL
    ORDER BY e.EmployeeID