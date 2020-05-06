
CREATE TABLE "public"."page"("uid" uuid NOT NULL, "name" varchar NOT NULL, "content" text NOT NULL, "version" integer NOT NULL DEFAULT 1, PRIMARY KEY ("uid") , UNIQUE ("uid"), UNIQUE ("version"));