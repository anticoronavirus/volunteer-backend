
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."requirement"("created_at" timestamptz NOT NULL DEFAULT now(), "uid" uuid NOT NULL DEFAULT gen_random_uuid(), "updated_at" timestamptz NOT NULL DEFAULT now(), "name" varchar NOT NULL, "description" varchar NOT NULL, PRIMARY KEY ("uid") , UNIQUE ("name"), UNIQUE ("uid"));
CREATE OR REPLACE FUNCTION "public"."set_current_timestamp_updated_at"()
RETURNS TRIGGER AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER "set_public_requirement_updated_at"
BEFORE UPDATE ON "public"."requirement"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_public_requirement_updated_at" ON "public"."requirement" 
IS 'trigger to set value of column "updated_at" to current timestamp on row update';