-- Number of occurrences of \xnot.\xany/\xone/\xall[*].$k$ for the different keywords
Select e1.p3key, '&', --p2s.sibkeys as uncles, 
        e1.p2key,  '&', e1.key, '&', 
		count(distinct e1.p2dewey) as "not.op([where *])", '&',
		count(*),  '&',
		count(distinct e1.line) as lines,
		 '\\'
FROM eflattree e1 
WHERE e1.p3key='not' --and e1.pkey='anyOf' 
      and not e1.added
      AND e1.pkey similar to '[0-9]+'
--and sibnum = 1
GROUP BY e1.p3key, e1.p2key, e1.key
ORDER BY e1.p2key, count desc, lines desc;