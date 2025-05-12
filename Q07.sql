use musicfestival;

SELECT 
    f.Festival_ID,
    f.Name AS Festival_Name,
    AVG(el.Level_ID) AS Average_Experience_Level
FROM 
    Festival AS f
JOIN 
    Event AS e ON f.Festival_ID = e.Festival_ID
JOIN 
    Performance AS p ON e.Event_ID = p.Event_ID
JOIN 
    PerformancePersonnel AS pp ON p.Performance_ID = pp.Performance_ID
JOIN 
    Personnel pe ON pp.Personnel_ID = pe.Personnel_ID
JOIN 
    Experience_Level el ON pe.Experience_Level_ID = el.Level_ID
JOIN
    Personnel_Role pr ON pe.Personnel_Role_ID = pr.Role_ID
WHERE 
    pr.Personnel_Role LIKE '%tech%'
    OR pr.Personnel_Role LIKE '%Tech%'
    OR pr.Personnel_Role IN ('Sound Engineer', 'Lighting Engineer')
GROUP BY 
    f.Festival_ID, f.Name
ORDER BY 
    Average_Experience_Level ASC
LIMIT 1;