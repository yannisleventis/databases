use musicfestival;

-- Καλλιτέχνες με τουλάχιστον 5 λιγότερες συμμετοχές από τον πιο ενεργό
SELECT a.Artist_ID, a.First_Name, a.Last_Name, COUNT(p.Performance_ID) AS Participations
FROM Artist a
LEFT JOIN Performance p ON a.Artist_ID = p.Artist_ID
GROUP BY a.Artist_ID, a.First_Name, a.Last_Name
HAVING COUNT(p.Performance_ID) <= (
    SELECT MAX(artist_participations) - 5
    FROM (
        SELECT COUNT(p2.Performance_ID) AS artist_participations
        FROM Artist a2
        JOIN Performance p2 ON a2.Artist_ID = p2.Artist_ID
        GROUP BY a2.Artist_ID
    ) AS sub
);
