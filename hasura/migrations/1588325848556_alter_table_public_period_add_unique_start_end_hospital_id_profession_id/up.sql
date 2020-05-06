
alter table "public"."period" add constraint "period_start_end_hospital_id_profession_id_key" unique ("start", "end", "hospital_id", "profession_id");