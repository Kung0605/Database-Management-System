select * from (
    SELECT h.Team as Team, pl.Name AS Hitter, round(avg(h.H / h.AB), 4) as avg_hit_rate, sum(h.AB) as tol_hit, winner.win_rate as win_rate
    FROM hitters AS h
    JOIN games AS g ON h.Game = g.Game
    JOIN players AS pl ON h.Hitter_Id = pl.Id
    JOIN (
        SELECT w.win AS win, w.num / (l.num + w.num) AS win_rate
        FROM (
            SELECT IF(away_score > home_score, away, home) AS win, COUNT(*) AS num
            FROM games AS g
            WHERE g.Date BETWEEN '2021-01-01' AND '2021-12-31'
            GROUP BY win
        ) AS w
        JOIN (
            SELECT IF(away_score < home_score, away, home) AS lose, COUNT(*) AS num
            FROM games AS g
            WHERE g.Date BETWEEN '2021-01-01' AND '2021-12-31'
            GROUP BY lose
        ) AS l ON w.win = l.lose
        GROUP BY w.win
        ORDER BY win_rate DESC
        LIMIT 5
    ) AS winner ON h.Team = winner.win
    WHERE g.Date BETWEEN '2021-01-01' AND '2021-12-31' and h.AB > 0
    GROUP BY h.Team, h.Hitter_Id
    having sum(h.AB) > 100
    order by winner.win_rate desc, avg_hit_rate desc
) as o
where avg_hit_rate in (
    select max(avg_hit_rate)
    from (
        SELECT h.Team as Team, pl.Name AS Hitter, round(avg(h.H / h.AB), 4) as avg_hit_rate, sum(h.AB) as tol_hit, winner.win_rate as win_rate
        FROM hitters AS h
        JOIN games AS g ON h.Game = g.Game
        JOIN players AS pl ON h.Hitter_Id = pl.Id
        JOIN (
            SELECT w.win AS win, w.num / (l.num + w.num) AS win_rate
            FROM (
                SELECT IF(away_score > home_score, away, home) AS win, COUNT(*) AS num
                FROM games AS g
                WHERE g.Date BETWEEN '2021-01-01' AND '2021-12-31'
                GROUP BY win
            ) AS w
            JOIN (
                SELECT IF(away_score < home_score, away, home) AS lose, COUNT(*) AS num
                FROM games AS g
                WHERE g.Date BETWEEN '2021-01-01' AND '2021-12-31'
                GROUP BY lose
            ) AS l ON w.win = l.lose
            GROUP BY w.win
            ORDER BY win_rate DESC
            LIMIT 5
        ) AS winner ON h.Team = winner.win
        WHERE g.Date BETWEEN '2021-01-01' AND '2021-12-31' and h.AB > 0
        GROUP BY h.Team, h.Hitter_Id
        having sum(h.AB) > 100
        order by winner.win_rate desc, avg_hit_rate desc
    ) as i 
    where Team = i.Team
    GROUP BY i.Team
)