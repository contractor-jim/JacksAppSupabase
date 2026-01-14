alter table "public"."achievements" add column "rarity" text default 'bronze'::text;

alter table "public"."bounties" add column "pending_complete" boolean default false;

alter table "public"."bounties" add column "rarity" text default 'bronze'::text;


