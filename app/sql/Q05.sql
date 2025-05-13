use musicfestival;

SELECT 
    a.Artist_ID,
    CONCAT(a.First_Name, ' ', a.Last_Name) AS Artist_Name,
    a.Stage_Name,
    TIMESTAMPDIFF(YEAR, a.Date_of_Birth, CURDATE()) AS Age,
    COUNT(DISTINCT f.Festival_ID) AS Festival_Count
FROM 
    Artist a
    JOIN Performance p ON a.Artist_ID = p.Artist_ID
    JOIN Event e ON p.Event_ID = e.Event_ID
    JOIN Festival f ON e.Festival_ID = f.Festival_ID
WHERE 
    TIMESTAMPDIFF(YEAR, a.Date_of_Birth, CURDATE()) < 30
    AND p.Artist_ID IS NOT NULL
GROUP BY 
    a.Artist_ID,
    Artist_Name,
    a.Stage_Name,
    Age
ORDER BY 
    Festival_Count DESC,
    Age ASC;