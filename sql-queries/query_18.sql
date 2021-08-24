--counting the categories
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
     ift (valuelen=1, 'onetype','manytypes')
	     as howmany
where path like '%.not.type'
--and value->>'type'='string'
group by cube(issimple, howmany)
order by NullOrder(issimple.issimple,howmany.howmany),
            count desc;
            
--   analysing co-occurring assertions in complex values
SELECT  t1.key, t1.value, t2.key associatedKey, count(distinct t2.dewey), array_agg(t2.value) t2values
FROM flattree t1 join flattree t2 on (t1.pdewey=t2.pdewey)
WHERE t1.pkey='not' and 
      t1.key='type'  and t2.dewey != t1.dewey
group by  t1.key, t1.value, t2.key
order by count desc;

--13 out of 19 negated type:object have a type sibling for ``not''
SELECT  t1.dewey, t1.pkey, s.sibkeys, t1.key, t1.value, 
      array_agg(t2.key), count(*)
   --, t2.key associatedKey, count(distinct t2.dewey), array_agg(t2.value) t2values
FROM flattree t1 join flattree t2 on (t1.pdewey=t2.pdewey)
     join treewithsiblings s on (t1.pdewey=s.dewey)
WHERE t1.pkey='not' and 
      t1.key='type'  and t2.dewey != t1.dewey
	  and t1.value = '"object"'
group by  t1.dewey, t1.pkey, s.sibkeys, t1.key, t1.value --, t2.key
order by sibkeys;
         
      
---looking at the arguments of ``type'' at the end of not.type and the co-occurring strings
select t.value, '&', -->>'type', 
         coalesce(issimple,'*'), '&', 
       --coalesce(howmany,'*'), '&', 
        count(*), '&', 
		count(distinct t.line) as numfiles, '\\',
	    array_agg(distinct sibnum) as lengths,
		array_agg(distinct valuelen) as lenArgs,
		array_agg(distinct t.line) as lines, 
        t.sibkeys as keys, --jsonb_agg(distinct t.sibkeys) as keys,
        jsonb_agg(distinct t.value) as args
from treewithsiblings t,
     ift (sibnum = 1, 'simple'::text, 'complex'::text) as issimple,
     ift (valuelen=1, 'onetype','manytypes')
	     as howmany
where path like '%.not.type'
and t.value::text ='"string"'
group by cube(issimple, howmany,t.sibkeys), t.value-->>'type'
order by NullOrder(issimple.issimple,howmany.howmany),
            count desc;

--analising which keys co-occurr with type
SELECT  thetype, --objlen(t.arg),
        count(*), --count(distinct (t.line, t.num)) as numfiles,
        array_agg(distinct t.line) as lines,
        array_agg(distinct array_to_string(t.keys,',')) as otherkeys,
        array_agg(distinct t.arg->>'type') as args,
        array_agg(distinct t.arg)
FROM notargs t
        ,jsonb_path_query(t.arg,'$.type') as thetype
where t.arg @? '$.type'::jsonpath
        and objlen(t.arg) > 1
group by  thetype, array_to_string(t.keys,',')
order by thetype, count desc;


--analysing complex usage of type in generale (this one takes 2 mins to run) (does not work?)
with temp as(
select e.path,
       e.value , 
	   e.line,
       jsonb_agg(keys order by keys) as cooccurring,
	   e.value -> 'type' as argument
from flattree e,
      jsonb_object_keys(e.value) as keys
where --path like '%.not' --and not path like '%.$eref.%'
	--path like '%.not.$eref' and 
    value @? '$.type'
	and jsonb_typeof(e.value)='object'
	and value->>'type'='string'
group by path, dewey, line, value, e.value ->> 'type')
select coalesce(issimple,'*'), '&', 
       coalesce(howmany,'*'), '&', 
        count(*), '&', 
		count(distinct t.line) as numfiles, '\\',
	    array_agg(distinct len(t.cooccurring)) as lenComplex,
		array_agg(distinct forcelen(t.argument)) as lenArgs,
		array_agg(distinct t.line) as lines, 
        array_agg(distinct t.cooccurring) as keys,
        array_agg(distinct t.argument) as args,
        array_agg(distinct t.value)
from temp t,
     ift (len(t.cooccurring) = 1, 'simple'::text, 'complex'::text) as issimple,
     ift (forcelen(t.argument)=1, 'oneValue',
		   ift (forcelen(t.argument)=2, 'twoValues','manyValues')) 
	     as howmany
group by cube(issimple, howmany)
order by NullOrder(issimple.issimple,howmany.howmany),
            count desc;