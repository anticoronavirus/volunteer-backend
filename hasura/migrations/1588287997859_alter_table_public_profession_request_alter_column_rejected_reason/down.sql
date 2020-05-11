
ALTER TABLE "public"."profession_request" ALTER COLUMN "rejected_reason" TYPE character varying;
ALTER TABLE "public"."profession_request" ALTER COLUMN "rejected_reason" DROP NOT NULL;