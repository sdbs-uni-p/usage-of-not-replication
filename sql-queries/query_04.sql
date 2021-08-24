--percentage of \$eref / \$ref
select(select count(*)
       from edftree
       where key = '$eref')*100/
	   (select count(*)
       from dftree
       where key = '$ref')
from dual;

--expansion of set of schemas
select(select count(*)
       from edftree
       )*100/
	   (select count(*)
       from dftree)
from dual;
