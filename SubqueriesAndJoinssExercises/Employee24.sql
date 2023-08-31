SELECT 
    e.EmployeeID,
    e.FirstName,
    CASE 
        WHEN p.StartDate >= '2005-01-01' THEN NULL
        ELSE p.Name 
    END
    AS ProjectName
    FROM EmployeesProjects
    AS ep 
    JOIN Employees
    AS e 
    ON ep.EmployeeID = e.EmployeeID  
    JOIN Projects
    AS p 
    ON p.ProjectID = ep.ProjectID
    WHERE e.EmployeeID = 24