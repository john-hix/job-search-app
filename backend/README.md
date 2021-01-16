# Job search management
This project can use [dbmate](https://github.com/amacneil/dbmate) to
manage schema migrations.

# Getting started
```
cp .env.example .env
mkdir data
touch data/jobs.sqlite3
# If you want batteries-included installation
dbmate up # using migrations
# if you want only the schema, no statuses, task templates, registered
# auto-added tasks, etc.
sqlite3 data/jobs.sqlite3 < db/schema.sql
```
