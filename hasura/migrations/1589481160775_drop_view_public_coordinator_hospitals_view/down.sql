CREATE VIEW public.coordinator_hospitals_view AS
SELECT hospital_coordinator.coophone,
hospital.uid,
hospital.name,
hospital.shortname,
hospital.phone,
hospital.address
FROM (public.hospital_coordinator
LEFT JOIN public.hospital ON ((hospital_coordinator.hospital_id = hospital.uid)));
