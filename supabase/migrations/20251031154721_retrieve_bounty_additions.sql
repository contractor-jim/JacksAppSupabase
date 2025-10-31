alter table "public"."bounties" add column "parent_id" uuid not null;

alter table "public"."bounties" alter column "id" set default gen_random_uuid();

alter table "public"."bounties" add constraint "bounties_parent_id_fkey1" FOREIGN KEY (parent_id) REFERENCES user_profile(id) not valid;

alter table "public"."bounties" validate constraint "bounties_parent_id_fkey1";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_profile(auth_id uuid)
 RETURNS SETOF record
 LANGUAGE sql
AS $function$
  SELECT a.*,
      jsonb_agg(DISTINCT to_jsonb(b)) AS children,
      jsonb_agg(DISTINCT to_jsonb(c)) AS managed_bounties,
      jsonb_agg(DISTINCT to_jsonb(e)) AS bounties
  FROM user_profile a
    JOIN user_profile b ON b.parent_id = a.auth_id
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



