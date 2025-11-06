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
WHERE a.auth_id = '7d04db7c-b9c3-4184-af50-5034cb65018b'
GROUP BY a.id

CREATE or REPLACE function get_profile(auth_id uuid)
returns setof record
language sql
as $$
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
$$;
