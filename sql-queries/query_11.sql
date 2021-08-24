-- 787 + (127-55= 72) = 859 - 17 = 842 - should be 840
-- distribution of valuelen
select (valuelen), count(*)
from treewithsiblings
where key = 'not' and valuelen > 1
group by valuelen;

select sum (valuelen), count(*)
from treewithsiblings
where key = 'not' and valuelen > 1;

--result:
-- 0	16
-- 1	716
-- 2	41
-- 3	11
-- 4	3

--mostsubschemas are complex
select(
	select count(*) from treewithsiblings
	where sibnum > 1)*100/
	(
	select count(*) from treewithsiblings)
	from dual;