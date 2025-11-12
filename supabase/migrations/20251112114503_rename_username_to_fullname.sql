alter table "public"."profiles" drop constraint "profiles_username_key";

drop index if exists "public"."profiles_username_key";

alter table "public"."profiles" drop column "username";

alter table "public"."profiles" add column "full_name" text;


