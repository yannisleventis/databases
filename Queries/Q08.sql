use musicfestival;

SELECT 
    p.Personnel_ID,
    p.Personnel_Name,
    pr.Personnel_Role
FROM 
    Personnel p
JOIN 
    Personnel_Role pr ON p.Personnel_Role_ID = pr.Role_ID
LEFT JOIN (
    SELECT DISTINCT pp.Personnel_ID
    FROM PerformancePersonnel pp
    JOIN Performance perf ON pp.Performance_ID = perf.Performance_ID
    WHERE DATE(perf.Start_Time) = :specific_date
) work_on_date ON p.Personnel_ID = work_on_date.Personnel_ID
WHERE 
    pr.Personnel_Role IN ('technical', 'security', 'assistant')
    AND work_on_date.Personnel_ID IS NULL
ORDER BY 
    pr.Personnel_Role, p.Personnel_Name;