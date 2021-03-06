
insert into period_demand(period_id, profession_id, demand)
select period.uid,
       profession.uid,
       case when shortname = 'ЦКБ РАН'
       then (demand / 2.) :: integer
       else demand
       end as demand
from period
inner join hospital on hospital_id = hospital.uid
left join profession on
(profession.name IN ('Статистика', 'Прачечная') AND shortname = 'ЦКБ РАН') OR
(shortname != 'ЦКБ РАН' AND profession.name = 'Санитар');