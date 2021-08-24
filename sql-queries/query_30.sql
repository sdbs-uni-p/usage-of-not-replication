--to compute the three numbers above change the condition below
with temp as
(select jsonb_agg(e.key order by e.key) as keys, count(*) as c,
        jsonb_agg(e.value order by e.value) as values
from flattree e 
where e.pkey = 'not' --and e.pkey = '$eref'
group by pdewey)
select keys, c, jsonb_agg(values), count(*)
from temp
where c > 1   
      and    (keys::text  similar to '%properties%|%required%')  --comment not for objects
      --and   (keys::text   similar to '%Properties%')
      --and   (keys::text   not similar to '%roperties%|%required%')
 group by keys, c
order by count desc;
      
      
      
--look at the arguments of complex negated schemas
with temp as
(select jsonb_agg(e.key order by e.key) as keys, count(*) as c,
        jsonb_agg(e.value order by e.value) as values
from flattree e 
where e.pkey = 'not' --and e.pkey = '$eref'
group by pdewey)
select keys, c, jsonb_agg(values), count(*)
from temp
where c > 1   
      and    (keys::text  similar to '%properties%|%required%')  --comment not for objects
      --and   (keys::text   similar to '%Properties%')
      --and   (keys::text   not similar to '%roperties%|%required%')
 group by keys, c
order by count desc;



--negation of $eref-mediated schemas: the extreme variety of their structure
--in 55 casi siamo sotto not.items.not, solo in 37 casi è un vero not

with temp as
(select jsonb_agg(distinct e.line order by e.line) as lines, 
        jsonb_agg(e.key order by e.key) as keys, count(*) as numkeys
from eflattree e join eflattree gp on (e.p2dewey = gp.dewey)
where e.p2key = 'not' and e.pkey = '$eref'
      and not (gp.p2key = 'not' and gp.pkey = 'items')
group by e.pdewey)
select keys, numkeys, count(*), jsonb_agg(lines)
from temp
where numkeys >= 1  -- change to =1 or >1
     --and    (keys::text  similar to '%roperties%|%required%')  --comment not for objects
     --and   (keys::text   not similar to '%roperties%|%required%')
group by keys, numkeys
order by count desc;