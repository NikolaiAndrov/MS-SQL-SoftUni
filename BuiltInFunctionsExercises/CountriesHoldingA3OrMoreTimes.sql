SELECT CountryName, IsoCode 
	FROM Countries
	WHERE LEN(LOWER(CountryName)) - LEN(REPLACE(LOWER(CountryName), 'a', '')) >= 3
	ORDER BY IsoCode