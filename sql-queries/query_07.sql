--for ER paper
--listing ``user defined keyword''
-- total keys that are not keywords are 120,113 out of 1,487,366
-- the most common are:
-- value 6939 247
-- name 5328 983
-- rule 5085 342

select d.key, 
count(*) as count, count(distinct line) as files
from dftree d left outer join keywords k on (d.key = k.keyword)
where (ktype is null or ktype = 'ns') and --comment here
key not in ('format','readonly','example','schema') and --comment here
key not in ( '$','/')
and key not similar to '\_%'
and key not similar to '[0-9]%'
group by cube(d.key)
order by count desc;