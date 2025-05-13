use musicfestival;

SELECT 
    a.Artist_ID,
    CONCAT(a.First_Name, ' ', a.Last_Name) AS Artist_Name,
    a.Stage_Name,
    f.Name AS Festival_Name,
    COUNT(*) AS Warmup_Count
FROM 
    Performance p
    JOIN Artist a ON p.Artist_ID = a.Artist_ID
    JOIN Event e ON p.Event_ID = e.Event_ID
    JOIN Festival f ON e.Festival_ID = f.Festival_ID
WHERE 
    p.Performance_Type_ID = 1
    AND p.Artist_ID IS NOT NULL
GROUP BY 
    a.Artist_ID, f.Festival_ID
HAVING 
    COUNT(*) > 2
ORDER BY 
    Warmup_Count DESC,
    Festival_Name,
    Artist_Name;