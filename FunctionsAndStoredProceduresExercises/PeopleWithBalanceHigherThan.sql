CREATE OR ALTER PROCEDURE usp_GetHoldersWithBalanceHigherThan @balance MONEY
AS
BEGIN

SELECT FirstName, LastName 
	FROM AccountHolders AS ah
	JOIN Accounts AS ac
	ON ah.Id = ac.AccountHolderId
	GROUP BY ah.Id, ah.FirstName, ah.LastName
	HAVING SUM(ac.Balance) > @balance
	ORDER BY FirstName, LastName
	
END