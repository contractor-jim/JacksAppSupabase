alter table "public"."user_profile" drop constraint "user_profile_auth_id_fkey";

alter table "public"."user_profile" drop constraint "user_profile_parent_id_fkey";

alter table "public"."user_profile" drop column "auth_id";

alter table "public"."user_profile" drop column "parent_id";

alter table "public"."user_profile" add column "authId" uuid not null;

alter table "public"."user_profile" add column "parentId" uuid;

alter table "public"."user_profile" alter column "id" set default gen_random_uuid();

alter table "public"."user_profile" add constraint "user_profile_auth_id_fkey" FOREIGN KEY ("authId") REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."user_profile" validate constraint "user_profile_auth_id_fkey";

alter table "public"."user_profile" add constraint "user_profile_parent_id_fkey" FOREIGN KEY ("parentId") REFERENCES user_profile(id) ON UPDATE CASCADE not valid;

alter table "public"."user_profile" validate constraint "user_profile_parent_id_fkey";

create policy "Users can create a profile."
on "public"."user_profile"
as permissive
for insert
to authenticated
with check ((( SELECT auth.uid() AS uid) = "authId"));


create policy "Users can view their own profile."
on "public"."user_profile"
as permissive
for select
to public
using ((( SELECT auth.uid() AS uid) = "authId"));



