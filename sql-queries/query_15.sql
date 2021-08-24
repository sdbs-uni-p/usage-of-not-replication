-- computing the table
select coalesce(issimple,'*'), '&', 
       coalesce(howmany,'*'), '&', 
        count(*), '&', 
		count(distinct t.line) as numfiles, '\\',
	    array_agg(distinct sibnum) as lengths,
		array_agg(distinct valuelen) as lenArgs,
		array_agg(distinct t.line) as lines, 
        jsonb_agg(distinct t.sibkeys) as keys,
        jsonb_agg(distinct t.value) as args
from etreewithsiblings t,
     ift (sibnum = 1, 'simple'::text, 'complex'::text) as issimple,
     ift (valuelen=1, 'onefield',
		   ift (valuelen=2, 'twofields','manyfields')) 
	     as howmany
where path like '%.not.$eref.required'
group by issimple, cube(howmany)
order by case when issimple is null and howmany is null 
               then 1
			   when howmany is null then 2
			   when issimple is null then 3
			   else 4 end,
      count desc;
      
--deleting spurious cases
select coalesce(issimple,'*'), '&', 
       coalesce(howmany,'*'), '&', 
        count(*), '&', 
		count(distinct t.line) as numfiles, '\\',
	    array_agg(distinct sibnum) as lengths,
		array_agg(distinct valuelen) as lenArgs,
		array_agg(distinct t.line) as lines, 
        jsonb_agg(distinct t.sibkeys) as keys,
        jsonb_agg(distinct t.value) as args
from etreewithsiblings t,
     ift (sibnum = 1, 'simple'::text, 'complex'::text) as issimple,
     ift (valuelen=1, 'onefield',
		   ift (valuelen=2, 'twofields','manyfields')) 
	     as howmany
where path like '%.not.$eref.required'
group by issimple, cube(howmany)
order by case when issimple is null and howmany is null 
               then 1
			   when howmany is null then 2
			   when issimple is null then 3
			   else 4 end,
      count desc;
      
--what comes with not.$eref.req
select sibkeys, count(*)
from etreewithsiblings
where path like '%.not.$eref.required'
group by sibkeys;

--in 35 cases out of 36 we have type object with required
select sibkeys, value, count(*)
from etreewithsiblings
where path like '%.not.$eref.type'
      and 'required' = any (sibkeys)
group by rollup(sibkeys), value;