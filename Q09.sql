use musicfestival;

SELECT 
    v.Visitor_ID,
    v.First_Name,
    v.Last_Name,
    YEAR(perf.Start_Time) AS Year,
    COUNT(DISTINCT perf.Performance_ID) AS Performance_Count
FROM 
    Visitor v
JOIN 
    Ticket t ON v.Visitor_ID = t.Visitor_ID
JOIN 
    Event e ON t.Event_ID = e.Event_ID
JOIN 
    Performance perf ON e.Event_ID = perf.Event_ID
WHERE 
    t.Ticket_Status_ID = (SELECT Status_ID FROM Ticket_Status WHERE Status_Name = 'used')
GROUP BY 
    v.Visitor_ID, v.First_Name, v.Last_Name, YEAR(perf.Start_Time)
HAVING 
    Performance_Count > 3
    AND Performance_Count IN (
        SELECT 
            COUNT(DISTINCT p2.Performance_ID) AS Count
        FROM 
            Visitor v2
        JOIN 
            Ticket t2 ON v2.Visitor_ID = t2.Visitor_ID
        JOIN 
            Event e2 ON t2.Event_ID = e2.Event_ID
        JOIN 
            Performance p2 ON e2.Event_ID = p2.Event_ID
        WHERE 
            t2.Ticket_Status_ID = (SELECT Status_ID FROM Ticket_Status WHERE Status_Name = 'used')
        GROUP BY 
            v2.Visitor_ID, YEAR(p2.Start_Time)
        HAVING 
            COUNT(DISTINCT p2.Performance_ID) > 3
    )
ORDER BY 
    Year, Performance_Count DESC, v.Last_Name, v.First_Name;