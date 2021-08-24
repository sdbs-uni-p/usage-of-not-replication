-- analysing the structure of the argument of xall
select f1.p2dewey, f1.line, count(*) argsOfAllOf,
       jsonb_agg(distinct f2.key) distinctArgsOfAllOf,
       jsonb_agg(f2.key order by f2.key) argsOfAllOf
from flattree f1 join flattree f2 on (f1.p2dewey=f2.p2dewey)
where f1.p2key='allOf' and f1.key ='not'
group by f1.p2dewey, f1.line
order by jsonb_agg(distinct f2.key);

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