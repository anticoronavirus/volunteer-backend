
insert into period(start, "end", hospital_id, demand, profession_id)
select p.start, p."end", p.hospital_id, pd.demand, pd.profession_id from
period p
inner join period_demand pd on
p.uid = pd.period_id
where p.profession_id <> pd.profession_id;