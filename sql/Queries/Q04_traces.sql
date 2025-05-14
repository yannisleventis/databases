-- For original query
EXPLAIN FORMAT=JSON 
SELECT 
    a.Artist_ID,
    CONCAT(a.First_Name, ' ', a.Last_Name) AS Artist_Name,
    a.Stage_Name,
    ROUND(AVG(r.Artist_Interpretation), 2) AS Avg_Artist_Interpretation,
    ROUND(AVG(r.Overall_Impression), 2) AS Avg_Overall_Impression,
    COUNT(DISTINCT p.Performance_ID) AS Performances_Rated,
    COUNT(r.Rating_ID) AS Total_Ratings
FROM 
    Artist a
    JOIN Performance p ON a.Artist_ID = p.Artist_ID
    JOIN Rating r ON p.Performance_ID = r.Performance_ID
WHERE 
    a.Artist_ID = '11'
GROUP BY 
    a.Artist_ID, 
    Artist_Name, 
    a.Stage_Name
ORDER BY 
    Avg_Overall_Impression DESC;

-- For Force Index query

EXPLAIN FORMAT=JSON
SELECT 
    a.Artist_ID,
    CONCAT(a.First_Name, ' ', a.Last_Name) AS Artist_Name,
    a.Stage_Name,
    ROUND(AVG(r.Artist_Interpretation), 2) AS Avg_Artist_Interpretation,
    ROUND(AVG(r.Overall_Impression), 2) AS Avg_Overall_Impression,
    COUNT(DISTINCT p.Performance_ID) AS Performances_Rated,
    COUNT(r.Rating_ID) AS Total_Ratings
FROM 
    Artist a USE INDEX (PRIMARY)
    JOIN Performance p USE INDEX (fk_Performance_Artist) ON a.Artist_ID = p.Artist_ID
    JOIN Rating r ON p.Performance_ID = r.Performance_ID
WHERE 
    a.Artist_ID = '11'
GROUP BY 
    a.Artist_ID, 
    Artist_Name,
    a.Stage_Name;

-- For Straight Join query
EXPLAIN FORMAT=JSON

SELECT STRAIGHT_JOIN
    a.Artist_ID,
    CONCAT(a.First_Name, ' ', a.Last_Name) AS Artist_Name,
    a.Stage_Name,
    ROUND(AVG(r.Artist_Interpretation), 2) AS Avg_Artist_Interpretation,
    ROUND(AVG(r.Overall_Impression), 2) AS Avg_Overall_Impression,
    COUNT(DISTINCT p.Performance_ID) AS Performances_Rated,
    COUNT(r.Rating_ID) AS Total_Ratings
FROM 
    Artist a
    JOIN Performance p ON a.Artist_ID = p.Artist_ID
    JOIN Rating r ON p.Performance_ID = r.Performance_ID
WHERE 
    a.Artist_ID = '11'
GROUP BY 
    a.Artist_ID, 
    Artist_Name,
    a.Stage_Name;

-- For Merge Join query
EXPLAIN FORMAT=JSON

SELECT /*+ MERGE_JOIN(a, p, r) */
    a.Artist_ID,
    CONCAT(a.First_Name, ' ', a.Last_Name) AS Artist_Name,
    a.Stage_Name,
    ROUND(AVG(r.Artist_Interpretation), 2) AS Avg_Artist_Interpretation,
    ROUND(AVG(r.Overall_Impression), 2) AS Avg_Overall_Impression,
    COUNT(DISTINCT p.Performance_ID) AS Performances_Rated,
    COUNT(r.Rating_ID) AS Total_Ratings
FROM 
    Artist a
    JOIN Performance p ON a.Artist_ID = p.Artist_ID
    JOIN Rating r ON p.Performance_ID = r.Performance_ID
WHERE 
    a.Artist_ID = '11'
GROUP BY 
    a.Artist_ID, 
    Artist_Name, 
    a.Stage_Name;

-- For Hash Join query
EXPLAIN FORMAT=JSON

SELECT /*+ HASH_JOIN(a, p, r) */
    a.Artist_ID,
    CONCAT(a.First_Name, ' ', a.Last_Name) AS Artist_Name,
    a.Stage_Name,
    ROUND(AVG(r.Artist_Interpretation), 2) AS Avg_Artist_Interpretation,
    ROUND(AVG(r.Overall_Impression), 2) AS Avg_Overall_Impression,
    COUNT(DISTINCT p.Performance_ID) AS Performances_Rated,
    COUNT(r.Rating_ID) AS Total_Ratings
FROM 
    Artist a
    JOIN Performance p ON a.Artist_ID = p.Artist_ID
    JOIN Rating r ON p.Performance_ID = r.Performance_ID
WHERE 
    a.Artist_ID = '11'
GROUP BY 
    a.Artist_ID, 
    Artist_Name, 
    a.Stage_Name;