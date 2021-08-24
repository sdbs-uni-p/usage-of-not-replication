select line, path, sibnum, sibkeys, valuelen, value
from treewithsiblings
where key = 'not' and path similar to '%.dependencies.[^.]*.not';