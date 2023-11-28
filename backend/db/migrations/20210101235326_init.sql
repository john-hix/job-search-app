-- migrate:up

CREATE TABLE companies (
  id SERIAL PRIMARY KEY,
  name VARCHAR,
  website VARCHAR,
  glassdoor VARCHAR,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE statuses (
  id SERIAL PRIMARY KEY,
  title VARCHAR NOT NULL,
  icon VARCHAR,
  chronology INTEGER NOT NULL, -- lower number => earlier in process
  show_in_kanban BOOLEAN NOT NULL DEFAULT TRUE
);

-- Default statuses 
INSERT INTO statuses (id, chronology, title, icon)
  VALUES (1, 1, 'To Apply', 'binoculars');
INSERT INTO statuses (id, chronology, title, icon)
  VALUES (2, 2, 'Applied', 'file-earmark-check');
INSERT INTO statuses (id, chronology, title, icon) 
  VALUES (3, 3, 'Phone screen', 'telephone');
INSERT INTO statuses (id, chronology, title, icon) 
  VALUES (4, 4, 'Interview', 'briefcase');
INSERT INTO statuses (id, chronology, title, icon) 
  VALUES (5, 5, 'Offer', 'hand-thumbs-up');
INSERT INTO statuses (id, chronology, title, icon) 
  VALUES (6, 6, 'Accepted offer', 'bookmark-check');
INSERT INTO statuses (id, chronology, title, icon) 
  VALUES (7, 7, 'Declined offer', 'hand-thumbs-down');
INSERT INTO statuses (id, chronology, title, icon) 
  VALUES (8, 8, 'Rejected', 'x-circle');
INSERT INTO statuses (id, chronology, title, icon) 
  VALUES (9, 0, 'Imported', 'download');

CREATE TABLE jobs (
  id SERIAL PRIMARY KEY,
  company_id INTEGER REFERENCES companies(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  status_id INTEGER REFERENCES statuses(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE jobs_details (
  job_id INTEGER PRIMARY KEY REFERENCES jobs(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  title VARCHAR,
  source VARCHAR,
  location VARCHAR,
  full_time BOOLEAN,
  intern BOOLEAN,
  work_remote BOOLEAN,
  temp_remote BOOLEAN, -- Everyone's fav virus
  start_at DATE,
  end_at DATE,
  app_deadline DATE,
  app_url VARCHAR,
  compensation_posted VARCHAR,
  internal_reference VARCHAR, -- The company's internal reference #
  posting_url VARCHAR,
  posting_text TEXT -- html
);

CREATE TABLE jobs_notes (
  id SERIAL PRIMARY KEY,
  job_id INTEGER REFERENCES jobs(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  text TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE jobs_applications (
  id SERIAL PRIMARY KEY,
  job_id INTEGER REFERENCES jobs(id) ON UPDATE CASCADE ON DELETE CASCADE,
  application_url VARCHAR,
  submitted_at TIMESTAMP WITH TIME ZONE,
  compensation_ask VARCHAR,
  start_date_given DATE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE jobs_offers (
  id SERIAL PRIMARY KEY,
  job_id INTEGER REFERENCES jobs(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  accepted BOOLEAN,
  accept_deadline TIMESTAMP WITH TIME ZONE,
  start_work TIMESTAMP WITH TIME ZONE,
  compensation VARCHAR,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE task_templates (
  id SERIAL PRIMARY KEY,
  description VARCHAR,
  default_days_to_due INTEGER,
  needed_until_after_status INTEGER REFERENCES statuses(id)
    ON UPDATE CASCADE,
  order_in_status INTEGER DEFAULT 0
);


CREATE TABLE tasks (
  id SERIAL PRIMARY KEY,
  job_id INTEGER REFERENCES jobs(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  from_template INTEGER REFERENCES task_templates(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  description VARCHAR,
  due_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- Task templates
INSERT INTO task_templates (id, description, default_days_to_due, needed_until_after_status, order_in_status)
  VALUES (1, 'Glassdoor reviews!', 0, 1, 0);
INSERT INTO task_templates (id, description, default_days_to_due, needed_until_after_status, order_in_status)
  VALUES (2, 'Prep cover letter', 0, 1, 10);
INSERT INTO task_templates (id, description, default_days_to_due, needed_until_after_status, order_in_status)
  VALUES (3, 'Tailor resume', 0, 1, 20);
INSERT INTO task_templates (id, description, default_days_to_due, needed_until_after_status, order_in_status)
  VALUES (4, 'Get reference', 0, 1, 30);
INSERT INTO task_templates (id, description, default_days_to_due, needed_until_after_status, order_in_status)
  VALUES (5, 'Apply', 0, 1, 40);
INSERT INTO task_templates (id, description, default_days_to_due, needed_until_after_status, order_in_status)
  VALUES (6, 'Follow up', 14, 2, 0);
INSERT INTO task_templates (id, description, default_days_to_due, needed_until_after_status, order_in_status)
  VALUES (7, 'Prep for interview', 2, 3, 0);
INSERT INTO task_templates (id, description, needed_until_after_status, order_in_status)
  VALUES (8, 'Phone screen', 3, 10);
INSERT INTO task_templates (id, description, needed_until_after_status)
  VALUES (9, 'On-site interview', 4);
INSERT INTO task_templates (id, description, default_days_to_due, needed_until_after_status)
  VALUES (10, 'Post-interview thank-you email', 0, 4);
INSERT INTO task_templates (id, description,default_days_to_due, needed_until_after_status)
  VALUES (11, 'Mail post-interview thank-you note', 0, 4);
INSERT INTO task_templates (id, description, needed_until_after_status)
  VALUES (12, 'Negotiate offer', 6);
INSERT INTO task_templates (id, description, needed_until_after_status)
  VALUES (13, 'Decline offer', 7);
INSERT INTO task_templates (id, description, needed_until_after_status)
  VALUES (14, 'Thank-you email', 8);

-- To assign tasks which should be added to a job when the jobs are assigned
-- particular statuses. See auto_add_tasks_on_status_change_update and 
-- auto_add_tasks_on_status_change_insert TRIGGERs

CREATE TABLE auto_add_tasks (
  id SERIAL PRIMARY KEY,
  on_status_change_to INTEGER NOT NULL REFERENCES statuses(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  task_template INTEGER REFERENCES task_templates(id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- ***Add tasks automatically when a job posting is assigned a status***
-- Look at the company's Glassdoor
INSERT INTO auto_add_tasks (on_status_change_to, task_template) VALUES (1, 1);
-- Tell them to actually apply!
INSERT INTO auto_add_tasks (on_status_change_to, task_template) VALUES (1, 5);
-- Thank-you emails/notes after phone and in-person interviews
INSERT INTO auto_add_tasks (on_status_change_to, task_template) VALUES (3, 10);
INSERT INTO auto_add_tasks (on_status_change_to, task_template) VALUES (4, 10);
INSERT INTO auto_add_tasks (on_status_change_to, task_template) VALUES (4, 11);


-- People! Professional contacts, references, people at companies, interviewers, etc.
CREATE TABLE contacts (
  id SERIAL PRIMARY KEY,
  designation VARCHAR,
  f_name VARCHAR,
  l_name VARCHAR,
  job_title VARCHAR,
  notes TEXT,
  is_linkedin_connection BOOLEAN NOT NULL DEFAULT FALSE,
  linkedin_acct VARCHAR,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE contacts_phones (
  id SERIAL PRIMARY KEY,
  contact_id INTEGER REFERENCES contacts(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  phone_number VARCHAR,
  phone_type VARCHAR,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE contacts_emails (
  id SERIAL PRIMARY KEY,
  contact_id INTEGER REFERENCES contacts(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  email VARCHAR,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- People involved in the hiring process
CREATE TABLE jobs_to_hiring_contacts (
  id SERIAL PRIMARY KEY,
  contact_id INTEGER REFERENCES contacts(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  company_id INTEGER REFERENCES companies(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  "role" VARCHAR -- e.g. recruiter, technical interviewer, admin. assistant, etc.
);

-- Record of job references
CREATE TABLE jobs_to_reference_contacts (
  id SERIAL PRIMARY KEY,
  contact_id INTEGER REFERENCES contacts(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  job_id INTEGER REFERENCES jobs(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  notes TEXT
);

-- Track interviews for jobs
CREATE TABLE interviews (
  id SERIAL PRIMARY KEY,
  job_id INTEGER REFERENCES jobs(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  notes TEXT,
  interviewed_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT (now()),
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- Refer to contacts who were present at interviews
CREATE TABLE interviews_to_contacts (
  contact_id INTEGER REFERENCES contacts(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  interview_id INTEGER REFERENCES interviews(id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- Create a dashboard
CREATE VIEW jobs_list_main AS
SELECT
  jobs.id AS "Job id",
  statuses.title AS "STATUS",
  MAX(jobs_applications.submitted_at) AS "Last application",
  jobs_details.title AS "Title",
  companies.name AS "Company",
  COUNT(interviews.id) AS "# of interviews"
FROM
  jobs_details
  INNER JOIN jobs ON jobs.id = jobs_details.job_id
  INNER JOIN companies ON jobs.company_id = companies.id
  LEFT JOIN statuses ON jobs.status_id = statuses.id
  LEFT JOIN interviews ON interviews.job_id = jobs_details.job_id
  LEFT JOIN jobs_applications ON jobs_applications.job_id = jobs_details.job_id
WHERE
  jobs.deleted_at IS NULL
GROUP BY
  jobs.id,
  jobs_details.title,
  companies.name,
  statuses.title
ORDER BY
  jobs.updated_at DESC;

CREATE VIEW task_list
AS
SELECT tasks.id AS "Task ID", tasks.job_id,
  tasks.description AS "Task",
  tasks.due_at AS "Due date",
  statuses.title AS "Job status",
  jobs_details.title AS "Job title",
  companies.name AS "Company",
  jobs_details.app_url AS "Application link",
  jobs_details.posting_url AS "Post link",
  tasks.created_at AS "Task created at",
  tasks.updated_at AS "Task updated at"
FROM tasks
LEFT JOIN jobs
ON tasks.job_id = jobs.id
LEFT JOIN jobs_details
ON tasks.job_id = jobs_details.job_id
LEFT JOIN statuses
ON jobs.status_id = statuses.id
LEFT JOIN companies
ON jobs.company_id = companies.id
WHERE tasks.completed_at IS NULL
  AND tasks.deleted_at IS NULL
ORDER BY due_at;

-- migrate:down
DROP VIEW IF EXISTS jobs_list_main;
DROP TABLE IF EXISTS interviews_to_contacts;
DROP TABLE IF EXISTS interviews;
DROP TABLE IF EXISTS jobs_to_reference_contacts;
DROP TABLE IF EXISTS jobs_to_hiring_contacts;
DROP TABLE IF EXISTS contacts_emails;
DROP TABLE IF EXISTS contacts_phones;
DROP TABLE IF EXISTS contacts;
DROP TABLE IF EXISTS auto_add_tasks;
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS task_templates;
DROP TABLE IF EXISTS jobs_offers;
DROP TABLE IF EXISTS jobs_applications;
DROP TABLE IF EXISTS jobs_notes;
DROP TABLE IF EXISTS jobs_details;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS statuses;
DROP TABLE IF EXISTS companies;
