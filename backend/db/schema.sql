CREATE TABLE IF NOT EXISTS "schema_migrations" (version varchar(255) primary key);
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
CREATE TABLE auto_add_tasks (
  id INTEGER PRIMARY KEY ,
  on_status_change_to INTEGER,  -- job is changed *to* this status
  task_template INTEGER, -- add a task to the job from this template
  FOREIGN KEY(task_template) REFERENCES task_templates(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY(on_status_change_to) REFERENCES statuses(id) ON UPDATE CASCADE ON DELETE CASCADE
);
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
    END;
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
    END;
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
CREATE TABLE jobs_to_hiring_contacts (
  id INTEGER PRIMARY KEY,
  contact_id INTEGER NOT NULL,
  company_id INTEGER NOT NULL,
  role VARCHAR(64), -- e.g. recruiter, technical interviewer, admin. assistant, etc.
  FOREIGN KEY(contact_id) REFERENCES contacts(id) ON UPDATE CASCADE ON DELETE CASCADE
  FOREIGN KEY(company_id) REFERENCES companies(id) ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE jobs_to_reference_contacts (
  id INTEGER PRIMARY KEY,
  contact_id INTEGER NOT NULL,
  job_id INTEGER NOT NULL,
  notes TEXT,
  FOREIGN KEY(contact_id) REFERENCES contacts(id) ON UPDATE CASCADE ON DELETE CASCADE
  FOREIGN KEY(job_id) REFERENCES jobs(id) ON UPDATE CASCADE ON DELETE SET NULL
);
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
CREATE TABLE interviews_to_contacts (
  contact_id INTEGER,
  interview_id INTEGER,
  FOREIGN KEY(contact_id) REFERENCES contacts(id) ON UPDATE CASCADE ON DELETE CASCADE
  FOREIGN KEY(interview_id) REFERENCES interviews(id) ON UPDATE CASCADE ON DELETE CASCADE
);
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
/* jobs_list_main("Job id",STATUS,"Last application",Title,Company,"# of interviews",job_id,"title:1",source,location,full_time,intern,work_remote,temp_remote,start_at,end_at,app_deadline,app_url,compensation_posted,internal_reference,posting_url,posting_text,id,company_id,status_id,created_at,updated_at,deleted_at,"id:1",name,website,glassdoor,"created_at:1","updated_at:1","deleted_at:1","id:2","title:2",icon,chronology,show_in_kanban,"id:3","job_id:1",notes,interviewed_at,"created_at:2","updated_at:2","deleted_at:2","id:4","job_id:2",application_url,submitted_at,compensation_ask,start_date_given,"notes:1","created_at:3","updated_at:3","deleted_at:3") */;
-- Dbmate schema migrations
INSERT INTO "schema_migrations" (version) VALUES
  ('20210101235326');
