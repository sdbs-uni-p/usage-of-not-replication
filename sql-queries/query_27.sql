--going through $eref (5 cases with 13 references)
with temp as --temp: one line for each not.anyOf
(select --p2dewey, p3key, p2key, array_agg(pkey) pkeys, 
        --array_agg(distinct key) keys,
        --count(distinct pdewey) as pcount,
        --count(distinct dewey) as numarg,
        count(distinct line) as lines,
        jsonb_agg(value) as values,
        array_agg(distinct line) as linelist
from eflattree
where p3key = 'not' and p2key = 'anyOf' 
      and key = '$eref'
group by p2dewey) --, p3key, p2key)
select --keys, '&', count(*), '&', sum(pcount), '&', --sum(numarg), '&', 
      count(*),
	  forcelen(values),
	  (values),
	  sum(lines), '\\', array_agg(distinct linelist)
from temp
group by values
order by count desc;