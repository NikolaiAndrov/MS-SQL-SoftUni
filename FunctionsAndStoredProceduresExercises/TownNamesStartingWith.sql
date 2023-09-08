CREATE PROCEDURE usp_GetTownsStartingWith @StartingString VARCHAR(50)
AS
BEGIN
SELECT [Name]
	 FROM Towns
	 WHERE [Name] LIKE @StartingString + '%'	 
END