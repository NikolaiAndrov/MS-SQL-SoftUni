SELECT 
    COUNT(*) AS Count
    FROM(
            SELECT 
                CountryName,
                MountainRange
                FROM MountainsCountries AS mNc
                FULL JOIN Countries AS c ON mNc.CountryCode = c.CountryCode
                FULL JOIN Mountains AS m ON m.Id = mNc.MountainId
                WHERE MountainRange IS NULL
                
        ) AS CountSubquery