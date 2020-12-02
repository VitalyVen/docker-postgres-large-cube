drop table if exists noindex cascade ;
CREATE TABLE noindex
AS
  SELECT i, cube(array_agg(random()::float)) AS vector_0
          FROM generate_series(1,1000000) AS i
          CROSS JOIN LATERAL generate_series(1,512)
            AS x
          GROUP BY i;

-- CREATE INDEX ON mytable USING gist (vector_0, vector_1);
SELECT i from noindex order by
(select vector_0 from noindex limit 1 offset 3)<-> vector_0
         asc limit 100;
-- 4 s


drop table if exists mytable cascade ;

CREATE TABLE mytable
AS
  SELECT i,
         cube(array_agg(random()::float)) AS vector_0,
         cube(array_agg(random()::float)) AS vector_1,
         cube(array_agg(random()::float)) AS vector_2,
         cube(array_agg(random()::float)) AS vector_3
          FROM generate_series(1,100000) AS i
          CROSS JOIN LATERAL generate_series(1,128)
            AS x
          GROUP BY i;

CREATE INDEX v12 ON mytable USING gist (vector_0, vector_1);
CREATE INDEX v34 ON mytable USING gist (vector_2, vector_3);
ANALYZE mytable;

SELECT i from mytable order by
sqrt(
            power((select vector_0 from mytable limit 1)<-> vector_0, 2)
            +
            power((select vector_1 from mytable limit 1)<-> vector_1, 2)
            +
            power((select vector_2 from mytable limit 1)<-> vector_2, 2)
            +
            power((select vector_3 from mytable limit 1)<-> vector_3, 2)
    )
         asc limit 100;


drop index if exists v12, v34;

drop table if exists mytable2 cascade ;
CREATE TABLE mytable2
AS
  SELECT i,
         cube(array_agg(random()::float)) AS vector_0,
         cube(array_agg(random()::float)) AS vector_1,
         cube(array_agg(random()::float)) AS vector_2,
         cube(array_agg(random()::float)) AS vector_3
          FROM generate_series(1,1000000) AS i
          CROSS JOIN LATERAL generate_series(1,128)
            AS x
          GROUP BY i;

CREATE INDEX v0 ON mytable USING gist (vector_0 desc);
CREATE INDEX v1 ON mytable USING gist (vector_1 desc);
CREATE INDEX v2 ON mytable USING gist (vector_2 desc);
CREATE INDEX v3 ON mytable USING gist (vector_3 desc);

ANALYZE mytable2;

SET random_page_cost = DEFAULT;
SET random_page_cost = 1;
SET enable_seqscan=false;
with v as (select vector_0 from mytable2 limit 1)
SELECT i from mytable2 order by
sqrt(
            power((select * from v)<-> vector_0, 2)
            +
            power((select * from v)<-> vector_1, 2)
                +
            power((select * from v))<-> vector_2, 2)
                +
            power((select * from v)<-> vector_3, 2)
    )
         asc limit 100 offset 0;