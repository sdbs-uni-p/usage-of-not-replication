--this code excludes the not.items.not contexts
select k1.k, '&', k1.c, '&', k1.cd, '&', k2.k, '&', k2.c, '&', k2.cd, '\\'
from
(select coalesce(d.key,'*') as key, concat('not.',coalesce(d.key,'*')) as k, 
        count(*) as c, count(distinct d.line) as cd
from eflattree d join keywords k on d.key = k.keyword
where d.pkey = 'not' and d.path not like '%$eref_%'
      and not (d.p3key = 'not' and d.p2key = 'items')
group by rollup(d.key)) as k1
full outer join
(select coalesce(d.key,'*') as key, concat('not.\$eref.',coalesce(d.key,'*')) as k, 
         count(*) as c, count(distinct d.line) as cd
from eflattree d join keywords k on d.key = k.keyword
     left join flattree p on (d.p2dewey = p.dewey)
where d.p2key = 'not' and d.pkey = '$eref'
      and not (p.p2key is not null and p.p2key = 'not' and p.pkey = 'items')
group by rollup(d.key)) as k2
on k1.key = k2.key
order by coalesce(k1.c,0)+ coalesce(k2.c,0)  desc;