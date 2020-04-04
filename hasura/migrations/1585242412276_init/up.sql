CREATE TABLE public.hospital (
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    shortname character varying NOT NULL,
    phone character varying NOT NULL,
    address character varying NOT NULL
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
    password character varying DEFAULT ''::character varying NOT NULL
);
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
    volunteer.password
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
CREATE TABLE public.special_shift (
    start time with time zone NOT NULL,
    "end" time with time zone NOT NULL,
    needs jsonb NOT NULL,
    date date NOT NULL,
    hospital_id uuid NOT NULL
);
CREATE TABLE public.volunteer_shift (
    start time with time zone NOT NULL,
    "end" time with time zone NOT NULL,
    date date NOT NULL,
    volunteer_id uuid NOT NULL,
    confirmed boolean NOT NULL,
    uid uuid NOT NULL
);
ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_address_key UNIQUE (address);
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
ALTER TABLE ONLY public.special_shift
    ADD CONSTRAINT special_shift_pkey PRIMARY KEY (start, "end");
ALTER TABLE ONLY public.special_shift
    ADD CONSTRAINT special_shift_start_end_date_key UNIQUE (start, "end", date);
ALTER TABLE ONLY public.volunteer
    ADD CONSTRAINT volunteer_pkey PRIMARY KEY (uid);
ALTER TABLE ONLY public.volunteer_shift
    ADD CONSTRAINT volunteer_shift_pkey PRIMARY KEY (uid);
ALTER TABLE ONLY public.period
    ADD CONSTRAINT period_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(uid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.special_shift
    ADD CONSTRAINT special_shift_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(uid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.volunteer_shift
    ADD CONSTRAINT volunteer_shift_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.volunteer(uid) ON UPDATE CASCADE ON DELETE CASCADE;
