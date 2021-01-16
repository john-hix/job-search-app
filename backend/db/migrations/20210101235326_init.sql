-- migrate:up
PRAGMA foreign_keys = ON;

CREATE TABLE companies (
  id INTEGER PRIMARY KEY ,
  name VARCHAR(128),
  website VARCHAR(128),
  glassdoor VARCHAR(256),
  created_at DATETIME DEFAULT (datetime('now','utc')),
  updated_at DATETIME DEFAULT (datetime('now','utc')),
  deleted_at DATETIME
);

CREATE TABLE statuses (
  id INTEGER PRIMARY KEY ,
  title VARCHAR(64) NOT NULL,
  icon VARCHAR(16),
  chronology INTEGER NOT NULL, -- lower number => earlier in process
  show_in_kanban BOOLEAN NOT NULL CHECK (show_in_kanban IN (1,0)) DEFAULT 1
);

-- Default statuses 
INSERT INTO statuses (id, chronology, title, icon) VALUES (1, 1, 'To Apply', 'binoculars');
INSERT INTO statuses (id, chronology, title, icon) VALUES (2, 2, 'Applied', 'file-earmark-check');
INSERT INTO statuses (id, chronology, title, icon) VALUES (3, 3, 'Phone screen', 'telephone');
INSERT INTO statuses (id, chronology, title, icon) VALUES (4, 4, 'Interview', 'briefcase');
INSERT INTO statuses (id, chronology, title, icon) VALUES (5, 5, 'Offer', 'hand-thumbs-up');
INSERT INTO statuses (id, chronology, title, icon) VALUES (6, 6, 'Accepted offer', 'bookmark-check');
INSERT INTO statuses (id, chronology, title, icon) VALUES (7, 7, 'Declined offer', 'hand-thumbs-down');
INSERT INTO statuses (id, chronology, title, icon) VALUES (8, 8, 'Rejected', 'x-circle');
INSERT INTO statuses (id, chronology, title, icon) VALUES (9, 0, 'Imported', 'download');


