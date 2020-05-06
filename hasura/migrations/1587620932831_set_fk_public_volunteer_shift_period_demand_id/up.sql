
alter table "public"."volunteer_shift"
           add constraint "volunteer_shift_period_demand_id_fkey"
           foreign key ("period_demand_id")
           references "public"."period_demand"
           ("uid") on update cascade on delete cascade;