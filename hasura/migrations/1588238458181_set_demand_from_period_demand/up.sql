
update period as p
set demand = pd.demand
from period_demand pd
where pd.period_id = p.uid;