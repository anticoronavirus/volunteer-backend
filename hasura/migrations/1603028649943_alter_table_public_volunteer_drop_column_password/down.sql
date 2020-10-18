ALTER TABLE "public"."volunteer" ADD COLUMN "password" varchar;
ALTER TABLE "public"."volunteer" ALTER COLUMN "password" DROP NOT NULL;
ALTER TABLE "public"."volunteer" ALTER COLUMN "password" SET DEFAULT ''::character varying;
