SELECT Username, IpAddress AS [Ip Address]
	FROM Users
	WHERE IpAddress LIKE '___.1_%._%.___'
	ORDER BY Username
