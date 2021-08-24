select anc.dewey, des.key, des.value, des.path
       --, case when danc.value = des.value then 'yes' else 'no' end as equal
from dftree danc, edftree anc, edftree des
where  des.key = '$ref'
       and des.dewey similar to concat(anc.dewey,'.%')
       and des.path similar to '%$eref%.not%.$ref'
                 and anc.key = '$eref'
                 and danc.dewey = anc.dewey
                 and danc.value = des.value;
               
create table if not exists depends as
(select distinct
       --danc.dewey, des.dewey, 
	   danc.value as var ,
       des.value as dependsOn, des.path
       --, case when danc.value = des.value then 'yes' else 'no' end as equal
from dftree danc, edftree anc, edftree des
where  des.key = '$ref'
       and des.dewey similar to concat(anc.dewey,'.%')
       and des.path similar to '%$eref%.$ref'
                 and anc.key = '$eref'
				 and danc.key = '$ref'
                 and danc.dewey = anc.dewey
                 --and danc.value = des.value
);