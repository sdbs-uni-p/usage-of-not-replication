--verify the shape of allOf
select line, p3key, p2key, jsonb_agg(key), jsonb_agg(value)
from flattree
where p3key = 'not' and p2key = 'allOf' and key = 'required'
group by line, p3key, p2key, p2dewey;