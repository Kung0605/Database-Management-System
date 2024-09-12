select tmp.Game as Game, ceiling(tmp.num_innings / 2) as num_innings 
from (
    select i.Game as Game, count(*) as num_innings
    from inning as i
    group by i.Game
) as tmp
where tmp.num_innings = (select max(t.num_innings) 
    from (
        select i.Game as Game, count(*) as num_innings
        from inning as i
        group by i.Game
    ) as t
)
order by Game asc;