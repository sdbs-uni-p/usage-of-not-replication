---look all the lists
with temp as
(select count(*) as numRequiredArgsOfAnyOf,
        array_agg(value) as skeleton,
        jsonb_agg(len(value)) as listOfRequiredListLength,
        min(len(value)) as minRequiredListLength,
        max(len(value)) as maxRequiredListLength
from flattree
where p3key = 'not' and p2key = 'anyOf' and key = 'required'
group by p2dewey)
select listOfRequiredListLength, minRequiredListLength,
       len(listOfRequiredListLength), count(*)
from temp
group by listOfRequiredListLength, minRequiredListLength
order by count(*) desc;

--generate numbers: when reqlist = 1, we have 10 cases; when reqlist = 2, we have 17 cases; 
with temp as
(select count(*) as numRequiredArgsOfAnyOf,
        array_agg(value) as skeleton,
        jsonb_agg(len(value)) as listOfRequiredListLength,
        min(len(value)) as minRequiredListLength,
        max(len(value)) as maxRequiredListLength
from flattree
where p3key = 'not' and p2key = 'anyOf' and key = 'required'
group by p2dewey)
select minRequiredListLength as reqListLen,count(*),
       max(maxRequiredListLength) as reqListLenControl,
       min(len(listOfRequiredListLength)) as minLenAnyOfArg,
	   max(len(listOfRequiredListLength)) AS mAXLenAnyOfArg
from temp
group by minRequiredListLength
order by count(*) desc;