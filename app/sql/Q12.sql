use musicfestival;

SELECT 
    DATE(p.Start_Time) AS Festival_Date,
    pr.Personnel_Role,
    SUM(
        CASE 
            WHEN pr.Personnel_Role = 'security' THEN CEIL(s.Maximum_Capacity * 0.05)
            WHEN pr.Personnel_Role = 'assistant' THEN CEIL(s.Maximum_Capacity * 0.02)
            ELSE 0
        END
    ) AS Required_Staff
FROM Performance p
JOIN Stage s ON p.Stage_ID = s.Stage_ID
JOIN Personnel_Role pr ON pr.Personnel_Role IN ('security', 'assistant')
GROUP BY Festival_Date, pr.Personnel_Role
ORDER BY Festival_Date, pr.Personnel_Role;
