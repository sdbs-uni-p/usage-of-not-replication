--counting
select count(*) countNegations, count(distinct p2dewey) countDefGroups, count(distinct line)
from flattree
where key = 'not' and p2key = 'definitions';


--visualizing -- this code miss one definition that has `.' inside the definition name
select line, sibnum, sibkeys, valuelen, value
from treewithsiblings
where key = 'not' and path similar to '%.definitions.[^.]*.not';