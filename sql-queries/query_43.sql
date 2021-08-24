--counting anyOf with a not arguments, number of not arguments, number of total
--arguments
(select count(distinct p2dewey) as countAnyOf, count(distinct pdewey) as countArg
from anyOfArgs a join flattree using (p2dewey))
union
(select count(distinct p2dewey) as countAnyOf, count(distinct pdewey) as countArg
from anyOfArgs a join flattree f using (p2dewey)
where f.key='not');

--for each anyOf with a not argument, visualize all keys of all group argumentns
drop table if exists anyOfArgs;
create table anyOfArgs as(
with temp as(
select t.line, t.p2dewey, t.pdewey, 
	count(*) as ckeys, jsonb_agg(t.key order by t.key) as keys -- t.key, t.value -- jsonb_agg(kk order by kk) as group-- t.dewey, 
from flattree t -- ,jsonb_object_keys(t.value) as kk
where 
  exists (select *
		  from  flattree c
		  where c.p2dewey = t.p2dewey and
		        c.key = 'not' and    -- for speedup 
                c.path like '%.anyOf[_].not')
group by t.line, t.p2dewey, t.pdewey)
select p2dewey, count(*) as cargs, jsonb_agg(ckeys order by ckeys) as ckkeys,
     jsonb_agg(keys order by keys) as kkeys
from temp
group by p2dewey );
select * from anyOfArgs;

--synthesize the table above and add information about arguments of not
with temp as
(select o.p2dewey, cargs, ckkeys, jsonb_agg(t.key order by t.key) as notargs, kkeys, t.pkey, jsonb_agg(t.key)
from anyofargs o join flattree t on (o.p2dewey = parDewey(t.p2dewey))
where t.pkey = 'not'
group by o.p2dewey, cargs, ckkeys, kkeys, t.pkey)
select count(*), jsonb_agg(p2dewey), notargs, cargs, ckkeys, kkeys
from temp
group by cargs, ckkeys, kkeys, notargs
order by count desc;

