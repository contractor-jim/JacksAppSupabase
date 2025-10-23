alter table "public"."user_profile" add column "auth_id" uuid not null;

alter table "public"."user_profile" add constraint "user_profile_auth_id_fkey" FOREIGN KEY (auth_id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."user_profile" validate constraint "user_profile_auth_id_fkey";


