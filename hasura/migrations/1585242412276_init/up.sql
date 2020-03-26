CREATE FUNCTION public.add_shift_professions(shift_id uuid, num integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    prof RECORD;
  BEGIN
    FOR prof IN SELECT name FROM profession LOOP
      INSERT INTO shift_profession("shift_id", "profession", number)
      VALUES (shift_id, prof.name, num);
    END LOOP;
    RETURN 1;
  END;
$$;
CREATE FUNCTION public.generate_shifts(start date DEFAULT CURRENT_DATE, end_ date DEFAULT CURRENT_DATE) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    iter date := start;
    suid UUID;
  BEGIN
    WHILE iter <= end_ LOOP
      INSERT INTO shift(start, "end", date)
      VALUES ('08:00', '14:00', iter) RETURNING uid INTO suid;
      PERFORM add_shift_professions(suid, 20);
      INSERT INTO shift(start, "end", date)
      VALUES ('14:00', '20:00', iter) RETURNING uid INTO suid;
      PERFORM add_shift_professions(suid, 20);
      INSERT INTO shift(start, "end", date)
      VALUES ('20:00', '08:00', iter) RETURNING uid INTO suid;
      PERFORM add_shift_professions(suid, 3);
      iter := iter + '1 day'::interval;
    END LOOP;
    RETURN 1;
  END;
$$;
CREATE TABLE public.profession (
    name character varying NOT NULL
);
CREATE TABLE public.shift (
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    start time with time zone NOT NULL,
    "end" time with time zone NOT NULL,
    date date NOT NULL
);
CREATE TABLE public.shift_profession (
    shift_id uuid NOT NULL,
    profession character varying NOT NULL,
    number integer NOT NULL
);
CREATE VIEW public.profession_shifts_view AS
 SELECT shift_profession.profession,
    shift.uid,
    shift.start,
    shift."end",
    shift.date
   FROM (public.shift_profession
     LEFT JOIN public.shift ON ((shift_profession.shift_id = shift.uid)));
CREATE VIEW public.shift_professions_view AS
 SELECT shift_profession.shift_id,
    profession.name,
    shift_profession.number
   FROM (public.shift_profession
     LEFT JOIN public.profession ON (((shift_profession.profession)::text = (profession.name)::text)));
CREATE TABLE public.volunteer (
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    fname character varying DEFAULT ''::character varying NOT NULL,
    mname character varying DEFAULT ''::character varying NOT NULL,
    lname character varying DEFAULT ''::character varying NOT NULL,
    phone character varying DEFAULT ''::character varying NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    profession character varying DEFAULT ''::character varying NOT NULL
);
CREATE TABLE public.volunteer_shift (
    volunteer_id uuid NOT NULL,
    shift_id uuid NOT NULL,
    confirmed boolean DEFAULT false NOT NULL
);
CREATE VIEW public.shift_volunteers_view AS
 SELECT volunteer_shift.shift_id,
    volunteer.uid,
    volunteer.fname,
    volunteer.mname,
    volunteer.lname,
    volunteer.phone,
    volunteer.profession
   FROM (public.volunteer_shift
     LEFT JOIN public.volunteer ON ((volunteer_shift.volunteer_id = volunteer.uid)));
CREATE VIEW public.volunteer_shifts_view AS
 SELECT volunteer_shift.volunteer_id,
    shift.uid,
    shift.start,
    shift."end",
    shift.date
   FROM (public.volunteer_shift
     LEFT JOIN public.shift ON ((volunteer_shift.shift_id = shift.uid)));
ALTER TABLE ONLY public.profession
    ADD CONSTRAINT profession_pkey PRIMARY KEY (name);
ALTER TABLE ONLY public.shift
    ADD CONSTRAINT shift_pkey PRIMARY KEY (uid);
ALTER TABLE ONLY public.shift_profession
    ADD CONSTRAINT shift_profession_pkey PRIMARY KEY (shift_id, profession);
ALTER TABLE ONLY public.shift
    ADD CONSTRAINT shift_start_end_date_key UNIQUE (start, "end", date);
ALTER TABLE ONLY public.volunteer
    ADD CONSTRAINT volunteer_phone_email_key UNIQUE (phone, email);
ALTER TABLE ONLY public.volunteer
    ADD CONSTRAINT volunteer_pkey PRIMARY KEY (uid);
ALTER TABLE ONLY public.volunteer_shift
    ADD CONSTRAINT volunteer_shift_pkey PRIMARY KEY (volunteer_id, shift_id);
ALTER TABLE ONLY public.shift_profession
    ADD CONSTRAINT shift_profession_professsion_fkey FOREIGN KEY (profession) REFERENCES public.profession(name) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.shift_profession
    ADD CONSTRAINT shift_profession_shift_id_fkey FOREIGN KEY (shift_id) REFERENCES public.shift(uid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.volunteer
    ADD CONSTRAINT volunteer_profession_fkey FOREIGN KEY (profession) REFERENCES public.profession(name) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.volunteer_shift
    ADD CONSTRAINT volunteer_shift_shift_id_fkey FOREIGN KEY (shift_id) REFERENCES public.shift(uid) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.volunteer_shift
    ADD CONSTRAINT volunteer_shift_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.volunteer(uid) ON UPDATE CASCADE ON DELETE CASCADE;
