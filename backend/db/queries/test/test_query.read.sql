SELECT companies.name, jobs.*
FROM jobs
LEFT JOIN companies
ON jobs.company_id = companies.id
LIMIT 5;
