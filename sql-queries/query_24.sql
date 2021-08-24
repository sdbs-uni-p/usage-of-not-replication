--This query shows that, out of 50 occurrences of not.any, each of them is either
--followed by ref or by properties or by required
select line, a.anum, array_agg(distinct k.key), count(*)
from dfn2,
     jsonb_path_query(sch,'strict $.**.not.anyOf')
	 with ordinality as a (a,anum),
	 jsonb_array_elements(a.a)
	 with ordinality as e (elem, enum),
	 jsonb_object_keys(e.elem) 
	 with ordinality as  k (key, keynum)
group by line, anum;