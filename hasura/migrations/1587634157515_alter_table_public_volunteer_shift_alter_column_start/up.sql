
ALTER TABLE "public"."volunteer_shift" ALTER COLUMN "start" TYPE timetz;
ALTER TABLE "public"."volunteer_shift" ALTER COLUMN "start" DROP NOT NULL;