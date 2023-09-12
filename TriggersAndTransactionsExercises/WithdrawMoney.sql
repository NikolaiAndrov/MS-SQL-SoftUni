CREATE PROCEDURE usp_DepositMoney @accountId INT, @moneyAmount DECIMAL(18,4)
AS
BEGIN
BEGIN TRANSACTION

IF @accountId NOT IN (SELECT Id FROM Accounts)
BEGIN
ROLLBACK
RAISERROR('Invalid account!', 16, 1)
RETURN
END

IF @moneyAmount < 0
BEGIN
ROLLBACK
RAISERROR('Invalid money amount!', 16, 1)
RETURN
END

UPDATE Accounts
	SET Balance += @moneyAmount
	WHERE Id = @accountId
COMMIT
END
