SELECT 
    YEAR(f.Start_Date) AS Festival_Year,
    tc.Category_Name AS Ticket_Category,
    pm.Method_Name AS Payment_Method,
    COUNT(t.Ticket_ID) AS Tickets_Sold,
    SUM(t.Cost) AS Revenue,
    SUM(SUM(t.Cost)) OVER(PARTITION BY YEAR(f.Start_Date), tc.Category_Name) AS Total_Category_Revenue,
    SUM(COUNT(t.Ticket_ID)) OVER(PARTITION BY YEAR(f.Start_Date), tc.Category_Name) AS Total_Category_Tickets,
    SUM(SUM(t.Cost)) OVER(PARTITION BY YEAR(f.Start_Date)) AS Total_Year_Revenue
FROM 
    Ticket t
    JOIN Payment_Method pm ON t.Payment_Method_ID = pm.Method_ID
    JOIN Ticket_Category tc ON t.Category_ID = tc.Category_ID
    JOIN Event e ON t.Event_ID = e.Event_ID
    JOIN Festival f ON e.Festival_ID = f.Festival_ID
GROUP BY 
    YEAR(f.Start_Date), 
    tc.Category_Name,
    pm.Method_Name
ORDER BY 
    Festival_Year DESC,
    Ticket_Category,
    Revenue DESC;