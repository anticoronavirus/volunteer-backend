
CREATE VIEW public.shifts AS
SELECT (days.date)::date AS date,
period.start,
period."end",
count(DISTINCT period.hospital_id) AS hospitalscount,
sum(period.demand) AS demand,
(((sum(period.demand))::numeric - COALESCE(sum(vs_stat.subs), (0)::numeric)))::bigint AS placesavailable
FROM ((public.period
LEFT JOIN generate_series((CURRENT_DATE)::timestamp without time zone, (CURRENT_DATE + '14 days'::interval), '1 day'::interval) days(date) ON (true))
LEFT JOIN ( SELECT volunteer_shift.date,
      volunteer_shift.start,
      volunteer_shift."end",
      count(volunteer_shift.uid) AS subs,
      volunteer_shift.hospital_id
     FROM public.volunteer_shift
    GROUP BY volunteer_shift.date, volunteer_shift.start, volunteer_shift."end", volunteer_shift.hospital_id) vs_stat ON (((vs_stat.date = (days.date)::date) AND (vs_stat.start = period.start) AND (vs_stat."end" = period."end") AND (vs_stat.hospital_id = period.hospital_id))))
    GROUP BY ((days.date)::date), period.start, period."end";