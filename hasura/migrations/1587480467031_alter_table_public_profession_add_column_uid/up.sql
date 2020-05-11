
CREATE EXTENSION IF NOT EXISTS pgcrypto;
ALTER TABLE "public"."profession" ADD COLUMN "uid" uuid NOT NULL UNIQUE DEFAULT gen_random_uuid();