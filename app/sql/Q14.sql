use musicfestival;

/* -------------------------------------------------------------
   1)  Συγκεντρώνουμε για κάθε εμφάνιση (Performance) ποιο genre
       εμφανίζεται, μέσω:
         - Artist  -> Artist_Genre
         - Band    -> ArtistBand -> Artist_Genre
   2)  Μετράμε πόσα performances είχε κάθε genre ανά έτος.
   3)  Ψάχνουμε ζεύγη διαδοχικών ετών με ίσο πλήθος (≥3).
----------------------------------------------------------------*/

WITH
-- A. Είδος για κάθε Performance (artist + band)
perf_genre AS (
    /* εμφανίσεις σόλο καλλιτεχνών */
    SELECT  p.Performance_ID,
            g.Genre_ID,
            YEAR(p.Start_Time) AS perf_year
    FROM    Performance      p
    JOIN    Artist_Genre     ag ON ag.Artist_ID = p.Artist_ID
    JOIN    Genre            g  ON g.Genre_ID   = ag.Genre_ID
    WHERE   p.Artist_ID IS NOT NULL

    UNION ALL

    /* εμφανίσεις μέσω συγκροτήματος */
    SELECT  p.Performance_ID,
            g.Genre_ID,
            YEAR(p.Start_Time) AS perf_year
    FROM    Performance      p
    JOIN    ArtistBand       ab ON ab.Band_ID   = p.Band_ID
    JOIN    Artist_Genre     ag ON ag.Artist_ID = ab.Artist_ID
    JOIN    Genre            g  ON g.Genre_ID   = ag.Genre_ID
    WHERE   p.Band_ID IS NOT NULL
),

-- B. Πλήθος εμφανίσεων ανά Genre και Έτος
genre_year_cnt AS (
    SELECT  Genre_ID,
            perf_year        AS yr,
            COUNT(*)         AS perf_cnt
    FROM    perf_genre
    GROUP BY Genre_ID, perf_year
),

-- C. Ζεύγη διαδοχικών ετών με ίδιο πλήθος (και ≥3)
genre_same_two_years AS (
    SELECT  g1.Genre_ID,
            g1.yr       AS year_1,
            g2.yr       AS year_2,
            g1.perf_cnt AS appearances
    FROM    genre_year_cnt g1
    JOIN    genre_year_cnt g2
           ON g1.Genre_ID = g2.Genre_ID
          AND g2.yr = g1.yr + 1          -- διαδοχικά έτη
          AND g1.perf_cnt = g2.perf_cnt  -- ίδιο πλήθος
          AND g1.perf_cnt >= 3           -- τουλάχιστον 3 εμφανίσεις
)

-- Τελικό αποτέλεσμα με το όνομα του είδους
SELECT  g.Genre_Name,
        s.year_1,
        s.year_2,
        s.appearances
FROM    genre_same_two_years s
JOIN    Genre g ON g.Genre_ID = s.Genre_ID
ORDER BY g.Genre_Name, s.year_1;
