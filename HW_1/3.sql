select p.Pitcher_Id as Pitcher_Id, pl.Name as Pitcher, round(sum(IP), 1) as tol_innings
from pitchers as p, games as g, players as pl 
where p.Game = g.Game and g.date between '2021-04-01' and '2021-11-30' and pl.Id = p.Pitcher_Id 
group by p.Pitcher_Id
order by sum(IP) desc
limit 3;