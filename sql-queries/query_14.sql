---three keys just two times
select line, pkey, key, jsonb_array_length(value) as numFields,value
from dftree
where path like '%.not.required'
      and jsonb_array_length(value) > 2;

-- positive instance with 411 elements in the array
select forcelen(value), line, key, value
from dftree
where key = 'required'
order by forcelen desc;