--structure of not.properties
select coalesce(issimple,'*'), '&', 
       coalesce(howmany,'*'), '&', 
        count(*), '&', 
		count(distinct e.line) as numfiles, '\\' ,
	    jsonb_agg(distinct sibnum) as lenComplex,
		jsonb_agg(distinct forcelen(e.value)) as lenArgs,
		jsonb_agg(distinct e.line) as lines, 
        jsonb_agg(distinct s.sibkeys) as keys,
        jsonb_agg(distinct e.value)
from eflattree e 
join etreewithsiblings s on (e.dewey=s.dewey),
     ift (s.sibnum = 1, 'simple'::text, 'complex'::text) as issimple,
     ift (forcelen(e.value)=1, 'oneProperty', 
	    ift (forcelen(e.value)=2, 'twoProperties','manyProperties'))
	     as howmany
where e.pkey = 'not' and e.key = 'properties' and not e.added
group by cube(issimple, howmany)
order by NullOrder(issimple.issimple,howmany.howmany),
            count desc;
            

--what is negated by not.property
select coalesce(issimple,'*'), '&', 
       coalesce(howmany,'*'), '&', 
        count(*), '&', 
		count(distinct e.line) as numfiles, '\\' ,
		e2.key,
	    jsonb_agg(distinct sibnum) as lenComplex,
		jsonb_agg(distinct forcelen(e.value)) as lenArgs,
		jsonb_agg(distinct e.line) as lines, 
        jsonb_agg(distinct s.sibkeys) as keys  --, e.value
        --,jsonb_agg(distinct e.value)
from eflattree e join eflattree e2 on (e.dewey=e2.p2dewey)
join etreewithsiblings s on (e.dewey=s.dewey),
     ift (s.sibnum = 1, 'simple'::text, 'complex'::text) as issimple,
     ift (forcelen(e.value)=1, 'oneProperty', 
	    ift (forcelen(e.value)=2, 'twoProperties','manyProperties'))
	     as howmany
where e.pkey = 'not' and e.key = 'properties' and not e.added
group by cube(issimple, howmany), e2.key
order by NullOrder(issimple.issimple,howmany.howmany),
            count desc;