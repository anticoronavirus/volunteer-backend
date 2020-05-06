
ALTER TABLE "public"."volunteer_shift" ALTER COLUMN "start" TYPE time with time zone;
ALTER TABLE "public"."volunteer_shift" ALTER COLUMN "start" SET NOT NULL;