create table "public"."achievements" (
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "title" text not null,
    "points" bigint not null,
    "pending_complete" boolean,
    "complete" boolean,
    "profile_id" uuid default gen_random_uuid(),
    "id" uuid not null default gen_random_uuid()
);


alter table "public"."achievements" enable row level security;

alter table "public"."bounties" alter column "deleted_at" set data type timestamp with time zone using "deleted_at"::timestamp with time zone;

alter table "public"."bounties" alter column "updated_at" drop default;

alter table "public"."bounties" alter column "updated_at" set data type timestamp with time zone using "updated_at"::timestamp with time zone;

alter table "public"."bounties_join_table" add column "delete_at" timestamp with time zone;

alter table "public"."bounties_join_table" add column "updated_at" timestamp with time zone;

alter table "public"."data_points" drop column "entry_data";

alter table "public"."data_points" add column "entry_date" timestamp with time zone not null;

alter table "public"."data_points" alter column "deleted_at" set data type timestamp with time zone using "deleted_at"::timestamp with time zone;

alter table "public"."data_points" alter column "updated_at" drop default;

alter table "public"."data_points" alter column "updated_at" set data type timestamp with time zone using "updated_at"::timestamp with time zone;

alter table "public"."user_profile" alter column "deleted_at" set data type timestamp with time zone using "deleted_at"::timestamp with time zone;

alter table "public"."user_profile" alter column "updated_at" drop default;

alter table "public"."user_profile" alter column "updated_at" set data type timestamp with time zone using "updated_at"::timestamp with time zone;

CREATE UNIQUE INDEX achievements_pkey ON public.achievements USING btree (id);

alter table "public"."achievements" add constraint "achievements_pkey" PRIMARY KEY using index "achievements_pkey";

alter table "public"."achievements" add constraint "achievements_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES user_profile(id) not valid;

alter table "public"."achievements" validate constraint "achievements_profile_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_profile(auth_id uuid)
 RETURNS SETOF record
 LANGUAGE sql
AS $function$
  SELECT a.*,
    JSONB_AGG(DISTINCT to_jsonb(b)) AS children,
    JSONB_AGG(DISTINCT to_jsonb(c)) AS managed_bounties,
    JSONB_AGG(DISTINCT to_jsonb(e)) AS bounties,
    JSONB_AGG(DISTINCT to_jsonb(f)) AS achievements
FROM user_profile a
  JOIN(SELECT pd.*,
    JSONB_AGG(DISTINCT to_jsonb(cd)) as data_points,
    JSONB_AGG(DISTINCT to_jsonb(ce)) as bounties,
    JSONB_AGG(DISTINCT to_jsonb(cf)) as achievements
    FROM user_profile pd
      JOIN data_points cd ON cd.child_id = pd.id
      LEFT OUTER JOIN bounties_join_table cb ON cb.user_id = pd.id
      LEFT OUTER JOIN bounties ce ON ce.id = cb.bounty_id
      LEFT OUTER JOIN achievements cf ON cf.profile_id = pd.id
    GROUP BY pd.id
  ) AS b
  ON b.parent_id = a.auth_id
  LEFT OUTER JOIN bounties c ON c.parent_id = a.id
  LEFT OUTER JOIN bounties_join_table d ON d.user_id = a.id
  LEFT OUTER JOIN bounties e ON e.id = d.bounty_id
  LEFT OUTER JOIN achievements f ON f.profile_id = a.id 
WHERE a.auth_id = get_profile.auth_id
GROUP BY a.id;
$function$
;

grant delete on table "public"."achievements" to "anon";

grant insert on table "public"."achievements" to "anon";

grant references on table "public"."achievements" to "anon";

grant select on table "public"."achievements" to "anon";

grant trigger on table "public"."achievements" to "anon";

grant truncate on table "public"."achievements" to "anon";

grant update on table "public"."achievements" to "anon";

grant delete on table "public"."achievements" to "authenticated";

grant insert on table "public"."achievements" to "authenticated";

grant references on table "public"."achievements" to "authenticated";

grant select on table "public"."achievements" to "authenticated";

grant trigger on table "public"."achievements" to "authenticated";

grant truncate on table "public"."achievements" to "authenticated";

grant update on table "public"."achievements" to "authenticated";

grant delete on table "public"."achievements" to "service_role";

grant insert on table "public"."achievements" to "service_role";

grant references on table "public"."achievements" to "service_role";

grant select on table "public"."achievements" to "service_role";

grant trigger on table "public"."achievements" to "service_role";

grant truncate on table "public"."achievements" to "service_role";

grant update on table "public"."achievements" to "service_role";

create policy "Achievements are viewable by everyone"
on "public"."achievements"
as permissive
for select
to authenticated, anon
using (true);



