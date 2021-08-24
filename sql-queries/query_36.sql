select sibkeys, value, *
from treewithsiblings
where path like '%.not.additionalProperties'
order by sibnum;