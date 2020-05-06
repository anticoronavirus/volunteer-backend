
update volunteer_shift set
       period_demand_id = pd.uid
from period_demand pd
left join profession p on
       pd.profession_id = p.uid
left join period pe on
       pe.uid = pd.period_id
left join hospital h on
       h.uid = pe.hospital_id
where ((p.name = 'Статистика' AND h.shortname = 'ЦКБ РАН') OR
       (h.shortname='ГКБ №52' AND p.name = 'Санитар')) AND
      volunteer_shift.hospital_id = h.uid AND
      volunteer_shift.start = pe.start AND
      volunteer_shift."end" = pe."end";