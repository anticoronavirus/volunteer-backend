
alter table "public"."volunteer_shift" drop constraint "volunteer_shift_period_demand_id_fkey",
             add constraint "volunteer_shift_period_demand_id_fkey"
             foreign key ("period_demand_id")
             references "public"."period_demand"
             ("uid") on update restrict on delete set null;