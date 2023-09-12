CREATE PROCEDURE usp_TransferMoney @senderId INT, @receiverId INT, @amount DECIMAL(18, 4)
AS
BEGIN

BEGIN TRANSACTION

IF @amount < 0
BEGIN
ROLLBACK
RAISERROR('Invalid money amount!', 16, 1)
RETURN
END

EXEC usp_WithdrawMoney @senderId, @amount
EXEC usp_DepositMoney @receiverId, @amount
COMMIT

END