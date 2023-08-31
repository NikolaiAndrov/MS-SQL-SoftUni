SELECT Bulgaria.CountryCode,
       m.MountainRange,
       p.PeakName,
       p.Elevation      
    FROM (
            SELECT * 
                FROM Countries
                WHERE CountryName = 'Bulgaria'
         )  AS Bulgaria

    JOIN MountainsCountries AS mNc ON Bulgaria.CountryCode = mNc.CountryCode
    JOIN Mountains AS m ON mNc.MountainId = m.Id
    JOIN Peaks AS p ON p.MountainId = m.Id
    WHERE p.Elevation > 2835
    ORDER BY p.Elevation DESC


