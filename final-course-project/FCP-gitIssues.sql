----
--- 1. Setting

-- 1.1 Create database called smm695 for the final course project
CREATE DATABASE smm695;


-- 1.2 Create schema called FCP standing for final course project
CREATE SCHEMA FCP;


-- 1.3 Create table called gitIssues for importing the data of gitIssues
CREATE TABLE FCP.gitIssues (
    id bigserial,
    title TEXT,
	state TEXT,
	body TEXT,
	"user" TEXT,
	user_id TEXT,
	repository TEXT,
	created_at timestamp with time zone,
	updated_at timestamp with time zone,
	closed_at timestamp with time zone,
	assignees TEXT,
	labels TEXT,
	reactions TEXT,
	n_comments NUMERIC,
	closed_by TEXT,
	comment_id TEXT,
	comment_created_at timestamp with time zone,
	comment_updated_at timestamp with time zone,
	comment_user_id TEXT,
	comment_user TEXT,
	comment_text TEXT,
	project TEXT
);


-- 1.4 Import data of gitIssues
COPY FCP.gitIssues (id, title, state, body, "user", user_id, repository, created_at, updated_at, closed_at, assignees, labels, reactions, n_comments, closed_by, comment_id, comment_created_at, comment_updated_at, comment_user_id, comment_user, comment_text, project)
FROM 'C:/Program Files/PostgreSQL/14/data/Data/gitIssues.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';



----
--- 2. Perform data validation and reconciliation

-- 2.1 Make sure all data is imported
-- The number of data should be 32329
SELECT COUNT(*) FROM FCP.gitIssues;


-- 2.2 We notice that there are duplicate value in column id
-- Examine the data, then we obtain there are 1510 duplicate id, where they occur exactly twice
-- The remaining 29309 ids are unique
WITH id_count AS (SELECT id, COUNT(id) AS id_ct FROM FCP.gitIssues GROUP BY id ORDER BY id ASC)
SELECT COUNT(id_ct) FROM id_count WHERE id_ct = 2;

WITH id_count AS (SELECT id, COUNT(id) AS id_ct FROM FCP.gitIssues GROUP BY id ORDER BY id ASC)
SELECT COUNT(id_ct) FROM id_count WHERE id_ct = 1;


-- 2.3 Examine column state are all 'closed' as introduced in the data description
SELECT DISTINCT state FROM FCP.gitIssues;


-- 2.4 Check the content of column repository
-- We found that it is null for all data
SELECT DISTINCT repository FROM FCP.gitIssues;


-- 2.5 Examine column created_at are all no later than their corresponding column updated_at
SELECT COUNT(*) FROM FCP.gitIssues WHERE created_at > updated_at;


-- 2.6 Examine column created_at are all no later than their corresponding column closed_at
SELECT COUNT(*) FROM FCP.gitIssues WHERE created_at > closed_at;


-- 2.7 Check how many assignees are in the column assignees -----!! could be deleted !!-----
-- It shows that there are at most 4 assignees in each issue
WITH assignees_length AS
(SELECT assignees, split_part(assignees::TEXT,',',4) AS element
FROM FCP.gitIssues WHERE NOT assignees = '[]')
SELECT element FROM assignees_length WHERE NOT element = '';

WITH assignees_length AS
(SELECT assignees, split_part(assignees::TEXT,',',5) AS element
FROM FCP.gitIssues WHERE NOT assignees = '[]')
SELECT element FROM assignees_length WHERE NOT element = '';


-- 2.8 Examine column reactions are all in the following contents
-- +1, -1, laugh, confused, heart, hooray, rocket, eyes
UPDATE FCP.gitIssues
SET reactions = REPLACE(REPLACE(reactions,'[','{'),']','}');

ALTER TABLE FCP.gitIssues ALTER COLUMN reactions SET DATA TYPE TEXT[] USING reactions::TEXT[];

WITH reaction_split AS
(SELECT UNNEST(reactions) AS reaction FROM FCP.gitIssues)
SELECT reaction, COUNT(*) FROM reaction_split GROUP BY reaction;


-- 2.9 Examine column comment_created_at are all no later than their corresponding column comment_updated_at
SELECT COUNT(*) FROM FCP.gitIssues WHERE comment_created_at > comment_updated_at;



----
--- 3. Split original data into small small table

-- 3.1 Create table issue
CREATE TABLE FCP.issue AS SELECT DISTINCT title, state, body, repository, n_comments FROM FCP.gitIssues ORDER BY title ASC;

-- Add issue_id for identification of each issue
ALTER TABLE FCP.issue ADD COLUMN issue_id serial;

-- Link issue_id back to the original data
ALTER TABLE FCP.gitIssues ADD COLUMN issue_id int;

UPDATE FCP.gitIssues
SET issue_id = FCP.issue.issue_id FROM FCP.issue
WHERE FCP.gitIssues.title = FCP.issue.title;

-- Drop the information in the original data that can be retrieve from table issue
ALTER TABLE FCP.gitIssues
DROP COLUMN title,
DROP COLUMN state,
DROP COLUMN body,
DROP COLUMN repository,
DROP COLUMN n_comments;


-- 3.2 Create table user
CREATE TABLE FCP.user AS SELECT DISTINCT user_id, "user" FROM FCP.gitIssues ORDER BY user_id ASC;

