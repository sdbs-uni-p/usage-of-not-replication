--pattern: counting the categories
select coalesce(issimple,'*'), '&', 
        count(*), '&', 
		count(distinct t.line) as numfiles, '\\',
	    array_agg(distinct sibnum) as lengths,
       jsonb_agg(distinct t.sibkeys) as keys,
        jsonb_agg(distinct t.value) as args
from treewithsiblings t,
     ift (sibnum = 1, 'simple'::text, 'complex'::text) as issimple
where path like '%.not.pattern'
group by cube(issimple)
order by case  when issimple is null then 3
			   else 4 end,
      count desc;
      
/*
*	&	47	&	28	\\
simple	&	46	&	27	\\
complex	&	1	&	1	\\
*/

--counting cooccurrences in positive cases (requires table ``cooccurrences'')
SELECT * 
FROM cooccurrences
where key1 in ('pattern')
order by count desc;
      

--checking how many times is paired with type: string
SELECT  t1.key, count(distinct t2.dewey), t2.key, array_agg(t2.value) 
FROM flattree t1 join flattree t2 on (t1.pdewey=t2.pdewey)
WHERE --t1.pkey='not' and 
      t1.key='pattern'  and t2.dewey != t1.dewey
group by  t1.key, t2.key
order by count desc;

SELECT  count(*)
from dftree
where key = 'pattern';

--checking it never appears below $eref
select *
from edftree
where path like '%.not.$eref.pattern';