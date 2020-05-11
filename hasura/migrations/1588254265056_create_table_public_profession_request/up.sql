
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."profession_request"("uid" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "hospital_id" uuid NOT NULL, "volunteer_id" uuid NOT NULL, "profession_id" uuid NOT NULL, "rejected" boolean NOT NULL, "rejected_reason" varchar NOT NULL, PRIMARY KEY ("uid") , FOREIGN KEY ("volunteer_id") REFERENCES "public"."volunteer"("uid") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("profession_id") REFERENCES "public"."profession"("uid") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("hospital_id") REFERENCES "public"."hospital"("uid") ON UPDATE restrict ON DELETE restrict, UNIQUE ("uid"), UNIQUE ("profession_id", "hospital_id", "volunteer_id"));
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
CREATE TRIGGER "set_public_profession_request_updated_at"
BEFORE UPDATE ON "public"."profession_request"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_public_profession_request_updated_at" ON "public"."profession_request" 
IS 'trigger to set value of column "updated_at" to current timestamp on row update';