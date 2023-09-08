CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(8)
AS
BEGIN

DECLARE @level VARCHAR(8)

IF @salary < 30000
	SET @level = 'Low'
ELSE IF @salary BETWEEN 30000 AND 50000
	SET @level = 'Average'
ELSE IF @salary > 50000
	SET @level = 'High'

RETURN @level
END
