
alter table "public"."volunteer_shift"
           add constraint "volunteer_shift_profession_id_fkey"
           foreign key ("profession_id")
           references "public"."profession"
           ("uid") on update restrict on delete restrict;