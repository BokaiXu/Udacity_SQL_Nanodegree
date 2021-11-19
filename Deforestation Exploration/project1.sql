# View
SELECT *
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=f.country_code

# 1-a,1-b
SELECT f.country_code, f.country_name, f.year,
       f.forest_area_sqkm, l.total_area_sq_mi,
       r.region, r.income_group,
       f.forest_area_sqkm/(l.total_area_sq_mi*2.59) AS precent_land_area
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=f.country_code
WHERE (f.year=1990 OR f.year=2016) AND region LIKE '%World%'

# 1-c,1-d
WITH t1 AS(SELECT f.country_code, f.country_name, f.year,
       f.forest_area_sqkm, l.total_area_sq_mi,
       r.region, r.income_group,
       f.forest_area_sqkm/(l.total_area_sq_mi*2.59) AS precent_land_area
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=f.country_code
WHERE (f.year=1990 OR f.year=2016) AND region LIKE '%World%')

SELECT year,forest_area_sqkm,
       forest_area_sqkm-LAG(forest_area_sqkm)OVER() AS difference,
       (forest_area_sqkm-LAG(forest_area_sqkm)OVER())/forest_area_sqkm AS ratio
FROM t1

# 1-e
SELECT country_name, total_area_sq_mi, total_area_sq_mi*2.59 AS total_area_sqkm
FROM land_area
WHERE year=2016 AND total_area_sq_mi<1324449/2.59
ORDER BY 2 DESC
LIMIT 1

# 2-a
WITH t1 AS (
SELECT f.country_code, f.country_name, f.year,
       f.forest_area_sqkm, l.total_area_sq_mi,
       r.region, r.income_group
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=f.country_code
WHERE f.year=2016)

SELECT region, year,
       SUM(forest_area_sqkm) AS sum_forest_area_sqkm,
       SUM(total_area_sq_mi*2.59) AS sum_total_area_sqkm,
       SUM(forest_area_sqkm)/SUM(total_area_sq_mi*2.59) AS ratio
FROM t1
GROUP BY 2,1
ORDER BY 5 DESC

# 2-b
WITH t1 AS (
SELECT f.country_code, f.country_name, f.year,
       f.forest_area_sqkm, l.total_area_sq_mi,
       r.region, r.income_group
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=f.country_code
WHERE f.year=1990)

SELECT region, year,
       SUM(forest_area_sqkm) AS sum_forest_area_sqkm,
       SUM(total_area_sq_mi*2.59) AS sum_total_area_sqkm,
       SUM(forest_area_sqkm)/SUM(total_area_sq_mi*2.59) AS ratio
FROM t1
GROUP BY 2,1
ORDER BY 5 DESC

# 2-c
WITH t2016 AS(
SELECT DISTINCT(region), f.year AS year_2016,
       SUM(forest_area_sqkm) OVER (PARTITION BY region) AS forest_area_sqkm,
       SUM(total_area_sq_mi*2.59) OVER (PARTITION BY region) AS total_area_sqkm,
       SUM(forest_area_sqkm) OVER (PARTITION BY region)/SUM(total_area_sq_mi*2.59) OVER (PARTITION BY region) AS ratio_2016
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=f.country_code
WHERE f.year=2016
ORDER BY 4 DESC),

t1990 AS(
SELECT DISTINCT(region), f.year AS year_1990,
       SUM(forest_area_sqkm) OVER (PARTITION BY region) AS forest_area_sqkm,
       SUM(total_area_sq_mi*2.59) OVER (PARTITION BY region) AS total_area_sqkm,
       SUM(forest_area_sqkm) OVER (PARTITION BY region)/SUM(total_area_sq_mi*2.59) OVER (PARTITION BY region) AS ratio_1990
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=f.country_code
WHERE f.year=1990
ORDER BY 4 DESC)

SELECT t2016.region, t2016.year_2016, t2016.ratio_2016,
       t1990.year_1990, t1990.ratio_1990
