--counting
select count(*), count(distinct line)
from dftree
where path like '%not.patternProperties';

--having a look at the 15 different cases
select pkey, key, value, sibkeys, count(*)
from treewithsiblings
where path like '%.not.patternProperties'
group by pkey, key, value, sibkeys;

--analisyng the contexts
--grouping pproperties on the basis of the pattern
--keywords that cooccur with properties under negation
-- e2: sibling of patternProperties; e2.dewey != e1.dewey to count the complex cases
--notsib: siblings of the not
select count(*), array_agg(e1.line) as files, --e1.pdewey, 
       forcelen(e1.value) as numProp,
       e1.value as ppArg, jsonb_agg(e2.key order by e2.key) as cooccur, 
      jsonb_agg(e2.value order by e2.value) as cooccurArg,
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
order by e1.value --jsonb_agg(e2.key);