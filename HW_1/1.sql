select count(*) as cnt 
from games 
where abs(away_score - home_score) >= 10;