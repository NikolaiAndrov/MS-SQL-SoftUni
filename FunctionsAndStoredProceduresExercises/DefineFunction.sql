CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(50))
RETURNS BIT
AS
BEGIN

DECLARE @wordIndex TINYINT = 1

WHILE @wordIndex <= LEN(@word)
	BEGIN
		DECLARE @currentWordLetter CHAR(1) = SUBSTRING(@word, @wordIndex, 1)

		IF CHARINDEX(@currentWordLetter, @setOfLetters) = 0
		RETURN 0

		SET @wordIndex += 1	
	END

RETURN 1
END