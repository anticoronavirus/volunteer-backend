
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE "public"."hospital_profession_requirement"("uid" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "requirement_id" uuid NOT NULL, "profession_id" uuid NOT NULL, "hospital_id" uuid NOT NULL, PRIMARY KEY ("uid") , FOREIGN KEY ("requirement_id") REFERENCES "public"."requirement"("uid") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("profession_id") REFERENCES "public"."profession"("uid") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("hospital_id") REFERENCES "public"."hospital"("uid") ON UPDATE restrict ON DELETE restrict, UNIQUE ("uid"), UNIQUE ("requirement_id", "profession_id", "hospital_id"));