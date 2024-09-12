with ttmp as (
    select round(hit_rate_diff, 2) as hit_rate_diff, tmp.w as w
    from (
        select floor(100 * abs((sum(case when h.Team = g.home then h.H else null end) / sum(case when h.Team = g.home then h.AB else null end) - sum(case when h.Team = g.away then h.H else null end) / sum(case when h.Team = g.away then h.AB else null end)))) / 100 as 'hit_rate_diff',
            (case when ((g.home_score > g.away_score and (sum(case when h.Team = g.home then h.H else null end) / sum(case when h.Team = g.home then h.AB else null end) - sum(case when h.Team = g.away then h.H else null end) / sum(case when h.Team = g.away then h.AB else null end)) > 0) or
                (g.home_score < g.away_score and (sum(case when h.Team = g.home then h.H else null end) / sum(case when h.Team = g.home then h.AB else null end) - sum(case when h.Team = g.away then h.H else null end) / sum(case when h.Team = g.away then h.AB else null end)) < 0))
                then 'win' else 'lose' end) as w
        from games as g         
        join hitters as h on h.Game = g.Game
        where year(g.Date) = 2021
        group by g.Game
    ) as tmp 
), 
h1 as (
select DISTINCT hit_rate_diff as hrd1
from ttmp
)
select hrd1, sum(case when ttmp.w = 'win' and ttmp.hit_rate_diff >= hrd1 then 1 else 0 end) / sum(case when ttmp.hit_rate_diff >= hrd1 then 1 else 0 end) as win_rate
from h1, ttmp
group by hrd1
having win_rate >= 0.95
order by hrd1
limit 1;