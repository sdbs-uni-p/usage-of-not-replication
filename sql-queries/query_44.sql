--count occurrences of simple and not simple: 98 - 96
select count(*) as cocc, count(distinct line) as cfiles, jsonb_agg(line), 
        sibnum, sibkeys, valuelen --%, value
from treewithsiblings
where key = 'not' and path similar to '%.properties.[^.]*.not'
group by sibnum, sibkeys, valuelen --%, value
order by cocc desc;

--analysiie the structure
select count(*) as cocc, count(distinct line) as cfiles, jsonb_agg(line) 
        sibnum, sibkeys, valuelen --%, value
from treewithsiblings
where key = 'not' and path similar to '%.properties.[^.]*.not'
--and sibnum > 1
group by sibnum, sibkeys, valuelen --%, value
order by cocc desc;

--counting
select  const::text,
       case when sibnum = 1 then 'simpleSchema' else 'complexSchema' end, 
       case when valuelennew = 1 then 'simpleArg' else 'complexArg' end,
	   count(*) as cocc, 
       count(distinct line) as cfiles, 
	   jsonb_agg(distinct line) files
from treesibargs, ( values ('properties'),('definitions')) as const
where key = 'not' 
        and path similar to concat('%.', const,'.[^.]*.not') -- comment here for general counting
group  by   const,
       cube(
		   case when sibnum = 1 then 'simpleSchema' else 'complexSchema' end, 
       case when valuelennew = 1 then 'simpleArg' else 'complexArg' end )
order by const desc, cocc desc;