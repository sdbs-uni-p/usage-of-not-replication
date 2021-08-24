-- counting the amount of user-defined keywords
with keyTypes as
(select  key,
        case when (key in (select keyword
						    from keywords
						    where kclass in ('s','dollar'))) then 'standard keyword'
			when key = '$'  then 'root object'
			when key like '\_\_\_%'  then 'property name'
			when key similar to '[0-9]*' then 'array element'
            else 'user-defined keyword'
            end as typeOfKey,
			row_number () over (order by key) as rowNum
from dftree) 
select typeOfKey, count(*)
from keyTypes
--where mod(rowNum,1000) = 0
group by typeOfKey;