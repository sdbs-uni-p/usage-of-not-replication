-- computing the table
with temp as --temp: one line for each not.anyOf
(select --p2dewey, p3key, p2key, array_agg(pkey) pkeys, 
        array_agg(distinct key) keys,
        count(distinct pdewey) as pcount,
        count(distinct dewey) as numarg,
        count(distinct line) as lines,
        array_agg(distinct line) as linelist
from flattree --eflattree
where p3key = 'not' and p2key = 'anyOf' --and added = false
group by p2dewey) --, p3key, p2key)
select keys, '&', count(*), '&', sum(pcount), '&', --sum(numarg), '&', 
      sum(lines), '\\', array_agg(distinct linelist)
from temp
group by rollup(keys)
order by count desc;