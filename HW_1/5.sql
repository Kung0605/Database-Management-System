with Mon as (
    select date_format(g.Date, "%Y-%m") as tmp_mon
    from games as g
    group by tmp_mon
    order by count(*) desc
    limit 1
)
select g.away as away, Mon.tmp_mon as The_month, lag(g.Date) over(PARTITION BY g.Date) as pre
from games as g, Mon
where date_format(g.Date, "%Y-%m") = Mon.tmp_mon
group by away, Mon.tmp_mon
having min(g.Date - pre) 