
update period_demand as pd set demand = pd.demand * 2
      from profession p, period pe
      inner join hospital h on
                 h.uid = pe.hospital_id
      where pe.uid = pd.period_id AND
            p.uid = pd.profession_id and
            p.name = 'Статистика' and
            h.shortname = 'ЦКБ РАН'
      returning pd.uid;