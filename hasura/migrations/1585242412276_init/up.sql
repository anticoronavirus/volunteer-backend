CREATE FUNCTION public.drop_shifts_for() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
delete from volunteer_shift where volunteer_id = NEW.volunteer_id;
end;
$$;
CREATE FUNCTION public.drop_shifts_for(vuid uuid) RETURNS void
    LANGUAGE sql STABLE
    AS $$
delete from volunteer_shift where volunteer_id = vuid;
$$;
CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;
CREATE TABLE public.vshift (
    date date NOT NULL,
    start time with time zone NOT NULL,
    "end" time with time zone NOT NULL,
    hospitalscount integer NOT NULL,
    demand integer NOT NULL,
    placesavailable integer NOT NULL,
    uid uuid NOT NULL
);
CREATE FUNCTION public.shift_selector(hospital_ids uuid[] DEFAULT NULL::uuid[]) RETURNS SETOF public.vshift
    LANGUAGE sql STABLE
    AS $$ 
SELECT (days.date)::date AS date,
    period.start,
    period."end",
    count(DISTINCT period.hospital_id)::integer AS hospitalscount,
    sum(period.demand)::integer AS demand,
    (((sum(period.demand))::numeric - COALESCE(sum(vs_stat.subs), (0)::numeric)))::integer AS placesavailable,
    gen_random_uuid() as uid
   FROM ((period
     LEFT JOIN generate_series((CURRENT_DATE)::timestamp without time zone, (CURRENT_DATE + '14 days'::interval), '1 day'::interval) days(date) ON (true))
     LEFT JOIN ( SELECT volunteer_shift.date,
            volunteer_shift.start,
            volunteer_shift."end",
            count(volunteer_shift.uid) AS subs,
            hospital_id
           FROM volunteer_shift
          GROUP BY volunteer_shift.date, volunteer_shift.start, volunteer_shift."end", volunteer_shift.hospital_id) vs_stat ON (((vs_stat.date = (days.date)::date) AND (vs_stat.start = period.start) AND (vs_stat."end" = period."end") AND vs_stat.hospital_id = period.hospital_id)))
  WHERE CASE WHEN hospital_ids IS NULL THEN TRUE ELSE period.hospital_id = ANY(hospital_ids) END 
  GROUP BY ((days.date)::date), period.start, period."end"
  ORDER BY date, period.start;
  $$;
CREATE FUNCTION public.shift_selector2(hospital_ids text[] DEFAULT NULL::text[]) RETURNS SETOF public.vshift
    LANGUAGE sql STABLE
    AS $$ 
SELECT (days.date)::date AS date,
    period.start,
    period."end",
    count(DISTINCT period.hospital_id)::integer AS hospitalscount,
    sum(period.demand)::integer AS demand,
    (((sum(period.demand))::numeric - COALESCE(sum(vs_stat.subs), (0)::numeric)))::integer AS placesavailable,
    gen_random_uuid() as uid
   FROM ((period
     LEFT JOIN generate_series((CURRENT_DATE)::timestamp without time zone, (CURRENT_DATE + '14 days'::interval), '1 day'::interval) days(date) ON (true))
     LEFT JOIN ( SELECT volunteer_shift.date,
            volunteer_shift.start,
            volunteer_shift."end",
            count(volunteer_shift.uid) AS subs,
            hospital_id
           FROM volunteer_shift
          GROUP BY volunteer_shift.date, volunteer_shift.start, volunteer_shift."end", volunteer_shift.hospital_id) vs_stat ON (((vs_stat.date = (days.date)::date) AND (vs_stat.start = period.start) AND (vs_stat."end" = period."end") AND vs_stat.hospital_id = period.hospital_id)))
  WHERE CASE WHEN hospital_ids IS NULL THEN TRUE ELSE period.hospital_id = ANY(hospital_ids::uuid[]) END 
  GROUP BY ((days.date)::date), period.start, period."end"
  ORDER BY date, period.start;
  $$;
CREATE TABLE public.hint (
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    text character varying NOT NULL,
    name bpchar NOT NULL
);
CREATE FUNCTION public.unseen_hint(hasura_session json, name character) RETURNS SETOF public.hint
    LANGUAGE sql STABLE
    AS $$
    SELECT hint.* FROM hint; --left outer join seen_hint ON seen_hint.hint_id = hint.uid where hint.name = name AND seen_hint.user_id = (hasura_session ->> 'x-hasura-user-id')::uuid
$$;
CREATE TABLE public.blacklist (
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    volunteer_id uuid NOT NULL,
    comment text NOT NULL
);
CREATE TABLE public.hospital (
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    shortname character varying NOT NULL,
    phone character varying NOT NULL,
    address character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.hospital_coordinator (
    hospital_id uuid NOT NULL,
    coophone text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
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
CREATE TABLE public.volunteer (
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    fname character varying NOT NULL,
    mname character varying NOT NULL,
    lname character varying NOT NULL,
    phone character varying NOT NULL,
    email character varying NOT NULL,
    role character varying NOT NULL,
    password character varying DEFAULT ''::character varying NOT NULL,
    hospital_id uuid,
    comment character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE VIEW public.me AS
 SELECT volunteer.uid,
    volunteer.fname,
    volunteer.mname,
    volunteer.lname,
    volunteer.phone,
    volunteer.email,
    volunteer.role,
    volunteer.password,
    volunteer.hospital_id,
    volunteer.comment,
    volunteer.created_at,
    volunteer.updated_at
   FROM public.volunteer;
CREATE TABLE public.period (
    start time with time zone NOT NULL,
    "end" time with time zone NOT NULL,
    hospital_id uuid NOT NULL,
    demand integer NOT NULL,
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
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
    confirmed boolean DEFAULT false NOT NULL,
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    hospital_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
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
CREATE TABLE public.special_shift (
    start time with time zone NOT NULL,
    "end" time with time zone NOT NULL,
    date date NOT NULL,
    hospital_id uuid NOT NULL,
    demand integer NOT NULL,
    uid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE ONLY public.blacklist
    ADD CONSTRAINT blacklist_pkey PRIMARY KEY (uid);
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
ALTER TABLE ONLY public.vshift
    ADD CONSTRAINT vshift_pkey PRIMARY KEY (uid);
CREATE TRIGGER drop_shift_for_newly_blacklisted AFTER INSERT ON public.blacklist FOR EACH STATEMENT EXECUTE FUNCTION public.drop_shifts_for();
CREATE TRIGGER set_public_blacklist_updated_at BEFORE UPDATE ON public.blacklist FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_blacklist_updated_at ON public.blacklist IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_hospital_coordinator_updated_at BEFORE UPDATE ON public.hospital_coordinator FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_hospital_coordinator_updated_at ON public.hospital_coordinator IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_hospital_updated_at BEFORE UPDATE ON public.hospital FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_hospital_updated_at ON public.hospital IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_period_updated_at BEFORE UPDATE ON public.period FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_period_updated_at ON public.period IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_special_shift_updated_at BEFORE UPDATE ON public.special_shift FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_special_shift_updated_at ON public.special_shift IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_volunteer_shift_updated_at BEFORE UPDATE ON public.volunteer_shift FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_volunteer_shift_updated_at ON public.volunteer_shift IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_volunteer_updated_at BEFORE UPDATE ON public.volunteer FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_volunteer_updated_at ON public.volunteer IS 'trigger to set value of column "updated_at" to current timestamp on row update';
ALTER TABLE ONLY public.blacklist
    ADD CONSTRAINT blacklist_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.volunteer(uid) ON UPDATE RESTRICT ON DELETE RESTRICT;
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
