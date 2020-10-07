with next_professions as (
    insert into profession(name, description, requirements) values
        ('Хирургия', '', ''),
        ('Гнойная хирургия', '', ''),
        ('ОРИТ', '', ''),
        ('Кардиология', '', ''),
        ('Неврология', '', '')
    on conflict(name) do update set name = EXCLUDED.name
    returning uid
)
insert into hospital_profession
select
    hospital.uid as hospital_id,
    next_professions.uid as profession_id
from hospital
cross join next_professions on conflict do nothing;

with
default_profession as (
    insert into profession(name, description, requirements) values
        ('Кандидат', '', '')
    on conflict(name) do update set name = EXCLUDED.name
    returning uid
),
hospital_profession as (
    insert into hospital_profession(hospital_id, profession_id, "default")
    select
        hospital.uid,
        default_profession.uid,
        true
    from hospital
    cross join default_profession
    on conflict do nothing
),
next_requirements as (
    insert into requirement(name, protected) values
        ('Инструктаж', true),
        ('Анализ на ВИЧ', false),
        ('Флюорография', false),
        ('Прививка АДС (Дифтерия, столбняк)', false),
        ('Прививка от гепатита Б', false),
        ('Прививка от кори', false),
        ('Анализ на Covid 19 (антитела)', false)
    on conflict(name) do update set name = EXCLUDED.name, protected = EXCLUDED.protected
    returning uid
),
updated_users as (
    insert into volunteer_hospital_requirement(hospital_id, volunteer_id, requirement_id)
    select
        hospital.uid,
        filtered_shifts.volunteer_id,
        next_requirements.uid
    from (select distinct volunteer_id from volunteer_shift where confirmed=true)
        as filtered_shifts
    cross join hospital
    cross join next_requirements
    on conflict do nothing
)
insert into hospital_profession_requirement (hospital_id, profession_id, requirement_id)
select
    hospital.uid,
    default_profession.uid,
    next_requirements.uid
from hospital
cross join next_requirements
cross join default_profession on conflict do nothing;
