--counting oneOf with a not arguments, number of not arguments, number of total
--arguments
(select count(distinct p2dewey) as countOneOf, count(distinct pdewey) as countArg
from oneOfArgs a join flattree using (p2dewey))
union
(select count(distinct p2dewey) as countOneOf, count(distinct pdewey) as countArg
from oneOfArgs a join flattree f using (p2dewey)
where f.key='not');



--for each oneOf with a not argument, visualize all keys of all group argumentns
drop table if exists oneOfArgs;
create table oneOfArgs as(
with temp as(
select t.line, t.p2dewey, t.pdewey, 
	count(*) as ckeys, jsonb_agg(t.key order by t.key) as keys -- t.key, t.value -- jsonb_agg(kk order by kk) as group-- t.dewey, 
from flattree t -- ,jsonb_object_keys(t.value) as kk
where 
  exists (select *
		  from  flattree c
		  where c.p2dewey = t.p2dewey and
		        c.key = 'not' and    -- for speedup 
                c.path like '%.oneOf[_].not')
group by t.line, t.p2dewey, t.pdewey)
select p2dewey, count(*) as cargs, jsonb_agg(ckeys order by ckeys) as ckkeys,
     jsonb_agg(keys order by keys) as kkeys
from temp
group by p2dewey );

--synthesize the table above and add information about arguments of not
with temp as
(select o.p2dewey, cargs, ckkeys, jsonb_agg(t.key order by t.key) as notargs, kkeys, t.pkey, jsonb_agg(t.key)
from oneofargs o join flattree t on (o.p2dewey = parDewey(t.p2dewey))
where t.pkey = 'not'
group by o.p2dewey, cargs, ckkeys, kkeys, t.pkey)
select count(*), jsonb_agg(p2dewey), notargs, cargs, ckkeys, kkeys
from temp
group by cargs, ckkeys, kkeys, notargs
order by count desc;


-- for each oneOf, analise all of its elements
select tnot.p2dewey, jsonb_agg(tc.sibkeys)
from treewithsiblings tnot join treewithsiblings tc on (tnot.p2dewey=tc.p2dewey)
where tnot.key = 'not' and    -- for speedup 
      tnot.path like '%.oneOf[_].not'
group by tnot.p2dewey;

-- analysing the structure of the argument of xone
select f1.p2dewey, f1.line, count(*) argsOfOneOf,
       f1.value as argOfNot,
	   forcelen(f1.value) as argOfNotLen,
       jsonb_agg(distinct f2.key) distinctArgsOfOneOf,
       jsonb_agg(f2.key order by f2.key) argsOfOneOf
from flattree f1 join flattree f2 on (f1.p2dewey=f2.p2dewey)
where f1.p2key='oneOf' and f1.key ='not'
group by f1.p2dewey, f1.line, f1.value
order by jsonb_agg(distinct f2.key);

--deeper analysis of the 126 cases: how many oneOf args, how many of then have a not
--which are the siblings of each notArgs (is it simple or complex?)
select p.pkey, t.line, p.pdewey,  
      count(*) as countNotArgs, 
	  p.sibnum as countTotalArgs,
	  jsonb_agg(t.sibkeys) as notsiblingkeys, jsonb_agg(t.sibnum) notsibnum, 
	  jsonb_agg(t.value) as notArgs
from treewithsiblings t join treewithsiblings p on (p.dewey=t.pdewey and p.line=t.line)
where p.pkey = 'oneOf' and t.key = 'not' and t.path similar to '%.oneOf\[_\].not'
group by p.pkey, t.line, p.pdewey, p.sibnum; --, t.pkey --, t.value, t.sibkeys, t.sibnum;



--categorizing xone on the set of xone arguments
with temp as(
select f1.p2dewey, f1.line, count(*) as "cArgsOfOneOf",
       f1.value as argOfNot,
	   forcelen(f1.value) as argOfNotLen,
       jsonb_agg(distinct f2.key) distinctArgsOfOneOf,
       jsonb_agg(f2.key order by f2.key) argsOfOneOf
from flattree f1 join flattree f2 on (f1.p2dewey=f2.p2dewey)
where f1.p2key='oneOf' and f1.key ='not'
group by f1.p2dewey, f1.line, f1.value)
select argsOfOneOf, count(*)
from temp
group by argsOfOneOf
order by count desc;

-- counting the total number of arguments of pure xall.not
with pureContexts as
(select distinct f1.p2dewey --, f1.line, count(*), jsonb_agg(distinct f2.key)
from flattree f1 join flattree f2 on (f1.p2dewey=f2.p2dewey)
where f1.p2key='allOf' and f1.key ='not'
group by f1.p2dewey, f1.line
having '["not"]' = jsonb_agg(distinct f2.key) 
)
select count(distinct f.p2dewey) as "allOfFollowedByNot", count(*) as "countAllOfNot"
from flattree f
where f.p2dewey in (select * from pureContexts);

-- looking at the shape of the values
with pureContexts as
(select distinct f1.p2dewey --, f1.line, count(*), jsonb_agg(distinct f2.key)
from eflattree f1 join eflattree f2 on (f1.p2dewey=f2.p2dewey)
where not f1.added and not f2.added and
   f1.p2key='allOf' and f1.key ='not'
group by f1.p2dewey, f1.line
having '["not"]' != jsonb_agg(distinct f2.key) 
--having '["not"]' = jsonb_agg(distinct f2.key) 
)
select f.p2dewey, f.key, f.value
from eflattree f
where f.p2dewey in (select * from pureContexts)
order by f.p2dewey, f.key, f.value;