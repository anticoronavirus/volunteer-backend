
DROP TRIGGER IF EXISTS "set_public_page_updated_at" ON "public"."page";
ALTER TABLE "public"."page" DROP COLUMN "updated_at";