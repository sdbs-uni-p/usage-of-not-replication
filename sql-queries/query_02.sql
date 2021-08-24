--count how many different descriptions exist
drop table if exists descriptions;
create table descriptions as
(select sch,
	   concat(right(sch#>>'{id}',260),'---',
			  right(sch#>>'{"$id"}',260),'+++',
			  right(sch#>>'{title}',260),'---',
              right(sch#>>'{description}',260)) as description,
       length(sch::text) as len,
       c
from uniq);
drop table if exists gdescriptions;
create table gdescriptions as
(select description,
       count(*) as versions, sum(c) as copies, min(len), max(len), 
       round(avg(len)) as avg, round(stddev(len)) as stdd
from descriptions
group by description);

---different descriptions: 15295+4519 = 19814 su 23683
--
select count(*)
from gdescriptions
union 
select versions
from gdescriptions
where description = '---+++---';

--half of the description disappear when we move to distfiles2!!!!
select(
select count(distinct d.description) 
from gdescriptions d left join distfiles2 dd using(description)
where dd.description is null) as "lostDescr",
(
select count(distinct dd.description)
from distfiles2 dd ) as "dist2Descr"
from dual;