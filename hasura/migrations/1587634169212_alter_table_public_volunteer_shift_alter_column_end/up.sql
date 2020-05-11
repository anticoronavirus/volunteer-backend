
ALTER TABLE "public"."volunteer_shift" ALTER COLUMN "end" TYPE timetz;
ALTER TABLE "public"."volunteer_shift" ALTER COLUMN "end" DROP NOT NULL;