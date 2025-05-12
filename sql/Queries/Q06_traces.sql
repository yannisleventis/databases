EXPLAIN FORMAT=JSON 
SELECT 
    v.Visitor_ID,
    CONCAT(v.First_Name, ' ', v.Last_Name) AS Visitor_Name,
    p.Performance_ID,
    CASE 
        WHEN p.Artist_ID IS NOT NULL THEN CONCAT(a.First_Name, ' ', a.Last_Name) 
        WHEN p.Band_ID IS NOT NULL THEN b.Band_Name
        ELSE 'Unknown'
    END AS Performer,
    pt.Performance_Type,
    p.Start_Time,
    s.Stage_ID,
    e.Event_Name,
    
    AVG(r.Artist_Interpretation) AS Avg_Artist_Interpretation,
    AVG(r.Sound_Lighting) AS Avg_Sound_Lighting,
    AVG(r.Stage_Presence) AS Avg_Stage_Presence,
    AVG(r.Organization) AS Avg_Organization,
    AVG(r.Overall_Impression) AS Avg_Overall_Impression,
    
    ROUND(
        (AVG(r.Artist_Interpretation) + AVG(r.Sound_Lighting) + 
         AVG(r.Stage_Presence) + AVG(r.Organization) + AVG(r.Overall_Impression)) / 5, 
        2
    ) AS Overall_Average,
    
    COUNT(r.Rating_ID) AS Rating_Count
FROM 
    Visitor v
    JOIN Ticket t ON v.Visitor_ID = t.Visitor_ID
    JOIN Event e ON t.Event_ID = e.Event_ID
    JOIN Performance p ON e.Event_ID = p.Event_ID
    JOIN Stage s ON p.Stage_ID = s.Stage_ID
    JOIN Performance_Type pt ON p.Performance_Type_ID = pt.Performance_Type_ID
    LEFT JOIN Artist a ON p.Artist_ID = a.Artist_ID
    LEFT JOIN Band b ON p.Band_ID = b.Band_ID
    LEFT JOIN Rating r ON p.Performance_ID = r.Performance_ID AND v.Visitor_ID = r.Visitor_ID
WHERE 
    v.Visitor_ID = '69'  
    AND t.Ticket_Status_ID = (SELECT Status_ID FROM Ticket_Status WHERE Status_Name = 'activated')
GROUP BY 
    v.Visitor_ID, 
    p.Performance_ID,
    Performer,
    pt.Performance_Type,
    p.Start_Time,
    s.Stage_ID,
    e.Event_Name;