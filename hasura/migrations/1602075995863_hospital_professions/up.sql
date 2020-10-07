
CREATE TABLE "public"."hospital_profession"("hospital_id" uuid NOT NULL, "profession_id" uuid NOT NULL, PRIMARY KEY ("hospital_id","profession_id") , FOREIGN KEY ("hospital_id") REFERENCES "public"."hospital"("uid") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("profession_id") REFERENCES "public"."profession"("uid") ON UPDATE restrict ON DELETE restrict);

ALTER TABLE "public"."hospital_profession" ADD COLUMN "created_at" timestamptz NOT NULL DEFAULT now();
