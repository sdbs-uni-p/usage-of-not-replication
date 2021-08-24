select key, count(*), count(distinct line), min(line), g.rgroup
from dftree join filetog g using (line)
where path like '%.not.items.not'
      or path like '%.not.items.enum'
group by rollup(key,g.rgroup);