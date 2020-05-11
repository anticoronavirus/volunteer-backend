
ALTER TABLE "public"."profession_request" ALTER COLUMN "rejected" TYPE bool;
ALTER TABLE "public"."profession_request" ALTER COLUMN "rejected" DROP NOT NULL;