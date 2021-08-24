--notanyOf how many: 45
select count(*)
from dftree
where path like '%.not.anyOf';

-----the following query visualized all not.boolOp collecting the set of keywords below
select  op.o, a.line, a.num as argnum, a.arg, 
      count(*) as children, 
	  count(distinct (op.o, a.line, a.num)) as notArgsNum,
	  count(distinct a.line) as lines, 
      array_agg(distinct k.keyword),
	  array_agg(distinct arg.opArg)
from notargs a , keywords k, 
     ( values ('anyOf'),('oneOf'),('allOf')) op (o),
	 jsonb_path_query(a.arg, concat('$.', op.o, '[*].',k.keyword)::jsonpath)
	 with ordinality as arg (opArg,num)
where a.arg @? concat('$.',  op.o, '[*].',k.keyword)::jsonpath 
and k.kclass not in ('array', 'path')
and o = 'anyOf'                                    --------modify this
and k.keyword = 'required'
group by op.o, a.line, a.num, a.arg      ----modify this
having 'required' =any (array_agg(distinct k.keyword))    --------modify this
order by count(*) desc,  op.o, array_agg(distinct k.keyword);