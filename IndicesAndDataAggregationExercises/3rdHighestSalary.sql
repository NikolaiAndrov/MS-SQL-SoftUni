SELECT DISTINCT
    DepartmentID,
    Salary AS ThirdHighestSalary
    FROM (

            SELECT
                DepartmentId,
                Salary,
                DENSE_RANK() OVER(PARTITION BY DepartmentId ORDER BY Salary DESC) AS Rank
                FROM Employees

         ) AS RankSubquery

    WHERE Rank = 3
