--35 uses
--negation is always not allof required / not anyof required / not required
select *
from flattree d 
where p2key = 'not'
and level = 3
order by pkey;