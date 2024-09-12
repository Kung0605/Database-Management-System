select p._Type as 'Type'
from pitches as p
group by p._Type
having max(p.MPH) <= 95
order by p._Type asc;