FROM t2016
JOIN t1990
ON t2016.region=t1990.region
WHERE ratio_2016<ratio_1990

# 3-a,b
WITH t1990 AS (
SELECT f.country_name AS name,
       f.country_code AS code,
       region AS region,
       f.year AS year_1990,
       f.forest_area_sqkm AS forest_area_sqkm_1990,
       l.total_area_sq_mi*2.59 AS total_area_sqkm_1990
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=f.country_code
WHERE f.year=1990),

t2016 AS (
SELECT f.country_name AS name,
       f.country_code AS code,
       region AS region,
       f.year AS year_2016,
       f.forest_area_sqkm AS forest_area_sqkm_2016,
       l.total_area_sq_mi*2.59 AS total_area_sqkm_2016
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=f.country_code
WHERE f.year=2016)

SELECT t1990.name, t1990.region,
       forest_area_sqkm_2016-forest_area_sqkm_1990 AS area_diff,
       (forest_area_sqkm_2016-forest_area_sqkm_1990)/forest_area_sqkm_1990  AS area_diff_ratio
FROM t1990
JOIN t2016
ON t1990.code=t2016.code
ORDER BY 4

# 3-c
WITH t1 AS(
SELECT f.country_name AS name,
f.country_code AS code,
region AS region,
f.year AS year_2016,f.forest_area_sqkm/(l.total_area_sq_mi*2.59) AS percent,
CASE WHEN f.forest_area_sqkm/(l.total_area_sq_mi*2.59) >=0.75 THEN 1
WHEN f.forest_area_sqkm/(l.total_area_sq_mi*2.59)>=0.50 THEN 2
WHEN f.forest_area_sqkm/(l.total_area_sq_mi*2.59)>=0.25 THEN 3
WHEN f.forest_area_sqkm/(l.total_area_sq_mi*2.59)>=0 THEN 4 END AS ntile
FROM forest_area f
JOIN land_area l ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=f.country_code
WHERE f.year=2016 AND region not LIKE '%World%')
SELECT ntile, COUNT(ntile)
FROM t1
GROUP BY 1

# 3-d
WITH t1 AS(
SELECT f.country_name AS name,
       f.country_code AS code,
       region AS region,
       f.year AS year_2016,
       f.forest_area_sqkm/(l.total_area_sq_mi*2.59) AS percent,
       CASE WHEN f.forest_area_sqkm/(l.total_area_sq_mi*2.59) >=0.75 THEN 1
       WHEN f.forest_area_sqkm/(l.total_area_sq_mi*2.59)>=0.50 THEN 2
       WHEN f.forest_area_sqkm/(l.total_area_sq_mi*2.59)>=0.25 THEN 3
       WHEN f.forest_area_sqkm/(l.total_area_sq_mi*2.59)>=0 THEN 4 END AS ntile
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=f.country_code
WHERE f.year=2016)

SELECT name, percent,region
FROM t1
WHERE ntile=1
ORDER BY 2 DESC

# 3-e
WITH t1 AS(
SELECT f.country_name AS name,
       f.country_code AS code,
       region AS region,
       f.year AS year_2016,
       f.forest_area_sqkm/(l.total_area_sq_mi*2.59) AS percent,
       CASE WHEN f.forest_area_sqkm/(l.total_area_sq_mi*2.59) >=0.75 THEN 1
       WHEN f.forest_area_sqkm/(l.total_area_sq_mi*2.59)>=0.50 THEN 2
       WHEN f.forest_area_sqkm/(l.total_area_sq_mi*2.59)>=0.25 THEN 3
       WHEN f.forest_area_sqkm/(l.total_area_sq_mi*2.59)>=0 THEN 4 END AS ntile
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON r.country_code=f.country_code
WHERE f.year=2016)

SELECT COUNT(name)
FROM t1
WHERE percent>(
  SELECT percent
  FROM t1
  WHERE name LIKE '%United States%')
