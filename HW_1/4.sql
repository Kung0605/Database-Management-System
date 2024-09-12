select pl.Name as Hitter, round(avg(h.num_p / (h.AB + h.BB + h.K)), 4) as 'avg_P/PA', round(avg(h.AB), 4) as avg_AB, round(avg(h.BB), 4) as avg_BB, round(avg(h.K), 4) as avg_K, (sum(h.AB) + sum(h.BB) + sum(h.K)) as tol_PA
from hitters as h, players as pl
where pl.Id = h.Hitter_Id and (h.AB + h.BB + h.K) > 0
group by h.Hitter_Id 
having (sum(h.AB) + sum(h.BB) + sum(h.K)) >= 20
order by round(avg(h.num_p / (h.AB + h.BB + h.K)), 4) desc
limit 3;