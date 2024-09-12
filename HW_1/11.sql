#Find win rate of home team, output is 0.5350
select (sum(case when home_score > away_score then 1 else 0 end) / count(*)) as home_win_rate
from games;

#Find win rate of higher average AVG, output = 0.5224
select ((sum(case when (home_score > away_score) and ((
    select t.avg_hit_rate 
    from (
        select h.Team as Team, round(sum(h.H) / sum(h.AB), 4) as avg_hit_rate
        from hitters as h
        group by h.Team
    ) as t
    where t.Team = g.home) > (
    select t2.avg_hit_rate 
    from (
        select h.Team as Team, round(sum(h.H) / sum(h.AB), 4) as avg_hit_rate
        from hitters as h
        group by h.Team
    ) as t2
    where t2.Team = g.away))then 1 else 0 end) + sum(case when (home_score > away_score) and ((
    select t.avg_hit_rate 
    from (
        select h.Team as Team, round(sum(h.H) / sum(h.AB), 4) as avg_hit_rate
        from hitters as h
        group by h.Team
    ) as t
    where t.Team = g.away) > (
    select t2.avg_hit_rate 
    from (
        select h.Team as Team, round(sum(h.H) / sum(h.AB), 4) as avg_hit_rate
        from hitters as h
        group by h.Team
    ) as t2
    where t2.Team = g.home))then 1 else 0 end)) / count(g.Game))
from games as g;

#Find win rate of lower_ERA, output = 0.5350
select ((sum(case when (home_score > away_score) and ((
    select t.ERA
    from (
        select pi.Team as Team, round(9 * sum(pi.ER) / sum(pi.IP), 4) as ERA
        from pitchers as pi
        group by pi.Team
    ) as t
    where t.Team = g.home) < (
    select t2.ERA
    from (
        select pi.Team as Team, round(9 * sum(pi.ER) / sum(pi.IP), 4) as ERA
        from pitchers as pi
        group by pi.Team
    ) as t2
    where t2.Team = g.away))then 1 else 0 end) + sum(case when (home_score > away_score) and ((
    select t.ERA 
    from (
        select pi.Team as Team, round(9 * sum(pi.ER) / sum(pi.IP), 4) as ERA
        from pitchers as pi
        group by pi.Team
    ) as t
    where t.Team = g.away) < (
    select t2.ERA
    from (
        select pi.Team as Team, round(9 * sum(pi.ER) / sum(pi.IP), 4) as ERA
        from pitchers as pi
        group by pi.Team
    ) as t2
    where t2.Team = g.home))then 1 else 0 end)) / count(g.Game))
from games as g
#it seems that there is no trivial difference between method using ERA, AVG, home and away