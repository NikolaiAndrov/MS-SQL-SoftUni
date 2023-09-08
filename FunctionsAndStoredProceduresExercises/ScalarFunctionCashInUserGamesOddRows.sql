CREATE OR ALTER FUNCTION ufn_CashInUsersGames(@gameName NVARCHAR(50))
RETURNS TABLE
AS
RETURN (

	SELECT 
		SUM(Cash) AS SumCash
		FROM (
				SELECT 
					Cash,
					ROW_NUMBER() OVER(ORDER BY Cash DESC) AS [Row]
					FROM UsersGames AS ug
					JOIN Games AS g
					ON ug.GameId = g.Id
					WHERE g.Name = @gameName
			 ) AS RankingSubquery
		WHERE [Row] % 2 != 0
	
)