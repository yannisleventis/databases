/*  ---- ΠΙΝΑΚΕΣ που χρησιμοποιούνται ------------
    Rating            (Visitor_ID, Performance_ID, Artist_Interpretation,
                       Sound_Lighting, Stage_Presence, Organization, Overall_Impression)

    Performance       Performance_ID, Artist_ID , solo , Band_ID  optional

    -- Artist            (Artist_ID, First_Name, Last_Name)

    -- Visitor           (Visitor_ID, First_Name, Last_Name)
-- -------------------------------------------------- */
use musicfestival;

WITH rating_totals AS (
    /* 1. Υπολόγισε το συνολικό σκορ κάθε αξιολόγησης (5 κριτήρια) */
    SELECT  r.Visitor_ID,
            pf.Artist_ID,             -- συνδέουμε performance ➜ artist
            (   r.Artist_Interpretation +
                r.Sound_Lighting +
                r.Stage_Presence +
                r.Organization +
                r.Overall_Impression
            ) AS rating_sum
    FROM    Rating      r
    JOIN    Performance pf ON pf.Performance_ID = r.Performance_ID
    WHERE   pf.Artist_ID IS NOT NULL            -- κρατάμε μόνο σόλο καλλιτέχνες
),

visitor_artist_totals AS (
    /* 2. Συνολικό σκορ ενός επισκέπτη προς κάθε καλλιτέχνη */
    SELECT  Visitor_ID,
            Artist_ID,
            SUM(rating_sum)  AS total_score
    FROM    rating_totals
    GROUP BY Visitor_ID, Artist_ID
)

/* 3. Top-5 (με τα μεγαλύτερα συνολικά σκορ) */
SELECT  CONCAT(v.First_Name,' ',v.Last_Name)             AS VisitorName,
        CONCAT(a.First_Name,' ',a.Last_Name)             AS ArtistName,
        vat.total_score                                  AS TotalScore
FROM    visitor_artist_totals vat
JOIN    Visitor v ON v.Visitor_ID = vat.Visitor_ID
JOIN    Artist  a ON a.Artist_ID  = vat.Artist_ID
ORDER BY vat.total_score DESC
LIMIT 5;
