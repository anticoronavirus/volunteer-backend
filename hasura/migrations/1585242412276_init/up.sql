CREATE TABLE public.hospital (
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    shortname character varying NOT NULL,
    phone character varying NOT NULL,
    address character varying NOT NULL
);
CREATE TABLE public.hospital_coordinator (
    hospital_id uuid NOT NULL,
    coophone text NOT NULL
);
CREATE VIEW public.coordinator_hospitals_view AS
 SELECT hospital_coordinator.coophone,
    hospital.uid,
    hospital.name,
    hospital.shortname,
    hospital.phone,
    hospital.address
   FROM (public.hospital_coordinator
     LEFT JOIN public.hospital ON ((hospital_coordinator.hospital_id = hospital.uid)));
CREATE TABLE public.hint (
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    text character varying NOT NULL,
    name bpchar NOT NULL
);
CREATE TABLE public.volunteer (
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    fname character varying NOT NULL,
    mname character varying NOT NULL,
    lname character varying NOT NULL,
    phone character varying NOT NULL,
    email character varying NOT NULL,
    blacklisted boolean DEFAULT false NOT NULL,
    blacklist_comment text NOT NULL,
    role character varying NOT NULL,
    password character varying DEFAULT ''::character varying NOT NULL,
    hospital_id uuid
);
CREATE VIEW public.hospital_coordinators_view AS
 SELECT hospital_coordinator.hospital_id,
    volunteer.uid,
    volunteer.fname,
    volunteer.mname,
    volunteer.lname,
    volunteer.phone,
    volunteer.email,
    volunteer.blacklisted,
    volunteer.blacklist_comment,
    volunteer.role,
    volunteer.password
   FROM (public.hospital_coordinator
     LEFT JOIN public.volunteer ON ((hospital_coordinator.coophone = (volunteer.phone)::text)));
CREATE VIEW public.me AS
 SELECT volunteer.uid,
    volunteer.fname,
    volunteer.mname,
    volunteer.lname,
    volunteer.phone,
    volunteer.email,
    volunteer.blacklisted,
    volunteer.blacklist_comment,
    volunteer.role,
    volunteer.password,
    volunteer.hospital_id
   FROM public.volunteer;
CREATE TABLE public.period (
    start time with time zone NOT NULL,
    "end" time with time zone NOT NULL,
    hospital_id uuid NOT NULL,
    demand integer NOT NULL,
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL
);
CREATE TABLE public.profession (
    name text NOT NULL
);
CREATE TABLE public.role (
    name character varying NOT NULL
);
CREATE TABLE public.seen_hint (
    user_id uuid NOT NULL,
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    hint_id uuid NOT NULL
);
CREATE TABLE public.volunteer_shift (
    start time with time zone NOT NULL,
    "end" time with time zone NOT NULL,
    date date NOT NULL,
    volunteer_id uuid NOT NULL,
    confirmed boolean NOT NULL,
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL
);
CREATE VIEW public.shifts AS
 SELECT (days.days)::date AS meh,
    period.start,
    period."end",
    count(DISTINCT period.hospital_id) AS hospitalscount,
    sum(period.demand) AS demand,
    (sum(period.demand) - count(DISTINCT volunteer_shift.uid)) AS placesavailable
   FROM ((public.period
     LEFT JOIN generate_series((CURRENT_DATE)::timestamp without time zone, (CURRENT_DATE + '14 days'::interval), '1 day'::interval) days(days) ON (true))
     LEFT JOIN public.volunteer_shift ON (((volunteer_shift.date = days.days) AND (volunteer_shift.start = period.start) AND (volunteer_shift."end" = period."end"))))
  GROUP BY ((days.days)::date), period.start, period."end";
CREATE TABLE public.special_shift (
    start time with time zone NOT NULL,
    "end" time with time zone NOT NULL,
    needs jsonb NOT NULL,
    date date NOT NULL,
    hospital_id uuid NOT NULL
);
ALTER TABLE ONLY public.hint
    ADD CONSTRAINT hint_pkey PRIMARY KEY (name);
ALTER TABLE ONLY public.hint
    ADD CONSTRAINT hint_uid_key UNIQUE (uid);
ALTER TABLE ONLY public.hint
    ADD CONSTRAINT hints_text_key UNIQUE (text);
ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_address_key UNIQUE (address);
ALTER TABLE ONLY public.hospital_coordinator
    ADD CONSTRAINT hospital_coordinator_pkey PRIMARY KEY (hospital_id, coophone);
ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_name_key UNIQUE (name);
ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_phone_key UNIQUE (phone);
ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_pkey PRIMARY KEY (uid);
ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_uid_key UNIQUE (uid);
ALTER TABLE ONLY public.period
    ADD CONSTRAINT period_pkey PRIMARY KEY (uid);
ALTER TABLE ONLY public.profession
    ADD CONSTRAINT profession_name_key UNIQUE (name);
ALTER TABLE ONLY public.profession
    ADD CONSTRAINT profession_pkey PRIMARY KEY (name);
ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (name);
ALTER TABLE ONLY public.seen_hint
    ADD CONSTRAINT seen_hint_pkey PRIMARY KEY (uid);
ALTER TABLE ONLY public.seen_hint
    ADD CONSTRAINT seen_hint_user_id_hint_id_key UNIQUE (user_id, hint_id);
ALTER TABLE ONLY public.special_shift
    ADD CONSTRAINT special_shift_pkey PRIMARY KEY (start, "end");
ALTER TABLE ONLY public.special_shift
    ADD CONSTRAINT special_shift_start_end_date_key UNIQUE (start, "end", date);
ALTER TABLE ONLY public.volunteer
    ADD CONSTRAINT volunteer_phone_key UNIQUE (phone);
ALTER TABLE ONLY public.volunteer
    ADD CONSTRAINT volunteer_pkey PRIMARY KEY (uid);
ALTER TABLE ONLY public.volunteer_shift
    ADD CONSTRAINT volunteer_shift_pkey PRIMARY KEY (uid);
ALTER TABLE ONLY public.volunteer_shift
    ADD CONSTRAINT volunteer_shift_start_date_end_volunteer_id_key UNIQUE (start, date, "end", volunteer_id);
ALTER TABLE ONLY public.volunteer_shift
    ADD CONSTRAINT volunteer_shift_uid_key UNIQUE (uid);
ALTER TABLE ONLY public.hospital_coordinator
    ADD CONSTRAINT hospital_coordinator_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(uid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.period
    ADD CONSTRAINT period_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(uid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.seen_hint
    ADD CONSTRAINT seen_hint_hint_id_fkey FOREIGN KEY (hint_id) REFERENCES public.hint(uid) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.seen_hint
    ADD CONSTRAINT seen_hint_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.volunteer(uid) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.special_shift
    ADD CONSTRAINT special_shift_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(uid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.volunteer
    ADD CONSTRAINT volunteer_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(uid) ON UPDATE SET NULL ON DELETE SET NULL;
ALTER TABLE ONLY public.volunteer_shift
    ADD CONSTRAINT volunteer_shift_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.volunteer(uid) ON UPDATE CASCADE ON DELETE CASCADE;
