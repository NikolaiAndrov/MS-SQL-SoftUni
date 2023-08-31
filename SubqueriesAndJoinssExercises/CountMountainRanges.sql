SELECT  CountryCode,
    COUNT(MountainID) 
    AS MountainRanges
    FROM MountainsCountries
    WHERE CountryCode IN (
                            SELECT CountryCode 
                                FROM Countries 
                                WHERE CountryName IN ('United States', 'Russia', 'Bulgaria')

                         )
    GROUP BY CountryCode
