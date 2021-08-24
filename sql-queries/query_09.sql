------ count occurences of not.K path
select k1.k, '&', k1.c, '&', k1.cd, '&', k2.k, '&', k2.c, '&', k2.cd, '\\'
from
(select coalesce(key,'*') as key, concat('not.',coalesce(key,'*')) as k, count(*) as c, count(distinct line) as cd
from eflattree d join keywords k on d.key = k.keyword
where pkey = 'not' and path not like '%$eref_%'
group by rollup(key)) as k1
full outer join
(select coalesce(key,'*') as key, concat('not.\$eref.',coalesce(key,'*')) as k, count(*) as c, count(distinct line) as cd
from eflattree d join keywords k on d.key = k.keyword
where p2key = 'not' and pkey = '$eref'
group by rollup(key)) as k2
on k1.key = k2.key
order by coalesce(k1.c,0)+ coalesce(k2.c,0)  desc;

--  not and not.$eref
select key, count(*), count(distinct line)
from edftree
where (key = 'not' and path not like '%.$eref_%')
      or (key = '$eref' and pkey = 'not')
group by key;

-- counting not:{} and not:''  ``
select parent.value, count(*), count(distinct parent.line)
from dftree parent
     left join dftree child on (parent.dewey=child.pdewey)
where parent.key='not'
      and child.key is null
group by parent.value;