drop policy "Users can view their own profile." on "public"."user_profile";

drop policy "Users can create a profile." on "public"."user_profile";

alter table "public"."user_profile" drop constraint "user_profile_auth_id_fkey";

alter table "public"."user_profile" drop constraint "user_profile_parent_id_fkey";

alter table "public"."bounties" add column "parent_id" uuid not null;

alter table "public"."bounties" alter column "id" set default gen_random_uuid();

alter table "public"."data_points" add column "entry_data" timestamp without time zone;

alter table "public"."data_points" alter column "id" set default gen_random_uuid();

alter table "public"."user_profile" drop column "authId";

alter table "public"."user_profile" drop column "parentId";

alter table "public"."user_profile" drop column "userName";

alter table "public"."user_profile" add column "auth_id" uuid not null;

alter table "public"."user_profile" add column "parent_id" uuid;

alter table "public"."user_profile" add column "user_name" text;

alter table "public"."bounties" add constraint "bounties_parent_id_fkey1" FOREIGN KEY (parent_id) REFERENCES user_profile(id) not valid;

alter table "public"."bounties" validate constraint "bounties_parent_id_fkey1";

alter table "public"."user_profile" add constraint "user_profile_parent_id_fkey" FOREIGN KEY (parent_id) REFERENCES auth.users(id) not valid;

alter table "public"."user_profile" validate constraint "user_profile_parent_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_children(profile_id uuid)
 RETURNS SETOF record
 LANGUAGE sql
AS $function$
  SELECT a.*,
    JSON_AGG(DISTINCT b) AS children
  FROM user_profile a

    JOIN(SELECT pd.*,
      JSON_AGG(cd) as data_points
      FROM user_profile pd
        JOIN data_points cd ON cd.child_id = pd.id
      GROUP BY pd.id
    ) AS b
    ON b.parent_id = a.auth_id
  WHERE a.auth_id = get_children.profile_id
  GROUP BY a.id
$function$
;

CREATE OR REPLACE FUNCTION public.get_profile(auth_id uuid)
 RETURNS SETOF record
 LANGUAGE sql
AS $function$
  SELECT a.*,
    JSONB_AGG(DISTINCT to_jsonb(b)) AS children,
    JSONB_AGG(DISTINCT to_jsonb(c)) AS managed_bounties,
    JSONB_AGG(DISTINCT to_jsonb(e)) AS bounties
  FROM user_profile a
  JOIN(SELECT pd.*,
    JSONB_AGG(to_jsonb(cd)) as data_points,
    JSONB_AGG(to_jsonb(ce)) as bounties
    FROM user_profile pd
      JOIN data_points cd ON cd.child_id = pd.id
      LEFT OUTER JOIN bounties_join_table cb ON cb.user_id = pd.id
      LEFT OUTER JOIN bounties ce ON ce.id = cb.bounty_id
    GROUP BY pd.id
  ) AS b
  ON b.parent_id = a.auth_id
  JOIN bounties c ON c.parent_id = a.id
  JOIN bounties_join_table d ON d.user_id = a.id
  JOIN bounties e ON e.id = d.bounty_id
WHERE a.auth_id = get_profile.auth_id
GROUP BY a.id;
$function$
;

create policy "Bounties are viewable by everyone"
on "public"."bounties"
as permissive
for select
to authenticated, anon
using (true);


create policy "Bounties are viewable by everyone"
on "public"."bounties_join_table"
as permissive
for select
to authenticated, anon
using (true);


create policy "Data points are viewable to everyone"
on "public"."data_points"
as permissive
for all
to anon, authenticated
using (true);


create policy "Parents can view child profiles"
on "public"."user_profile"
as permissive
for select
to public
using ((( SELECT auth.uid() AS uid) = parent_id));


create policy "Users can view there own profile"
on "public"."user_profile"
as permissive
for select
to public
using ((( SELECT auth.uid() AS uid) = auth_id));


create policy "Users can create a profile."
on "public"."user_profile"
as permissive
for insert
to authenticated
with check ((( SELECT auth.uid() AS uid) = auth_id));



