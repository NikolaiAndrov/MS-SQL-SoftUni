CREATE TABLE Logs 
	(
		LogId INT PRIMARY KEY IDENTITY,
		AccountId INT REFERENCES Accounts(Id),
		OldSum MONEY,
		NewSum MONEY
	)

--PROBLEM 01
CREATE TRIGGER tr_InsertAccountInfo 
ON Accounts FOR UPDATE
AS
	INSERT Logs(AccountId, OldSum, NewSum)
	SELECT	i.Id, d.Balance, i.Balance  
	FROM inserted AS i
	JOIN deleted AS d 
	ON i.Id = d.Id

