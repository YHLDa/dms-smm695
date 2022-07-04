-- As id is a bigserial (auto incremented value), we can avoid specifying its value
INSERT INTO weather.us_weather (
city, temp_lo, temp_hi, prcp, date)
VALUES ('San Francisco', 43, 57, 0.0, '1994-11-29');



-- Constraint
-- uniqie constraint on email column:
ALTER TABLE people.person ADD CONSTRAINT unique_email  UNIQUE (email);

-- primary key constraint:
ALTER TABLE people.person ADD CONSTRAINT pk_id  UNIQUE (id);

-- check constraint:
ALTER TABLE people.person ADD CONSTRAINT check_gender 
CHECK (gender = 'Female' OR gender = 'Male' OR gender = 'Other');



-- Basic
-- SELECT FROM WHERE
SELECT * FROM people.person  WHERE gender = 'Female' AND NOT email IS NULL;

-- DISTINCT
SELECT DISTINCT country FROM people.location;

-- ORDER BY
SELECT DISTINCT country FROM people.location ORDER BY country DESC;

-- LIKE
SELECT * FROM people.person WHERE email LIKE '%amazon%';

-- iLIKE
SELECT * FROM people.person WHERE first_name iLIKE 'r%'; 

-- BETWEEN
SELECT * FROM people.person WHERE dob BETWEEN '1999-01-01' AND '1999-12-31';

-- EXTRACT 
SELECT *, EXTRACT(YEAR FROM dob) AS dob_year FROM people.person
WHERE EXTRACT(YEAR FROM dob) BETWEEN 1996 AND 2000;

-- GROUP BY, HAVING
SELECT car_make, COUNT(*) FROM people.car WHERE car_year > 2000
GROUP BY car_make HAVING COUNT(*) BETWEEN 50 AND 100;



-- Advanced
-- split:
SELECT
	address,
    split_part(address::TEXT,' ', 1) AS street_number
FROM
    address;

-- concat (and lower):
SELECT address, district, LOWER(CONCAT (address, ', ' , district)) AS full_address FROM address;

-- current date:
SELECT NOW();

-- WITH AS
WITH split_query AS (
SELECT artist, split_part(artist::text, ',', 1) AS last_name,
split_part(split_part(artist, ', ', 2), ' ', 3) AS second_name
FROM artists
WHERE split_part(split_part(artist, ', ', 2), ' ', 1) ILIKE 'sir%'
OR split_part(split_part(artist, ', ', 2), ' ', 1) ILIKE 'dr.%'
)
UPDATE artists
SET 
last_name  = split_query.last_name,
second_name = split_query.second_name
FROM split_query
WHERE artists.artist = split_query.artist;

-- CAST
CAST(split_part(address::TEXT,' ', 1) AS numeric)

-- Unnest the array:
SELECT gender, mda, unnest(movNames) FROM table_array

-- Mixed data type can create problems, let's use text for the column year:
ALTER TABLE artworks ALTER COLUMN year SET DATA TYPE text;
ALTER TABLE artworks ALTER COLUMN year SET DATA TYPE int USING year::integer;



-- Extend column
-- Add a new column to link tables
ALTER TABLE artists 
ADD COLUMN last_name text,
ADD COLUMN title_name text,
ADD COLUMN first_name text,
ADD COLUMN second_name text;

-- Foreign Key constraint
ALTER TABLE people.location ADD CONSTRAINT person_fk  
FOREIGN KEY (person_id) REFERENCES people.person(id)
ON DELETE SET NULL;

-- Modify data in our person table
UPDATE people.person SET car_id = 3 WHERE id = 1;

-- Delete observations
DELETE FROM people.person WHERE id > 5; 

-- Delete column from artworks:
ALTER TABLE artworks DROP COLUMN artist;



-- Join
-- Joining two tables 
SELECT first_name, last_name, country, city, car_make, car_model FROM people.person pp
INNER JOIN people.location pl ON pl.person_id = pp.id
INNER JOIN people.car pc ON pc.id = pp.car_id;

-- Left join
SELECT first_name, last_name, car_make FROM people.person pp
LEFT JOIN people.car pc ON pc.id = pp.car_id;
-- RIGHT join
SELECT first_name, last_name, country FROM people.person pp
RIGHT JOIN people.location pl ON pl.person_id = pp.id;
-- FULL (OUTER)
SELECT first_name, last_name, country FROM people.person pp
FULL OUTER JOIN people.location pl ON pl.person_id = pp.id;

-- cross join tables:
SELECT num, let FROM people.numbers
CROSS JOIN people.letters

-- EXPORT 
COPY (SELECT * FROM people.letters CROSS JOIN people.numbers)
TO '/tmp/cross_join.csv' DELIMITER ',' CSV HEADER; -- remember to insert the path to a folder that PgAmin can access!



-- Split big table into several small table
-- To handle problems with null values
UPDATE artworks
SET creditline = 'Not known'
WHERE
	creditline IS NULL;

UPDATE artworks
SET acquisitionyear = 9999
WHERE
	acquisitionyear IS NULL;

-- Create a new table for credit
CREATE TABLE credit AS SELECT DISTINCT creditline, acquisitionyear FROM artworks;
ALTER TABLE credit ADD COLUMN credit_id serial;

-- Create a credit_id column in artworks and pass values:
ALTER TABLE artworks ADD COLUMN credit_id int;

UPDATE artworks 
SET credit_id = credit.credit_id
FROM credit
WHERE artworks.creditline = credit.creditline AND artworks.acquisitionyear = credit.acquisitionyear;

ALTER TABLE artworks 
DROP COLUMN creditline,
DROP COLUMN acquisitionyear;