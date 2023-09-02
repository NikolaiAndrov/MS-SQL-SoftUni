SELECT 
    SUM(Difference)
    FROM (

            SELECT 
                wd1.DepositAmount - wd2.DepositAmount AS Difference
                FROM WizzardDeposits
                AS wd1
                JOIN WizzardDeposits
                AS wd2 ON wd1.Id + 1 = wd2.Id

         ) AS DifferenceSubquery