-- Drop the information in the original data that can be retrieve from table user
ALTER TABLE FCP.gitIssues DROP COLUMN "user";


-- 3.3 Create table date
CREATE TABLE FCP.date AS SELECT DISTINCT created_at, updated_at, closed_at FROM FCP.gitIssues ORDER BY created_at ASC;

-- Add issue_id for identification of each date set
ALTER TABLE FCP.date ADD COLUMN date_id serial;

-- Link date_id back to the original data
ALTER TABLE FCP.gitIssues ADD COLUMN date_id int;

UPDATE FCP.gitIssues
SET date_id = FCP.date.date_id FROM FCP.date
WHERE FCP.date.created_at = FCP.gitIssues.created_at
AND FCP.date.updated_at = FCP.gitIssues.updated_at
AND FCP.date.closed_at = FCP.gitIssues.closed_at;

-- Drop the information in the original data that can be retrieve from table date
ALTER TABLE FCP.gitIssues
DROP COLUMN created_at,
DROP COLUMN updated_at,
DROP COLUMN closed_at;


-- 3.4 Create table assignee
-- Replace [] by {} to allow the data type to be array
UPDATE FCP.gitIssues
SET assignees = REPLACE(REPLACE(assignees,'[','{'),']','}');

ALTER TABLE FCP.gitIssues ALTER COLUMN assignees SET DATA TYPE TEXT[] USING assignees::TEXT[];

-- Create an unnested table for assignees
CREATE TABLE FCP.assignee AS
(SELECT issue_id, UNNEST(assignees) AS assignee FROM FCP.gitIssues
GROUP BY issue_id, assignee);

-----!! to be completed !!-----


-- 3.5 Create table label


-- 3.6 Create table reaction


-- 3.7 Create table closeduser
CREATE TABLE FCP.closeduser AS SELECT DISTINCT closed_by FROM FCP.gitIssues ORDER BY closed_by ASC;

-- Add closeduser_id for identification of each closed user
ALTER TABLE FCP.closeduser ADD COLUMN closeduser_id serial;

-- Link closeduser_id back to the original data
ALTER TABLE FCP.gitIssues ADD COLUMN closeduser_id int;

UPDATE FCP.gitIssues
SET closeduser_id = FCP.closeduser.closeduser_id FROM FCP.closeduser
WHERE FCP.gitIssues.closed_by = FCP.closeduser.closed_by;

-- Drop the information in the original data that can be retrieve from table closeduser
ALTER TABLE FCP.gitIssues DROP COLUMN closed_by;


-- 3.8 Create table comment
CREATE TABLE FCP.comment AS SELECT DISTINCT comment_id, comment_created_at, comment_updated_at, comment_user_id, comment_user, comment_text FROM FCP.gitIssues ORDER BY comment_id ASC;

-- Drop the information in the original data that can be retrieve from table comment
ALTER TABLE FCP.gitIssues
DROP COLUMN comment_created_at,
DROP COLUMN comment_updated_at,
DROP COLUMN comment_user_id,
DROP COLUMN comment_user,
DROP COLUMN comment_text;


-- 3.9 Create table project
CREATE TABLE FCP.project AS SELECT DISTINCT project FROM FCP.gitIssues ORDER BY project ASC;

-- Add project_id for identification of each project
ALTER TABLE FCP.project ADD COLUMN project_id serial;

-- Link project_id back to the original data
ALTER TABLE FCP.gitIssues ADD COLUMN project_id int;

UPDATE FCP.gitIssues
SET project_id = FCP.project.project_id FROM FCP.project
WHERE FCP.gitIssues.project = FCP.project.project;

-- Drop the information in the original data that can be retrieve from table project
ALTER TABLE FCP.gitIssues DROP COLUMN project;











-- Original SQL for assignees
CREATE TABLE FCP.assignees AS
(SELECT DISTINCT title,
 	split_part(assignees::TEXT,',',1) AS assignee_1,
 	split_part(assignees::TEXT,',',2) AS assignee_2,
 	split_part(assignees::TEXT,',',3) AS assignee_3,
 	split_part(assignees::TEXT,',',4) AS assignee_4
 FROM FCP.gitIssues);

UPDATE FCP.assignees
SET assignee_1 = REPLACE(REPLACE(assignee_1,'[',''),']',''),
	assignee_2 = REPLACE(REPLACE(assignee_2,'[',''),']',''),
	assignee_3 = REPLACE(REPLACE(assignee_3,'[',''),']',''),
	assignee_4 = REPLACE(REPLACE(assignee_4,'[',''),']','');

UPDATE FCP.assignees
SET assignee_1 = SUBSTRING(assignee_1, 2, LENGTH(assignee_1) - 2)
WHERE NOT assignee_1 = '';

UPDATE FCP.assignees
SET assignee_2 = SUBSTRING(assignee_2, 3, LENGTH(assignee_2) - 3)
WHERE NOT assignee_2 = '';

UPDATE FCP.assignees
SET assignee_3 = SUBSTRING(assignee_3, 3, LENGTH(assignee_3) - 3)
WHERE NOT assignee_3 = '';

UPDATE FCP.assignees
SET assignee_4 = SUBSTRING(assignee_4, 3, LENGTH(assignee_4) - 3)
WHERE NOT assignee_4 = '';

