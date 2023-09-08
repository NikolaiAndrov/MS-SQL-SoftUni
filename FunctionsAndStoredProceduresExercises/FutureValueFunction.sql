CREATE OR ALTER FUNCTION ufn_CalculateFutureValue(@sum DECIMAL(18,4), @rate FLOAT, @years INT)
RETURNS DECIMAL(18, 4)
AS
BEGIN

DECLARE @totalInterest FLOAT = POWER(@rate + 1, @years)
RETURN @sum * @totalInterest

END