
insert into volunteer_profession(volunteer_id, profession_id)
select volunteer.uid, profession.uid
from volunteer
left join profession
on (profession in ('студент', 'врач','медперсонал', 'cтудент') and name = 'Санитар') OR
(profession = 'немедик' and name = 'Статистика');