CREATE TABLE NotificationEmails
	(
	Id INT PRIMARY KEY IDENTITY, 
	Recipient INT REFERENCES Accounts(Id), 
	[Subject] VARCHAR(100), 
	Body VARCHAR(MAX)
	)
-- PROBLEM 02
CREATE TRIGGER tr_LogEmail ON Logs FOR INSERT
AS
BEGIN

DECLARE @recipient INT = (SELECT AccountId FROM inserted)
DECLARE @subject VARCHAR(100) = CONCAT('Balance change for account: ', @recipient)
DECLARE @oldSum MONEY = (SELECT OldSum FROM deleted)
DECLARE @newSum MONEY = (SELECT NewSum FROM inserted)
DECLARE @body VARCHAR(MAX) = CONCAT('On ', GETDATE(), ' your balance was changed from ', @oldSum, 'to', @newSum, '.')

INSERT INTO NotificationEmails(Recipient, [Subject], Body)
	VALUES(@recipient, @subject, @body)

END
-- ---
UPDATE Accounts
	SET Balance += 10
	WHERE Id = 1
SELECT * FROM NotificationEmails