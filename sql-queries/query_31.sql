--not.oneOf: 6 cases
select *
from eflattree
where path like '%.not.oneOf' and not added;