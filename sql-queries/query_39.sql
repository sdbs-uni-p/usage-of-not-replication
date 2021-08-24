--computing the table
select concat(k.keyword,'.*.\xnot') as keyword, '&', count(*) as occ, '&', 
       count(distinct d.p2dewey) as contexts, '&', count(distinct line) as files, '\\', d.p2key as key
from flattree d, keywords k
where d.path like concat('%.not')
     and (d.p2key = k.keyword and d.p2key != 'not')
group by d.p2key, k.keyword --, d.dewey
union
select concat(k.keyword,'.\xnot') as keyword, '&', count(*) as occ, '&', 
       count(distinct d.pdewey) as contexts, '&', count(distinct line) as files, '\\', d.pkey as key
from flattree d, keywords k
where d.path like concat('%.not')
     and (d.pkey = k.keyword and k.kclass = 's')
group by d.pkey, k.keyword --, d.dewey
union
select '\$.\xnot' as keyword, '&', count(*) as occ, '&', 
       count(distinct d.pdewey) as contexts, '&', count(distinct line) as files, '\\', d.path
from dftree d
where d.path like concat('%.not')
     and level <= 1
group by d.path, d.pkey
order by occ desc;

--computing the percentages as well
with n as
(select concat(k.keyword,'.*.\xnot') as keyword, count(*) as occ, 
       count(distinct d.p2dewey) as contexts,  count(distinct line) as files
from flattree d, keywords k
where  (d.p2key = k.keyword and d.p2key != 'not')
group by d.p2key, k.keyword --, d.dewey
union
select concat(k.keyword,'.\xnot') as keyword, count(*) as occ, 
       count(distinct d.pdewey) as contexts, count(distinct line) as files
from flattree d, keywords k
where (d.pkey = k.keyword and k.kclass = 's')
group by d.pkey, k.keyword --, d.dewey
union
select '\$.\xnot' as keyword, count(*) as occ, 
       count(distinct d.pdewey) as contexts, count(distinct line) as files
from dftree d
where level = 1
group by d.pkey),
m as (
select concat(k.keyword,'.*.\xnot') as keyword, count(*) as occ, 
       count(distinct d.p2dewey) as contexts, count(distinct line) as files
from flattree d, keywords k
where d.path like concat('%.not')
     and (d.p2key = k.keyword and d.p2key != 'not')
group by d.p2key, k.keyword --, d.dewey
union
select concat(k.keyword,'.\xnot') as keyword, count(*) as occ, 
       count(distinct d.pdewey) as contexts, count(distinct line) as files
from flattree d, keywords k
where d.path like concat('%.not')
     and (d.pkey = k.keyword and k.kclass = 's')
group by d.pkey, k.keyword --, d.dewey
union
select '\$.\xnot' as keyword, count(*) as occ,
       count(distinct d.pdewey) as contexts,  count(distinct line) as files
from dftree d
where d.path like concat('%.not')
     and level = 1
group by d.pkey
)
select keyword, '&', m.occ, '&', m.occ*10,000/n.occ, '&', m.contexts, 
           '&', m.contexts*10000/n.contexts, 
           '&', m.files, '&', m.files*10000/n.files, '\\' 
from m  join n using (keyword)
order by m.occ desc;

--computing the line of the totals
with temp as(
select d.dewey, d.p2dewey as context, d.line --concat(k.keyword,'.*'), '&', count(*) as c, '&', count(distinct line), '\\', d.p2key as key
from flattree d, keywords k
where d.path like concat('%.not')
     and (d.p2key = k.keyword and d.p2key != 'not')
	 and k.kclass = 's'
--group by d.p2key, k.keyword --, d.dewey
union all
select d.dewey, d.pdewey as context, d.line --k.keyword, '&', count(*) as c, '&', count(distinct line), '\\', d.pkey as key
from flattree d, keywords k
where d.path like concat('%.not')
       and (d.pkey = k.keyword and k.kclass = 's')
--group by d.pkey, k.keyword --, d.dewey
union all
select d.dewey, d.pdewey as context, d.line --'root', '&', count(*) as c, '&', count(distinct line), '\\', d.path
from dftree d
where d.path like concat('%.not')
     and level <= 1
--group by d.path, d.pkey
	)
select count(*), count(distinct context), count(distinct line)
	from temp;
	
--computing the line of the totals: 2381958	316952	11508
with temp as(
select d.dewey, d.p2dewey as context, d.line --concat(k.keyword,'.*'), '&', count(*) as c, '&', count(distinct line), '\\', d.p2key as key
from flattree d, keywords k
where (d.p2key = k.keyword and d.p2key != 'not')
	 and k.kclass = 's'
--group by d.p2key, k.keyword --, d.dewey
union all
select d.dewey, d.pdewey as context, d.line --k.keyword, '&', count(*) as c, '&', count(distinct line), '\\', d.pkey as key
from flattree d, keywords k
where (d.pkey = k.keyword and k.kclass = 's')
--group by d.pkey, k.keyword --, d.dewey
union all
select d.dewey, d.pdewey as context, d.line --'root', '&', count(*) as c, '&', count(distinct line), '\\', d.path
from dftree d
where level = 1
--group by d.path, d.pkey
	)
select count(*), count(distinct context), count(distinct line)
	from temp