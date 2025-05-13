use musicfestival;

WITH artist_continents AS (

    /* 1. Άμεσες εμφανίσεις καλλιτεχνών */
    SELECT   p.Artist_ID          AS Artist_ID,
             l.Continent_ID       AS Continent_ID
    FROM     Performance  p
    JOIN     Event        e  ON e.Event_ID      = p.Event_ID
    JOIN     Festival     f  ON f.Festival_ID   = e.Festival_ID
    JOIN     Location     l  ON l.Location_ID   = f.Location_ID
    WHERE    p.Artist_ID IS NOT NULL

    UNION

    /* 2. Εμφανίσεις μέσω συγκροτημάτων */
    SELECT   ab.Artist_ID,
             l.Continent_ID
    FROM     Performance  p
    JOIN     ArtistBand   ab ON ab.Band_ID      = p.Band_ID
    JOIN     Event        e  ON e.Event_ID      = p.Event_ID
    JOIN     Festival     f  ON f.Festival_ID   = e.Festival_ID
    JOIN     Location     l  ON l.Location_ID   = f.Location_ID
    WHERE    p.Band_ID IS NOT NULL
)

SELECT   a.Artist_ID,
         CONCAT(a.First_Name,' ',a.Last_Name)      AS Artist_Name,
         COUNT(DISTINCT ac.Continent_ID)           AS Continents_Played
FROM     Artist             a
JOIN     artist_continents  ac ON ac.Artist_ID = a.Artist_ID
GROUP BY a.Artist_ID, Artist_Name
HAVING   COUNT(DISTINCT ac.Continent_ID) >= 3
ORDER BY Continents_Played DESC, Artist_Name;
