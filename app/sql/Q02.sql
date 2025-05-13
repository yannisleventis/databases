use musicfestival;

SELECT 
    a.Artist_ID,
    CONCAT(a.First_Name, ' ', a.Last_Name) AS Artist_Name,
    a.Stage_Name,
    g.Genre_Name,
    CASE 
        WHEN MAX(CASE WHEN YEAR(f.Start_Date) = 2025 THEN 1 ELSE NULL END) IS NOT NULL 
        THEN 'Yes' 
        ELSE 'No' 
    END AS Performed_In_Year
FROM 
    Artist a
    JOIN Artist_Genre ag ON a.Artist_ID = ag.Artist_ID
    JOIN Genre g ON ag.Genre_ID = g.Genre_ID
    LEFT JOIN Performance p ON a.Artist_ID = p.Artist_ID
    LEFT JOIN Event e ON p.Event_ID = e.Event_ID
    LEFT JOIN Festival f ON e.Festival_ID = f.Festival_ID
WHERE 
    g.Genre_Name = 'Jazz'
GROUP BY 
    a.Artist_ID, Artist_Name, a.Stage_Name, g.Genre_Name
ORDER BY 
    Artist_Name;