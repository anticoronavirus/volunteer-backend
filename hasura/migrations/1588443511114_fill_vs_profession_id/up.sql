
update volunteer_shift set profession_id = pd.profession_id
from period_demand pd
where pd.uid = volunteer_shift.period_demand_id;