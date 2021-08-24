-- combining xtype-object with object assertions: 22 cases
SELECT  t1.dewey, t1.pkey, s.sibkeys as uncles, t1.key, t1.value, 
      array_agg(t2.key) as siblings, count(*) as sibnum
FROM flattree t1 join flattree t2 on (t1.pdewey=t2.pdewey)
     join treewithsiblings s on (t1.pdewey=s.dewey)
WHERE t1.pkey='not' and t1.key='type'  
      and t2.dewey != t1.dewey  --check that it is complex
	  and t1.value = '"object"'
group by  t1.dewey, t1.pkey, s.sibkeys, t1.key, t1.value --, t2.key
order by sibkeys;

-- combining xtype-string with string assertions: 19 cases
SELECT  t1.dewey, t1.pkey, s.sibkeys as uncles, t1.key, t1.value, 
      array_agg(t2.key) as siblings, count(*) as sibnum
FROM flattree t1 join flattree t2 on (t1.pdewey=t2.pdewey)
     join treewithsiblings s on (t1.pdewey=s.dewey)
WHERE t1.pkey='not' and t1.key='type'  
      and t2.dewey != t1.dewey  --check that it is complex
	  and t1.value = '"string"'
group by  t1.dewey, t1.pkey, s.sibkeys, t1.key, t1.value --, t2.key
order by sibkeys;