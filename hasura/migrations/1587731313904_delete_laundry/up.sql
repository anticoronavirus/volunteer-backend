
delete from period_demand
using profession
where profession.name = 'Прачечная' and
      profession.uid = profession_id;