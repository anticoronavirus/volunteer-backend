
update period as p
set profession_id = pd.profession_id
from period_demand pd
where pd.period_id = p.uid;