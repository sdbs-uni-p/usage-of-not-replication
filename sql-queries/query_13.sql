select sibkeys, count(*)
from treewithsiblings
where path like '%.not.required'
and sibnum > 1
group by sibkeys
order by count desc;