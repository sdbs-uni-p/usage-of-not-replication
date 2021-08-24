select coalesce(f.draft,'total') as draft, '&',
       count(*) as count, '&',
	   round(count(*)*100.0/g.grandtotal,2) as percentage, '\\'
from fileschema f, 
     (select count(*) from fileschema) as g(grandtotal)
group by rollup(f.draft), g.grandtotal
order by draft;