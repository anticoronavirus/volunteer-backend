
alter table "public"."period"
           add constraint "period_profession_fkey"
           foreign key ("profession")
           references "public"."profession"
           ("uid") on update restrict on delete restrict;