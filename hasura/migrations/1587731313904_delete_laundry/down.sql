
insert into period_demand(period_id, profession_id, demand)
select pe.uid, lau.uid, pd.demand
from period_demand pd
inner join profession p on
           p.uid = pd.profession_id
inner join period pe on
           pe.uid = pd.period_id
inner join hospital h on
           h.uid = pe.hospital_id
inner join (select uid
            from profession
            where name = 'Прачечная') lau on
           TRUE
where p.name = 'Статистика' and
      h.shortname = 'ЦКБ РАН'