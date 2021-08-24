--counting cooccurrences in positive cases (requires table ``cooccurrences'')
--outdated
SELECT * 
FROM cooccurrences
where key1 in ('patternProperties')
order by count desc;

--structure of not.patternProperties
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
where e.pkey = 'not' and e.key = 'patternProperties' and not e.added
group by cube(issimple, howmany)
order by NullOrder(issimple.issimple,howmany.howmany),
            count desc;

--what is negated by not.patternProperties
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
where e.pkey = 'not' and e.key = 'patternProperties' and not e.added
group by cube(issimple, howmany), e2.key
order by NullOrder(issimple.issimple,howmany.howmany),
            count desc;

--checking that all propPatterns have the same context
select count(*), array_agg(e1.line), --e1.pdewey, 
       forcelen(e1.value) as numProp,
       e1.value as ppArg, jsonb_agg(e2.key order by e2.key) as cooccur, 
      jsonb_agg(distinct e2.value order by e2.value) as cooccurArg,
	  jsonb_agg(notsib.pkey) as notsibpkey,
	  jsonb_agg(notsib.key) as notsibkey,
	  notsib.value
from flattree e1 join dftree e2 using (line,pdewey,pkey) --added,
     join dftree notsib on (notsib.pdewey=e1.p2dewey)
where e1.pkey = 'not' and e1.key = 'patternProperties'
       and e2.dewey != e1.dewey
	   and notsib.key = 'patternProperties'
	   --and e2.key = 'required' 
	   --and not added
group by --e1.line, e1.pdewey, 
         e1.value, notsib.value --, e2.value
order by e1.value; --jsonb_agg(e2.key);

--keywords that cooccur with patternProperties under negation
select line, pdewey, e1.value, jsonb_agg(e2.key), jsonb_agg(e2.value)
from edftree e1 join edftree e2 using (line,pdewey,added,pkey)
where pkey = 'not' and e1.key = 'patternProperties'
       and e2.dewey != e1.dewey
	   --and e2.key = 'required' 
	   and not added
group by line, pdewey, e1.value --, e2.value
order by jsonb_agg(e2.key);