CREATE TABLE jobs (
  id INTEGER PRIMARY KEY ,
  company_id INTEGER,
  status_id INTEGER,
  created_at DATETIME DEFAULT (datetime('now','utc')),
  updated_at DATETIME DEFAULT (datetime('now','utc')),
  deleted_at DATETIME,
  FOREIGN KEY(company_id) REFERENCES companies(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY(status_id) REFERENCES statuses(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE jobs_details (
  job_id INTEGER UNIQUE NOT NULL,
  title VARCHAR(128),
  source VARCHAR(16),
  location VARCHAR(64),
  full_time BOOLEAN     CHECK (full_time IN (1,0)),
  intern BOOLEAN        CHECK (intern IN (1,0)),
  work_remote BOOLEAN   CHECK (work_remote IN (1,0)),
  temp_remote BOOLEAN   CHECK (temp_remote IN (1,0)), -- Everyone's fav virus
  start_at DATE,
  end_at DATE,
  app_deadline DATE,
  app_url VARCHAR(256),
  compensation_posted VARCHAR(32),
  internal_reference VARCHAR(32), -- The company's internal reference #
  posting_url VARCHAR(256),
  posting_text TEXT, -- html
  FOREIGN KEY(job_id) REFERENCES jobs(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE jobs_notes (
  id INTEGER PRIMARY KEY ,
  job_id INTEGER NOT NULL,
  text TEXT,
  created_at DATETIME DEFAULT (datetime('now','utc')),
  updated_at DATETIME DEFAULT (datetime('now','utc')),
  deleted_at DATETIME,
  FOREIGN KEY(job_id) REFERENCES jobs(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE jobs_applications (
  id INTEGER PRIMARY KEY,
  job_id INTEGER NOT NULL,
  application_url VARCHAR(256),
  submitted_at DATETIME,
  compensation_ask VARCHAR(32),
  start_date_given DATE,
  notes TEXT,
  created_at DATETIME DEFAULT (datetime('now','utc')),
  updated_at DATETIME DEFAULT (datetime('now','utc')),
  deleted_at DATETIME,
  FOREIGN KEY(job_id) REFERENCES jobs(id) ON UPDATE CASCADE ON DELETE CASCADE 
);

CREATE TABLE jobs_offers (
  id INTEGER PRIMARY KEY,
  job_id INTEGER NOT NULL,
  accepted BOOLEAN     CHECK (accepted IN (1,0)),
  accept_deadline DATETIME,
  start_work DATETIME,
  compensation VARCHAR(64),
  notes TEXT,
  created_at DATETIME DEFAULT (datetime('now','utc')),
  updated_at DATETIME DEFAULT (datetime('now','utc')),
  deleted_at DATETIME,
  FOREIGN KEY(job_id) REFERENCES jobs(id) ON UPDATE CASCADE ON DELETE CASCADE 
);

CREATE TABLE tasks (
  id INTEGER PRIMARY KEY ,
  job_id INTEGER NOT NULL,
  from_template INTEGER,
  description VARCHAR(64),
  due_at DATETIME,
  completed_at DATETIME,
  created_at DATETIME DEFAULT (datetime('now','utc')),
  updated_at DATETIME DEFAULT (datetime('now','utc')),
  deleted_at DATETIME,
  FOREIGN KEY(job_id) REFERENCES jobs(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY(from_template) REFERENCES task_templates(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE task_templates (
  id INTEGER PRIMARY KEY ,
  description VARCHAR(64),
  default_days_to_due INTEGER,
  needed_until_after_status INTEGER, -- See auto_add_tasks TABLE.
  order_in_status INTEGER DEFAULT 0,
  -- Note you could get a constraint failure if deleting, which forces intentionality
  -- when doing a DELETE that would affect the auto-task-add functionality.
  -- See auto_add_tasks TABLE.
  FOREIGN KEY(needed_until_after_status) REFERENCES statuses(id) ON UPDATE CASCADE
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
  id INTEGER PRIMARY KEY ,
  on_status_change_to INTEGER,  -- job is changed *to* this status
  task_template INTEGER, -- add a task to the job from this template
  FOREIGN KEY(task_template) REFERENCES task_templates(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY(on_status_change_to) REFERENCES statuses(id) ON UPDATE CASCADE ON DELETE CASCADE
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

-- No stored procedures in SQLite, so just copy the code for both update and creation events
CREATE TRIGGER auto_add_tasks_on_status_change_update AFTER UPDATE OF status_id ON jobs
    BEGIN
        INSERT INTO tasks (job_id, from_template, description, due_at)
            SELECT NEW.id AS jobId, tt.id AS templateId, tt.description,
                -- null default_days_to_due results in null due date, as desired
                DATETIME('now', '+' || CAST(tt.default_days_to_due AS TEXT)
                    || ' days', 'utc') AS dueDate
                FROM task_templates AS tt
                INNER JOIN auto_add_tasks AS aadd
                    ON aadd.task_template = tt.id
                WHERE NEW.status_id = aadd.on_status_change_to
                -- Keep from piling up autoadded tasks if user switches
                -- back and forth between statuses
                AND tt.id NOT IN (SELECT tasks.from_template
                                  FROM tasks
                                  WHERE tasks.job_id = NEW.id)
            ;
    END
;

-- Same procedure, but for insert
CREATE TRIGGER auto_add_tasks_on_status_change_insert AFTER INSERT ON jobs
    BEGIN
        -- If status_id is not null, insert appropriate tasks
        INSERT INTO tasks (job_id, from_template, description, due_at)
            SELECT NEW.id AS jobId, tt.id AS templateId, tt.description,
                -- null default_days_to_due results in null due date, as desired
                DATETIME('now', '+' || CAST(tt.default_days_to_due AS TEXT)
                    || ' days', 'utc') AS dueDate
                FROM task_templates AS tt
                INNER JOIN auto_add_tasks AS aadd
                    ON aadd.task_template = tt.id
                WHERE NEW.status_id = aadd.on_status_change_to
                AND NEW.status_id NOT NULL
                -- No need to check if this job already has auto tasks added,
                -- as with the UPDATE trigger, because this is a new job.
            ;
    END
;

-- People! Professional contacts, references, people at companies, interviewers, etc.
CREATE TABLE contacts (
  id INTEGER PRIMARY KEY,
  -- Yes, a naive name schema, esp if validated hard.
  -- https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/
  designation VARCHAR(8),
  f_name VARCHAR(64),
  l_name VARCHAR(64),
  job_title VARCHAR(32),
  notes TEXT,
  is_linkedin_connection BOOLEAN NOT NULL CHECK (is_linkedin_connection IN (1,0)) DEFAULT 0,
  linkedin_acct VARCHAR(32),
  created_at DATETIME DEFAULT (datetime('now','utc')),
  updated_at DATETIME DEFAULT (datetime('now','utc')),
  deleted_at DATETIME
);

CREATE TABLE contacts_phones (
  id INTEGER PRIMARY KEY,
  contact_id INTEGER NOT NULL,
  phone_number VARCHAR(12),
  phone_type VARCHAR(8),
  created_at DATETIME DEFAULT (datetime('now','utc')),
  updated_at DATETIME DEFAULT (datetime('now','utc')),
  deleted_at DATETIME,
  FOREIGN KEY(contact_id) REFERENCES contacts(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE contacts_emails (
  id INTEGER PRIMARY KEY,
  contact_id INTEGER NOT NULL,
  email VARCHAR(256),
  created_at DATETIME DEFAULT (datetime('now','utc')),
  updated_at DATETIME DEFAULT (datetime('now','utc')),
  deleted_at DATETIME,
  FOREIGN KEY(contact_id) REFERENCES contacts(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- People involved in the hiring process
CREATE TABLE jobs_to_hiring_contacts (
  id INTEGER PRIMARY KEY,
  contact_id INTEGER NOT NULL,
  company_id INTEGER NOT NULL,
  role VARCHAR(64), -- e.g. recruiter, technical interviewer, admin. assistant, etc.
  FOREIGN KEY(contact_id) REFERENCES contacts(id) ON UPDATE CASCADE ON DELETE CASCADE
  FOREIGN KEY(company_id) REFERENCES companies(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Record of job references
CREATE TABLE jobs_to_reference_contacts (
  id INTEGER PRIMARY KEY,
  contact_id INTEGER NOT NULL,
  job_id INTEGER NOT NULL,
  notes TEXT,
  FOREIGN KEY(contact_id) REFERENCES contacts(id) ON UPDATE CASCADE ON DELETE CASCADE
  FOREIGN KEY(job_id) REFERENCES jobs(id) ON UPDATE CASCADE ON DELETE SET NULL
);

-- Track interviews for jobs
CREATE TABLE interviews (
  id INTEGER PRIMARY KEY,
  job_id INTEGER NOT NULL,
  notes TEXT,
  interviewed_at DATETIME DEFAULT (datetime('now','utc')),
  created_at DATETIME DEFAULT (datetime('now','utc')),
  updated_at DATETIME DEFAULT (datetime('now','utc')),
  deleted_at DATETIME,
  FOREIGN KEY(job_id) REFERENCES jobs(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Refer to contacts who were present at interviews
CREATE TABLE interviews_to_contacts (
  contact_id INTEGER,
  interview_id INTEGER,
  FOREIGN KEY(contact_id) REFERENCES contacts(id) ON UPDATE CASCADE ON DELETE CASCADE
  FOREIGN KEY(interview_id) REFERENCES interviews(id) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Create a dashboard
CREATE VIEW jobs_list_main
AS
SELECT jobs.id AS "Job id", statuses.title AS "STATUS",
  MAX(jobs_applications.submitted_at) AS "Last application",
  jobs_details.title AS "Title", companies.name AS "Company",
  COUNT(interviews.id) AS "# of interviews",
  * -- Everything from all tables. Eh.
  FROM jobs_details
  INNER JOIN jobs ON jobs.id = jobs_details.job_id
  INNER JOIN companies ON jobs.company_id = companies.id
  LEFT JOIN statuses ON jobs.status_id = statuses.id
  LEFT JOIN interviews ON interviews.job_id = jobs_details.job_id
  LEFT JOIN jobs_applications ON jobs_applications.job_id = jobs_details.job_id
  WHERE jobs.deleted_at IS NULL
  GROUP BY jobs_details.job_id
  ORDER BY jobs.updated_at DESC
;

-- migrate:down
DROP VIEW IF EXISTS jobs_list_main;
DROP TRIGGER IF EXISTS auto_add_tasks_on_status_change_update;
DROP TRIGGER IF EXISTS auto_add_tasks_on_status_change_insert;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS statuses;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS jobs_details;
DROP TABLE IF EXISTS jobs_notes;
DROP TABLE IF EXISTS jobs_applications;
DROP TABLE IF EXISTS jobs_offers;
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS task_templates;
DROP TABLE IF EXISTS auto_add_tasks;
DROP TABLE IF EXISTS contacts;
DROP TABLE IF EXISTS contacts_phones;
DROP TABLE IF EXISTS contacts_emails;
DROP TABLE IF EXISTS jobs_to_hiring_contacts;
DROP TABLE IF EXISTS jobs_to_reference_contacts;
DROP TABLE IF EXISTS interviews;
DROP TABLE IF EXISTS interviews_to_contacts;
