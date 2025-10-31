SELECT a.*,
      json_agg(DISTINCT b) AS children,
      json_agg(DISTINCT c) AS managed_bounties,
      json_agg(DISTINCT e) AS bounties
  FROM user_profile a
  JOIN user_profile b ON b.parent_id = a.auth_id
  JOIN bounties c ON c.parent_id = a.id
  JOIN bounties_join_table d ON d.user_id = a.id
  JOIN bounties e ON e.id = d.bounty_id
WHERE a.auth_id = '7d04db7c-b9c3-4184-af50-5034cb65018b'
GROUP BY a.id

CREATE or REPLACE function get_profile(auth_id uuid)
returns setof record
language sql
as $$
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
$$;