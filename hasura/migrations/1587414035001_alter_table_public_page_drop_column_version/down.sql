
ALTER TABLE "public"."page" ADD COLUMN "version" int4;
ALTER TABLE "public"."page" ALTER COLUMN "version" DROP NOT NULL;
ALTER TABLE "public"."page" ADD CONSTRAINT page_version_key UNIQUE (version);
ALTER TABLE "public"."page" ALTER COLUMN "version" SET DEFAULT 1;