
CREATE OR REPLACE FUNCTION public.shift_selector(
_hospital_id uuid DEFAULT NULL::uuid,
professions uuid[] DEFAULT '{}'::uuid[]
)
 RETURNS SETOF vshift
 LANGUAGE sql
 STABLE
AS $function$ 
SELECT
    period."date",
    period.start,
    period."end",
    count(DISTINCT period.hospital_id)::integer AS hospitalscount,
    sum(period.demand)::integer AS demand,
    (((sum(period.demand))::numeric - sum(period.subs) - sum(period.reserved)))::integer AS placesavailable,
    gen_random_uuid() as uid
    FROM
    (select
        (days.date_)::date as "date",
        start,
        "end",
        hospital_id,
      period_demand.demand,
      period_demand.profession_id,
        CASE WHEN shortname = 'Коммунарка' THEN period_demand.demand
             ELSE 0
        END AS reserved,
        COALESCE(vs_stat.subs, 0) as subs
     FROM period
     INNER JOIN hospital ON hospital.uid = hospital_id
     RIGHT JOIN period_demand ON period_id = period.uid
     LEFT JOIN generate_series(
         (CURRENT_DATE)::timestamp without time zone,
         (CURRENT_DATE + '14 days'::interval),
         '1 day'::interval) days(date_) ON (true)
     LEFT JOIN (select count(volunteer_id) as subs,
                      period_demand_id,
                      volunteer_shift."date"
                from volunteer_shift
                group by period_demand_id, volunteer_shift."date") as vs_stat
                ON vs_stat."date" = (days.date_)::date AND
                  vs_stat.period_demand_id = period_demand.uid) period
  WHERE
    CASE WHEN _hospital_id IS NULL
      THEN TRUE
      ELSE period.hospital_id = _hospital_id
    END AND
    CASE WHEN array_length(professions, 1) IS NULL
      THEN TRUE
      ELSE profession_id = ANY(professions)
    END
  GROUP BY period."date", period.start, period."end"
  ORDER BY period."date", period.start;
  $function$;