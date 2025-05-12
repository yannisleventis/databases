use musicfestival;

WITH ArtistGenres AS (
    -- Βρίσκουμε όλους τους καλλιτέχνες που έχουν εμφανιστεί σε φεστιβάλ 
    -- και τα μουσικά είδη τους
    SELECT DISTINCT 
        a.Artist_ID,
        a.First_Name,
        a.Last_Name,
        g.Genre_ID,
        g.Genre_Name
    FROM 
        Artist a
    JOIN 
        Performance p ON a.Artist_ID = p.Artist_ID
    JOIN 
        Event e ON p.Event_ID = e.Event_ID
    JOIN 
        Festival f ON e.Festival_ID = f.Festival_ID
    JOIN 
        Artist_Genre ag ON a.Artist_ID = ag.Artist_ID
    JOIN 
        Genre g ON ag.Genre_ID = g.Genre_ID
),

GenrePairs AS (
    -- Δημιουργούμε όλα τα πιθανά ζεύγη ειδών για κάθε καλλιτέχνη
    SELECT 
        ag1.Genre_Name AS Genre1,
        ag2.Genre_Name AS Genre2,
        COUNT(DISTINCT ag1.Artist_ID) AS Artists_Count
    FROM 
        ArtistGenres ag1
    JOIN 
        ArtistGenres ag2 ON ag1.Artist_ID = ag2.Artist_ID 
        AND ag1.Genre_ID < ag2.Genre_ID -- Για να αποφύγουμε διπλή καταμέτρηση
    GROUP BY 
        ag1.Genre_Name, ag2.Genre_Name
)

-- Επιλέγουμε τα top-3 ζεύγη με βάση τον αριθμό καλλιτεχνών
SELECT 
    Genre1,
    Genre2,
    Artists_Count
FROM 
    GenrePairs
ORDER BY 
    Artists_Count DESC
LIMIT 3;