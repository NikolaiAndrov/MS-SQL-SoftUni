SELECT FirstLetter 
    FROM (
            SELECT 
                LEFT(FirstName, 1) AS FirstLetter
                FROM WizzardDeposits
                WHERE DepositGroup = 'Troll Chest'
         ) AS FirstLetterSubquery
    GROUP by FirstLetter
    