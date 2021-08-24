--creating the table for enum and for const
-- uncommenting --and value->>'type'='string' proves that type string is always present
-- this is just copied from the required case, no modification
select *
from dftree
where path like '%.not.enum';
      
---table for enum
select coalesce(issimple,'*'), '&', 
       coalesce(howmany,'*'), '&', 
        count(*), '&', 
		count(distinct t.line) as numfiles, '\\',
	    array_agg(distinct sibnum) as lengths,
		array_agg(distinct valuelen) as lenArgs,
		array_agg(distinct t.line) as lines, 
        jsonb_agg(distinct t.sibkeys) as keys,
        jsonb_agg(distinct t.value) as args
from treewithsiblings t,
     ift (sibnum = 1, 'simple'::text, 'complex'::text) as issimple,
     ift (valuelen=1, 'onefield',
		   ift (valuelen=2, 'twofields','manyfields')) 
	     as howmany
where path like '%.not.enum'
--and value->>'type'='string'
group by cube(issimple, howmany)
order by case when issimple is null and howmany is null 
               then 1
			   when howmany is null then 2
			   when issimple is null then 3
			   else 4 end,
      count desc;

--this is for const
with temp as(
select e.path, e.value, e.line, jsonb_agg(keys order by keys) as cooccurring,
	   e.value -> 'const' as argument
from edftree e,  jsonb_object_keys(e.value) as keys
where path like '%.not' and not path like '%.$eref.%'
	--path like '%.not.$eref'
   and value @? '$.const'
	--and value->>'type'='object'
group by path, dewey, line, value, e.value ->> 'const')
select coalesce(issimple,'*'), '&', 
       'oneValue', '&', 
        count(*), '&', 
		count(distinct t.line) as numfiles, '\\',
	    array_agg(distinct len(t.cooccurring)) as lenComplex,
		array_agg(distinct t.line) as lines, 
        array_agg(distinct t.cooccurring) as keys,
         array_agg(distinct t.value)
from temp t,
     ift (len(t.cooccurring) = 1, 'simple'::text, 'complex'::text) as issimple
group by (issimple);

--analysing const
select line, key, sibkeys, value
from treewithsiblings
where path like '%not.const';

--analising the non-simple cases only: enum is always paired with type:string

SELECT  t1.key, count(distinct t2.dewey), t2.key, array_agg(t2.value) 
FROM flattree t1 join flattree t2 on (t1.pdewey=t2.pdewey)
WHERE t1.pkey='not' and t1.key='enum'  and t2.dewey != t1.dewey
group by  t1.key, t2.key;


-----** create keyParChild and coOccurrences table from the associated file

-- check that enum and type are usually related
SELECT * 
FROM cooccurrences
where key1 in ('enum') and key2 in ('enum', 'type');

--$eref
select line, key, sibkeys, len(sibkeys), value
from etreewithsiblings
where path like '%not.$eref.enum'
order by len desc;