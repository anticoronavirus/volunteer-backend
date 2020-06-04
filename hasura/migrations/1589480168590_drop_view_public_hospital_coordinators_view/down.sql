CREATE VIEW public.hospital_coordinators_view AS
SELECT hospital_coordinator.hospital_id,
volunteer.uid,
volunteer.fname,
volunteer.mname,
volunteer.lname,
volunteer.phone,
volunteer.email,
volunteer.role,
volunteer.password,
volunteer.comment,
volunteer.created_at,
volunteer.updated_at
FROM (public.hospital_coordinator
LEFT JOIN public.volunteer ON ((hospital_coordinator.coophone = (volunteer.phone)::text)));
