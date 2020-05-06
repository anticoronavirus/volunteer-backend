
alter table "public"."profession" drop constraint "profession_pkey";
alter table "public"."profession"
    add constraint "profession_pkey" 
    primary key ( "name" );