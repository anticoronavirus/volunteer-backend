
ALTER TABLE "public"."volunteer_shift" ALTER COLUMN "end" TYPE time with time zone;
ALTER TABLE "public"."volunteer_shift" ALTER COLUMN "end" SET NOT NULL;