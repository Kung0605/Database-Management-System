select tmp.Pitcher, count(tmp.Pitcher) as cnt, 
    ROUND(AVG(strikeouts_2020 ), 4) AS '2020_avg_K/9',
    ROUND(AVG(strikeouts_2021 ), 4) AS '2021_avg_K/9',
    CONCAT(ROUND(AVG(pc20), 4), '-', ROUND(AVG(st20), 4)) AS '2020_PC-ST',
    CONCAT(ROUND(AVG(pc21), 4), '-', ROUND(AVG(st21), 4)) AS '2021_PC-ST'
from (
    SELECT CASE WHEN COUNT(DISTINCT Team) = 1 THEN 'Unchanged' ELSE 'Changed' END AS Pitcher, p.Pitcher_Id as Id,
    AVG(CASE WHEN YEAR(g.Date) = 2020 THEN 9*K/IP ELSE NULL END) AS strikeouts_2020,
    AVG(CASE WHEN YEAR(g.Date) = 2021 THEN 9*K/IP ELSE NULL END) AS strikeouts_2021, 
    AVG(CASE WHEN YEAR(g.Date) = 2020 THEN CAST(SUBSTRING_INDEX(p.`PC_ST`, '-', 1) AS FLOAT) ELSE NULL END) AS pc20,
    AVG(CASE WHEN YEAR(g.Date) = 2021 THEN CAST(SUBSTRING_INDEX(p.`PC_ST`, '-', 1) AS FLOAT) ELSE NULL END) AS pc21,
    AVG(CASE WHEN YEAR(g.Date) = 2020 THEN CAST(SUBSTRING_INDEX(p.`PC_ST`, '-', -1) AS FLOAT) ELSE NULL END) AS st20,
    AVG(CASE WHEN YEAR(g.Date) = 2020 THEN CAST(SUBSTRING_INDEX(p.`PC_ST`, '-', -1) AS FLOAT) ELSE NULL END) AS st21
    FROM pitchers AS p
    JOIN games AS g ON p.Game = g.Game
    WHERE g.Date BETWEEN '2020-01-01' AND '2021-12-31' and p.IP > 0
    GROUP BY p.Pitcher_Id
    HAVING SUM(p.IP) > 50
    AND SUM(CASE WHEN YEAR(g.Date) = 2021 THEN p.IP ELSE 0 END) > 0
    AND SUM(CASE WHEN YEAR(g.Date) = 2020 THEN p.IP ELSE 0 END) > 0
) as tmp
group by Pitcher
order by Pitcher