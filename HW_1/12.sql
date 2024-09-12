#USE WHIP(on base / IP) and ERA(ER / IP) to find best pitchers 
#and find intersection of pitchers of both ERA and WHIP 
#For checking the pitchers have played in MLB for long time so that the data is worthy
#we can constraint the innings more than 100
select pl.Name as Pitcher 
from pitchers as p 
join players as pl on pl.Id = p.Pitcher_Id
where pl.Id in (
    select t1.Id
    from (
        select p1.Pitcher_Id as Id, round(sum(p1.h + p1.BB) / sum(p1.IP), 4) as WHIP
        from pitchers as p1
        group by p1.Pitcher_Id
        having sum(p1.IP) > 100
        order by WHIP asc
        limit 20
    ) as t1
) and pl.Id in (
    select t2.Id
    from (
        select p2.Pitcher_Id as Id, round(9 * sum(p2.ER) / sum(p2.IP), 4) as ERA
        from pitchers as p2
        group by p2.Pitcher_Id
        having sum(p2.IP) > 100
        order by ERA asc
        limit 20
    ) as t2
)
group by Pitcher 
order by Pitcher