-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (http://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

-- Test all possible order modes

CREATE TABLE TEST(A INT);
> ok

INSERT INTO TEST VALUES (NULL), (0), (1);
> update count: 3

-- default

SELECT A FROM TEST ORDER BY A;
> A
> ----
> null
> 0
> 1
> rows (ordered): 3

CREATE INDEX A_IDX ON TEST(A);
> ok

SELECT A FROM TEST ORDER BY A;
> A
> ----
> null
> 0
> 1
> rows (ordered): 3

EXPLAIN SELECT A FROM TEST ORDER BY A;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX" */ ORDER BY 1 /* index sorted */

DROP INDEX A_IDX;
> ok

-- ASC

SELECT A FROM TEST ORDER BY A ASC;
> A
> ----
> null
> 0
> 1
> rows (ordered): 3

CREATE INDEX A_IDX ON TEST(A ASC);
> ok

SELECT A FROM TEST ORDER BY A ASC;
> A
> ----
> null
> 0
> 1
> rows (ordered): 3

EXPLAIN SELECT A FROM TEST ORDER BY A ASC;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX" */ ORDER BY 1 /* index sorted */

DROP INDEX A_IDX;
> ok

-- ASC NULLS FIRST

SELECT A FROM TEST ORDER BY A ASC NULLS FIRST;
> A
> ----
> null
> 0
> 1
> rows (ordered): 3

CREATE INDEX A_IDX ON TEST(A ASC NULLS FIRST);
> ok

SELECT A FROM TEST ORDER BY A ASC NULLS FIRST;
> A
> ----
> null
> 0
> 1
> rows (ordered): 3

EXPLAIN SELECT A FROM TEST ORDER BY A ASC NULLS FIRST;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX" */ ORDER BY 1 NULLS FIRST /* index sorted */

DROP INDEX A_IDX;
> ok

-- ASC NULLS LAST

SELECT A FROM TEST ORDER BY A ASC NULLS LAST;
> A
> ----
> 0
> 1
> null
> rows (ordered): 3

CREATE INDEX A_IDX ON TEST(A ASC NULLS LAST);
> ok

SELECT A FROM TEST ORDER BY A ASC NULLS LAST;
> A
> ----
> 0
> 1
> null
> rows (ordered): 3

EXPLAIN SELECT A FROM TEST ORDER BY A ASC NULLS LAST;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX" */ ORDER BY 1 NULLS LAST /* index sorted */

DROP INDEX A_IDX;
> ok

-- DESC

SELECT A FROM TEST ORDER BY A DESC;
> A
> ----
> 1
> 0
> null
> rows (ordered): 3

CREATE INDEX A_IDX ON TEST(A DESC);
> ok

SELECT A FROM TEST ORDER BY A DESC;
> A
> ----
> 1
> 0
> null
> rows (ordered): 3

EXPLAIN SELECT A FROM TEST ORDER BY A DESC;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX" */ ORDER BY 1 DESC /* index sorted */

DROP INDEX A_IDX;
> ok

-- DESC NULLS FIRST

SELECT A FROM TEST ORDER BY A DESC NULLS FIRST;
> A
> ----
> null
> 1
> 0
> rows (ordered): 3

CREATE INDEX A_IDX ON TEST(A DESC NULLS FIRST);
> ok

SELECT A FROM TEST ORDER BY A DESC NULLS FIRST;
> A
> ----
> null
> 1
> 0
> rows (ordered): 3

EXPLAIN SELECT A FROM TEST ORDER BY A DESC NULLS FIRST;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX" */ ORDER BY 1 DESC NULLS FIRST /* index sorted */

DROP INDEX A_IDX;
> ok

-- DESC NULLS LAST

SELECT A FROM TEST ORDER BY A DESC NULLS LAST;
> A
> ----
> 1
> 0
> null
> rows (ordered): 3

CREATE INDEX A_IDX ON TEST(A DESC NULLS LAST);
> ok

SELECT A FROM TEST ORDER BY A DESC NULLS LAST;
> A
> ----
> 1
> 0
> null
> rows (ordered): 3

EXPLAIN SELECT A FROM TEST ORDER BY A DESC NULLS LAST;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX" */ ORDER BY 1 DESC NULLS LAST /* index sorted */

DROP INDEX A_IDX;
> ok

-- Index selection

CREATE INDEX A_IDX_ASC ON TEST(A ASC);
> ok

CREATE INDEX A_IDX_ASC_NL ON TEST(A ASC NULLS LAST);
> ok

CREATE INDEX A_IDX_DESC ON TEST(A DESC);
> ok

CREATE INDEX A_IDX_DESC_NF ON TEST(A DESC NULLS FIRST);
> ok

EXPLAIN SELECT A FROM TEST ORDER BY A;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_ASC" */ ORDER BY 1 /* index sorted */

EXPLAIN SELECT A FROM TEST ORDER BY A ASC;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_ASC" */ ORDER BY 1 /* index sorted */

EXPLAIN SELECT A FROM TEST ORDER BY A NULLS FIRST;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_ASC" */ ORDER BY 1 NULLS FIRST /* index sorted */

EXPLAIN SELECT A FROM TEST ORDER BY A NULLS LAST;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_ASC_NL" */ ORDER BY 1 NULLS LAST /* index sorted */

EXPLAIN SELECT A FROM TEST ORDER BY A DESC;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_DESC" */ ORDER BY 1 DESC /* index sorted */

EXPLAIN SELECT A FROM TEST ORDER BY A DESC NULLS FIRST;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_DESC_NF" */ ORDER BY 1 DESC NULLS FIRST /* index sorted */

EXPLAIN SELECT A FROM TEST ORDER BY A DESC NULLS LAST;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_DESC" */ ORDER BY 1 DESC NULLS LAST /* index sorted */

DROP INDEX A_IDX_ASC;
> ok

DROP INDEX A_IDX_DESC;
> ok

CREATE INDEX A_IDX_ASC_NF ON TEST(A ASC NULLS FIRST);
> ok

CREATE INDEX A_IDX_DESC_NL ON TEST(A DESC NULLS LAST);
> ok

EXPLAIN SELECT A FROM TEST ORDER BY A;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_ASC_NF" */ ORDER BY 1 /* index sorted */

EXPLAIN SELECT A FROM TEST ORDER BY A ASC;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_ASC_NF" */ ORDER BY 1 /* index sorted */

EXPLAIN SELECT A FROM TEST ORDER BY A NULLS FIRST;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_ASC_NF" */ ORDER BY 1 NULLS FIRST /* index sorted */

EXPLAIN SELECT A FROM TEST ORDER BY A NULLS LAST;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_ASC_NL" */ ORDER BY 1 NULLS LAST /* index sorted */

EXPLAIN SELECT A FROM TEST ORDER BY A DESC;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_DESC_NL" */ ORDER BY 1 DESC /* index sorted */

EXPLAIN SELECT A FROM TEST ORDER BY A DESC NULLS FIRST;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_DESC_NF" */ ORDER BY 1 DESC NULLS FIRST /* index sorted */

EXPLAIN SELECT A FROM TEST ORDER BY A DESC NULLS LAST;
>> SELECT "A" FROM "PUBLIC"."TEST" /* "PUBLIC"."A_IDX_DESC_NL" */ ORDER BY 1 DESC NULLS LAST /* index sorted */

DROP TABLE TEST;
> ok

-- Other tests

create table test(a int, b int);
> ok

insert into test values(1, 1);
> update count: 1

create index on test(a, b desc);
> ok

select * from test where a = 1;
> A B
> - -
> 1 1
> rows: 1

drop table test;
> ok

create table test(x int);
> ok

create hash index on test(x);
> ok

select 1 from test group by x;
> 1
> -
> rows: 0

drop table test;
> ok

CREATE TABLE TEST(A INT, B INT, C INT);
> ok

CREATE INDEX T_A1 ON TEST(A);
> ok

CREATE INDEX T_A_B ON TEST(A, B);
> ok

CREATE INDEX T_A_C ON TEST(A, C);
> ok

EXPLAIN SELECT * FROM TEST WHERE A = 0;
>> SELECT "TEST"."A", "TEST"."B", "TEST"."C" FROM "PUBLIC"."TEST" /* "PUBLIC"."T_A1": "A" = 0 */ WHERE "A" = 0

EXPLAIN SELECT * FROM TEST WHERE A = 0 AND B >= 0;
>> SELECT "TEST"."A", "TEST"."B", "TEST"."C" FROM "PUBLIC"."TEST" /* "PUBLIC"."T_A_B": "A" = 0 AND "B" >= 0 */ WHERE ("A" = 0) AND ("B" >= 0)

EXPLAIN SELECT * FROM TEST WHERE A > 0 AND B >= 0;
>> SELECT "TEST"."A", "TEST"."B", "TEST"."C" FROM "PUBLIC"."TEST" /* "PUBLIC"."T_A_B": "A" > 0 AND "B" >= 0 */ WHERE ("A" > 0) AND ("B" >= 0)

INSERT INTO TEST (SELECT X / 100, X, X FROM SYSTEM_RANGE(1, 3000));
> update count: 3000

EXPLAIN SELECT * FROM TEST WHERE A = 0;
>> SELECT "TEST"."A", "TEST"."B", "TEST"."C" FROM "PUBLIC"."TEST" /* "PUBLIC"."T_A1": "A" = 0 */ WHERE "A" = 0

EXPLAIN SELECT * FROM TEST WHERE A = 0 AND B >= 0;
>> SELECT "TEST"."A", "TEST"."B", "TEST"."C" FROM "PUBLIC"."TEST" /* "PUBLIC"."T_A_B": "A" = 0 AND "B" >= 0 */ WHERE ("A" = 0) AND ("B" >= 0)

EXPLAIN SELECT * FROM TEST WHERE A > 0 AND B >= 0;
>> SELECT "TEST"."A", "TEST"."B", "TEST"."C" FROM "PUBLIC"."TEST" /* "PUBLIC"."T_A_B": "A" > 0 AND "B" >= 0 */ WHERE ("A" > 0) AND ("B" >= 0)

-- Test that creation order of indexes has no effect
CREATE INDEX T_A2 ON TEST(A);
> ok

DROP INDEX T_A1;
> ok

EXPLAIN SELECT * FROM TEST WHERE A = 0;
>> SELECT "TEST"."A", "TEST"."B", "TEST"."C" FROM "PUBLIC"."TEST" /* "PUBLIC"."T_A2": "A" = 0 */ WHERE "A" = 0

DROP TABLE TEST;
> ok
