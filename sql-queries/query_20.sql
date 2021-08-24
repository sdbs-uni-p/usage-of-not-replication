-- see all 51 instances
--value field: all of them with just one type
--uncle fields: only 5 have a type co-occurring with not
--value: string 10 cases, all with enum, object in 41 cases
Select *
FROM edftree e 
WHERE e.path like '%.not.$eref.type';
      -- and not e.path like '%.not.items.not.$eref.type'

--group the instances - only 5 of them have ``type'' among the uncles
Select e.p2key, p2s.sibkeys as uncles, e.pkey, e.key, s.value, jsonb_agg(s.sibkeys), count(*)
FROM eflattree e join etreewithsiblings s on (e.dewey = s.dewey)
     join etreewithsiblings p2s on (e.p2dewey = p2s.dewey)
WHERE s.path like '%.not.$eref.type'
   --and not s.path like '%.not.items.not.$eref.type'
--and s.sibnum = 1
GROUP BY e.p2key, e.pkey, e.key, s.value, p2s.sibkeys
ORDER BY s.value, count desc;