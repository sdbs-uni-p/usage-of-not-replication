-- counting the different contexts
select concat(k.keyword,'.*'), d.p2key as key, count(*)
from flattree d, keywords k
where d.path like concat('%.not')
     and (d.p2key = k.keyword and d.p2key != 'not')
group by d.p2key, k.keyword --, d.dewey
union
select k.keyword, d.pkey as key, count(*)
from flattree d, keywords k
where d.path like concat('%.not')
     and (d.pkey = k.keyword)
group by d.pkey, k.keyword --, d.dewey
union
select d.path, d.pkey as key, count(*)
from dftree d
where d.path like concat('%.not')
     and level <= 1
group by d.path, d.pkey
order by count desc;