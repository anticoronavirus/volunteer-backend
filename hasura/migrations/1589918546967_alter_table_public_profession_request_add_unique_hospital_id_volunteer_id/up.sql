alter table "public"."profession_request" drop constraint "profession_request_profession_id_hospital_id_volunteer_id_key";
alter table "public"."profession_request" add constraint "profession_request_hospital_id_volunteer_id_key" unique ("hospital_id", "volunteer_id");
