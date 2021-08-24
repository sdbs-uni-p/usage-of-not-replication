select coalesce(k.keyword,'Total'), '&',
       count(*) as c, '&',
	   case when keyword is not null then count(distinct d.line)
	   else (select count(*) from df2)
	   end, '&',
	   max(k.version), '\\'
from dftree d join keywords k on (d.key=k.keyword) 
where k.kclass in ('s', 'dollar')
group by rollup(k.keyword)
order by c desc;