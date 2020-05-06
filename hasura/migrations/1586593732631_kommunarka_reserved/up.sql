
CREATE OR REPLACE FUNCTION public.shift_selector(_hospital_id uuid DEFAULT NULL::uuid)
 RETURNS SETOF vshift
 LANGUAGE sql
 STABLE
AS $function$ 
SELECT (days.date)::date AS date,
    period.start,
    period."end",
    count(DISTINCT period.hospital_id)::integer AS hospitalscount,
    sum(period.demand)::integer AS demand,
    (((sum(period.demand))::numeric - COALESCE(sum(vs_stat.subs), (0)::numeric) - sum(period.reserved)))::integer AS placesavailable,
    gen_random_uuid() as uid
    FROM (
    ((select
        start,
        "end",
        hospital_id,
        demand,
        CASE WHEN shortname = 'Коммунарка' THEN demand
             ELSE 0
        END AS reserved
        FROM period
        INNER JOIN hospital ON hospital.uid = hospital_id) period
        LEFT JOIN generate_series(
            (CURRENT_DATE)::timestamp without time zone,
            (CURRENT_DATE + '14 days'::interval),
            '1 day'::interval) days(date) ON (true))
        LEFT JOIN ( SELECT volunteer_shift.date,
                           volunteer_shift.start,
                           volunteer_shift."end",
                           count(volunteer_shift.uid) AS subs,
                           hospital_id
                    FROM volunteer_shift
        GROUP BY volunteer_shift.date,
        volunteer_shift.start,
        volunteer_shift."end",
        volunteer_shift.hospital_id) vs_stat ON (
            ((vs_stat.date = (days.date)::date) AND
             (vs_stat.start = period.start) AND
             (vs_stat."end" = period."end") AND
             vs_stat.hospital_id = period.hospital_id)))
  WHERE CASE WHEN _hospital_id IS NULL THEN TRUE ELSE period.hospital_id = _hospital_id END 
  GROUP BY (days.date)::date, period.start, period."end"
  ORDER BY date, period.start;


  $function$;