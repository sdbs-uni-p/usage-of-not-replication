--keywords that occur with properties under negation
select line, pdewey, e1.value, jsonb_agg(e2.key), jsonb_agg(e2.value)
from edftree e1 join edftree e2 using (line,pdewey,added,pkey)
where pkey = 'not' and e1.key = 'properties'
       and e2.dewey != e1.dewey
	   --and e2.key = 'required' 
	   and not added
group by line, pdewey, e1.value --, e2.value
order by jsonb_agg(e2.key);