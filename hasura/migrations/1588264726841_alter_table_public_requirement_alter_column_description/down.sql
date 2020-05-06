
ALTER TABLE "public"."requirement" ALTER COLUMN "description" TYPE character varying;
ALTER TABLE "public"."requirement" ALTER COLUMN "description" DROP NOT NULL;