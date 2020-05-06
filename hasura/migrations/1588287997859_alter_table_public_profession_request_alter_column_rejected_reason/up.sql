
ALTER TABLE "public"."profession_request" ALTER COLUMN "rejected_reason" TYPE varchar;
ALTER TABLE "public"."profession_request" ALTER COLUMN "rejected_reason" DROP NOT NULL;