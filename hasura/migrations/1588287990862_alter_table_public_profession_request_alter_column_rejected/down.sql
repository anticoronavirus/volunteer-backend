
ALTER TABLE "public"."profession_request" ALTER COLUMN "rejected" TYPE boolean;
ALTER TABLE "public"."profession_request" ALTER COLUMN "rejected" DROP NOT NULL;