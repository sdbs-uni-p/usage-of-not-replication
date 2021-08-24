--instances and files
select key, count(*), count(distinct line), min(line)
from dftree
where path like '%.not.items.not'
      or path like '%.not.items.enum'
group by rollup(key);

--siblings and children of not.items: no siblings, children either enum or not
SELECT e.p2key, e.pkey, s.sibkeys, json_agg(e.key)
FROM eflattree e
join etreewithsiblings s on (e.pdewey = s.dewey)
--JOIN dfn2 d using (line)
where  not e.added
      and e.p2key = 'not' and e.pkey = 'items'
-- path like '%.not.items.not' 
--and d.description not like '%Section%'
--and d.description not like '%G-Cloud%'
group by e.p2key, e.line, e.pkey, e.pdewey, s.sibkeys
order by e.line;  --, d.description


--following $eref
select value
from edftree
where path like '%.not.items.not.$eref';