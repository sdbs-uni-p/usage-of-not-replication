select
(select count(*) from treesibargs
	where key = 'not' and valuelennew > 1),
(	select count(*) from treesibargs
	where key = 'not' and valuelennew = 1),
(	select count(*) from treesibargs
	where key = 'not' and valuelennew = 0),
(	select count(*) from treesibargs
	where key = 'not' )
	from dual;
	
--count not.$ref
select key, count(distinct pdewey), count(*)
from edftree
where pkey = 'not' and key like ('$_ref')
group by cube(key);

--count complex negated references: 79 su 93
select count(*)
from (select jsonb_agg(e.key), count(*)
from eflattree e 
where e.p2key = 'not' and e.pkey = '$eref'
group by pdewey
having count(*) > 1) n;