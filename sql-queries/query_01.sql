-- trivial duplicate elimination, producing 23683 distinct schemas
DROP TABLE IF EXISTS uniq;


CREATE TABLE uniq AS
	(SELECT doc -> 'schema_file' AS sch,
			COUNT(*) AS C
		FROM dist
		GROUP BY doc -> 'schema_file');


SELECT COUNT(*)
FROM uniq;